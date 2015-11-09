#include "common.h"
#include "fail.h"
#include "mcp2221.h"

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <linux/hiddev.h>
#include <poll.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>


#define T_ENTS 1
// >= 100 ns

#define T_ENTH 250
// >= 250 µs

#define T_CKL 1
// >= 100 ns

#define T_CKH 1
// >= 100 ns

#define T_DLY 1
// >= 1 µs

#define T_ERAB 5000
// >= 5 ms

#define T_PINTP 2500
// >= 2.5 ms

#define T_PINTC 5000
// >= 5 ms

#define T_EXIT 1
// >= 1 µs


int verbosity;


uint8_t gp_settings_development[] = {
    0x00, // GP0: GPIO out 0
    0x08, // GP1: GPIO in
    0x08, // GP2: GPIO in
    0x08, // GP3: GPIO in
};


uint8_t gp_settings_production[] = {
    0x10, // GP0: GPIO out 1
    0x08, // GP1: GPIO in
    0x01, // GP2: USBCFG
    0x08, // GP3: GPIO in
};


struct opts {
    bool run;
    bool self;
    bool print_config;
    bool production;
};


struct dev {
    int hid;
    int tty;
    struct hiddev_usage_ref* ur;
};


void exit_with_usage()
{
    fputs("Usage:\n", stderr);
    fputs("  Development mode:\n", stderr);
    fputs("    pickler -R HID  # Run self.\n", stderr);
    fputs("    pickler -S[R] HID HEXFILE  # Program [and run] self.\n",
        stderr);
    fputs("    pickler -Sc HID  # Print self config memory.\n", stderr);
    fputs("    pickler -P HID  # Change to production mode.\n", stderr);
    fputs("  Production mode:\n", stderr);
    fputs("    pickler TTY HEXFILE  # Program.\n", stderr);
    fputs("    pickler -c TTY  # Print config memory.\n", stderr);

    exit(E_USAGE);
}


static
int process_opts(int argc, char** argv, struct opts* opts)
{
    opts->run = false;
    opts->self = false;
    opts->print_config = false;
    opts->production = false;

    opterr = 0;
    int r;
    while ((r = getopt(argc, argv, "cvPRS")) != -1) {
        if (r == 'c') {
            opts->print_config = true;
        } else if (r == 'v') {
            ++verbosity;
        } else if (r == 'P') {
            opts->production = true;
        } else if (r == 'R') {
            opts->run = true;
        } else if (r == 'S') {
            opts->self = true;
        } else if (r == '?') {
            fatal(E_USAGE, "Invalid option '%c'", optopt);
        } else {
            fatal(E_RARE, "Impossible situation");
        }
    }

    if (opts->production && (opts->print_config || opts->run || opts->self))
        fatal(E_USAGE, "-P is mutually exclusive with -c, -R, and -S");
    else if (opts->print_config && opts->run)
        fatal(E_USAGE, "-c and -R are mutually exclusive");

    return optind;
}


static
void verify_gp_settings(struct dev* dev, uint8_t* ref)
{
    // Read flash data (read GP settings). //

    dev->ur[0].value = 0xB0; // command
    dev->ur[1].value = 0x01; // command

    communicate(dev->hid);

    bool correct = true;
    for (unsigned int u = 4; u <= 7; ++u) {
        if (ref[u - 4] != (uint8_t)dev->ur[u].value) {
            correct = false;
            v1("[%d]: 0x%02"PRIX8" should be 0x%02"PRIX8"\n",
                u, (uint8_t)dev->ur[u].value, ref[u - 4]);
        }
    }
    if (!correct) {
        v1("Changing GP settings");
        // Write flash data (write GP settings). //

        dev->ur[0].value = 0xB1; // command
        dev->ur[1].value = 0x01; // command

        for (unsigned int u = 2; u <= 5; ++u)
            dev->ur[u].value = ref[u - 2];

        communicate(dev->hid);
    }

    // Set SRAM settings. //

    dev->ur[0].value = 0x60; // command
    for (unsigned int u = 2; u <= 7; ++u)
        dev->ur[u].value = 0x00; // Don't change this setting.
    for (unsigned int u = 8; u <= 11; ++u)
        dev->ur[u].value = ref[u - 8];
    communicate(dev->hid);
}


struct gp {
    int n_mclr;
    int clk;
    int clk_in;
    int dat;
    int dat_in;
};


static
void set_gp(struct dev* dev, struct gp* gp)
{
    // Set GPIO output values //

    dev->ur[0].value = 0x50; // command

    dev->ur[2].value = 0x01; // set GP0
    dev->ur[3].value = gp->n_mclr; // GP0 = ~MCLR
    dev->ur[4].value = 0x00; // don't set GP0 dir

    dev->ur[6].value = 0x01; // set GP1
    dev->ur[7].value = gp->clk; // GP1 = ISCPCLK
    dev->ur[8].value = 0x01; // set GP1 dir
    dev->ur[9].value = gp->clk_in; // GP1 dir

    dev->ur[10].value = 0x00; // don't set GP2
    dev->ur[12].value = 0x00; // don't set GP2 dir

    dev->ur[14].value = 0x01; // set GP3
    dev->ur[15].value = gp->dat; // GP3 = ISCPDAT
    dev->ur[16].value = 0x01; // set GP3 dir
    dev->ur[17].value = gp->dat_in; // GP3 dir

    communicate(dev->hid);
}


static
int get_dat(struct dev* dev)
{
    // Get GPIO values //

    dev->ur[0].value = 0x51; // command

    communicate(dev->hid);

    return dev->ur[8].value; // GP3 pin value
}


static
void send_data_array(struct dev* dev, unsigned int* data, int len)
{
    struct gp gp = {0};

    for (int b = len - 1; b >= 0; --b) {
        gp.dat = data[b];
        gp.clk = 1;
        set_gp(dev, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(dev, &gp);

        usleep(T_CKL);
    }
}


static
void send_data(struct dev* dev, unsigned int data, int len)
{
    struct gp gp = {0};

    for (int b = 0; b < len; ++b) {
        gp.dat = data & 1;
        data >>= 1;
        gp.clk = 1;
        set_gp(dev, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(dev, &gp);

        usleep(T_CKL);
    }
}


static
unsigned int get_data(struct dev* dev, int len)
{
    struct gp gp = {0};

    gp.dat_in = 1;
    set_gp(dev, &gp);

    unsigned int n = 0;
    for (int b = 0; b < len; ++b) {
        gp.clk = 1;
        set_gp(dev, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(dev, &gp);

        n = (n >> 1) + (get_dat(dev) << (len - 1));

        usleep(T_CKL);
    }

    gp.dat_in = 0;
    set_gp(dev, &gp);

    return n;
}


static
void uart_send_recv(struct dev* dev, uint8_t* buf, int sendlen, int recvlen)
{
    if (verbosity >= 2) {
        print("Sending");
        for (int i = 0; i < sendlen; ++i)
            printf(" 0x%02X", buf[i]);
        print("\n");
    }

    ssize_t r = write(dev->tty, buf, sendlen);
    if (r == -1)
        fatal_e(E_COMMON, "Can't write to device");
    else if (r < sendlen)
        fatal(E_COMMON, "Can't write to device");

    r = read(dev->tty, buf, recvlen);
    if (r == -1)
        fatal_e(E_COMMON, "Can't read from device");
    else if (r < recvlen)
        fatal(E_COMMON, "Can't read from device");

    if (verbosity >= 2) {
        print("Received");
        for (int i = 0; i < recvlen; ++i)
            printf(" 0x%02X", buf[i]);
        print("\n");
    }
}


static
void uart_send_cmd(struct dev* dev, uint8_t* cmd, int len)
{
    uint8_t ack = cmd[0];
    uart_send_recv(dev, cmd, len, 1);
    if (cmd[0] != ack)
        fatal(E_COMMON, "Programmer can't execute '%c' (returned '%c')", ack,
            cmd[0]);
}


static
void pic_enter_LVP(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'N';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        struct gp gp = {0};

        gp.clk_in = 1;
        set_gp(dev, &gp);

        gp.n_mclr = 1;
        set_gp(dev, &gp);

        usleep(T_ENTS);

        gp.clk_in = 0;
        set_gp(dev, &gp);

        gp.n_mclr = 0;
        set_gp(dev, &gp);

        usleep(T_ENTH);

        unsigned int key[33] = {
            0, // don't care
            0, 1, 0, 0,
            1, 1, 0, 1,
            0, 1, 0, 0,
            0, 0, 1, 1,
            0, 1, 0, 0,
            1, 0, 0, 0,
            0, 1, 0, 1,
            0, 0, 0, 0,
        };
        send_data_array(dev, key, lengthof(key));
    }
}


static
void pic_exit_LVP(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'X';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        struct gp gp = {0};

        gp.clk_in = 1;
        set_gp(dev, &gp);

        gp.n_mclr = 1;
        set_gp(dev, &gp);
    }
}


static
void pic_load_configuration(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'C';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        send_data(dev, 0x00, 6);
        usleep(T_DLY);
        send_data(dev, 0x00, 16);
        usleep(T_DLY);
    }
}


static
void pic_load_data(struct dev* dev, unsigned int word)
{
    if (dev->hid == -1) {
        uint8_t cmd[3] = { 'L', word & 0xFF, (word >> 8) & 0x3F };
        uart_send_cmd(dev, cmd, 3);
    } else {
        send_data(dev, 0x02, 6);
        usleep(T_DLY);
        send_data(dev, word << 1, 16);
        usleep(T_DLY);
    }
}


static
unsigned int pic_read_data(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t buf[3] = { 'D' };
        uart_send_recv(dev, buf, 1, 3);
        if (buf[2] != 'D')
            fatal(E_COMMON, "Programmer can't execute 'D'");
        return (buf[1] << 8) | buf[0];
    } else {
        send_data(dev, 0x04, 6);
        usleep(T_DLY);
        unsigned int n = (get_data(dev, 16) >> 1) & 0x3FFF;
        usleep(T_DLY);
        return n;
    }
}


static
void pic_increment_address(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'I';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        send_data(dev, 0x06, 6);
        usleep(T_DLY);
    }
}


static
void pic_reset_address(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'A';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        send_data(dev, 0x16, 6);
        usleep(T_DLY);
    }
}


static
void pic_int_program(struct dev* dev, bool config)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'P';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        send_data(dev, 0x08, 6);
        usleep(config ? T_PINTC : T_PINTP);
    }
}


static
void pic_bulk_erase(struct dev* dev)
{
    if (dev->hid == -1) {
        uint8_t cmd = 'B';
        uart_send_cmd(dev, &cmd, 1);
    } else {
        send_data(dev, 0x09, 6);
        usleep(T_ERAB);
    }
}


static
void print_config(struct dev* dev)
{
    pic_enter_LVP(dev);
    pic_load_configuration(dev);

    unsigned int pc = 0x8000;
    print("User ID:\n");
    for (/* */; pc <= 0x8003; ++pc) {
        printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
            pc, pic_read_data(dev));
        pic_increment_address(dev);
    }
    print("???:\n");
    for (/* */; pc <= 0x8004; ++pc) {
        printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
            pc, pic_read_data(dev));
        pic_increment_address(dev);
    }
    print("Revision and device ID:\n");
    for (/* */; pc <= 0x8006; ++pc) {
        printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
            pc, pic_read_data(dev));
        pic_increment_address(dev);
    }
    print("???:\n");
    for (/* */; pc <= 0x800F; ++pc) {
        printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
            pc, pic_read_data(dev));
        pic_increment_address(dev);
    }

    pic_reset_address(dev);
}


static
void program_hex_file(struct dev* dev, FILE* f)
{
    pic_enter_LVP(dev);
    pic_reset_address(dev);
    pic_bulk_erase(dev);

    int l = 1;
    unsigned int pc = 0, len, newpc = 0;
    int r;
    while (true) {
        unsigned int newpc_l, type;
        r = fscanf(f, ":%2x%4x%2x", &len, &newpc_l, &type);
        if (ferror(f))
            fatal_e(E_COMMON, "Can't read from hex file");
        if (r < 3 || r == EOF)
            fatal(E_COMMON, "%d: Expected colon, length, address, and type",
                l);

        len /= 2;
        newpc_l /= 2;

        if (type == 0x01) {
            break;
        } else if (type == 0x04) {
            unsigned int newpc_h;
            r = fscanf(f, "%4x", &newpc_h);
            if (ferror(f))
                fatal_e(E_COMMON, "Can't read from hex file");
            if (r < 1 || r == EOF)
                fatal(E_COMMON, "%d: Expected upper address", l);
            newpc = newpc_h << 15;
        } else if (type == 0x00) {
            newpc = (newpc & ~0x7FFF) | newpc_l;

            if ((pc < 0x8000 || pc > newpc) && newpc >= 0x8000) {
                pic_load_configuration(dev);
                pc = 0x8000;
            } else if ((pc >= 0x8000 || pc > newpc) && newpc < 0x8000) {
                pic_reset_address(dev);
                pc = 0x0000;
            }

            while (pc < newpc) {
                pic_increment_address(dev);
                ++pc; // no way it'll overflow
            }

            for (unsigned int i = 0; i < len; ++i) {
                unsigned int low, high;
                r = fscanf(f, "%2x%2x", &low, &high);
                if (ferror(f))
                    fatal_e(E_COMMON, "Can't read from hex file");
                if (r < 2 || r == EOF)
                    fatal(E_COMMON, "Expected word");
                unsigned int word = low + (high << 8);
                pic_load_data(dev, word);
                pic_int_program(dev, false);
                printf("[0x%04X] = 0x%04X\n", pc, word);
                pic_increment_address(dev);
                ++pc; // no way it'll overflow
            }
        } else {
            fatal(E_COMMON, "Unrecognized type");
        }

        r = fscanf(f, "%*2x\n");
        if (ferror(f))
            fatal_e(E_COMMON, "Can't read from hex file");
        if (r == EOF)
            fatal(E_COMMON, "Expected checksum and newline");
    }
}


int main(int argc, char** argv)
{
    struct opts opts;

    int first = process_opts(argc, argv, &opts);

    struct dev dev = {
        .hid = -1,
        .tty = -1,
        .ur = NULL,
    };

    if (opts.run || opts.self || opts.production) {
        // (development mode)

        if (argc - first < 1)
            exit_with_usage();

        dev.hid = open(argv[first], O_RDWR | O_NONBLOCK);
        if (dev.hid == -1)
            fatal_e(E_COMMON, "Can't open HID device");

        struct hiddev_report_info ri;
        ri.report_id = 0;
        v1("Initializing HID device...");
        dev.ur = init_report(dev.hid, &ri);

        if (opts.production)
            verify_gp_settings(&dev, gp_settings_production);
        else
            verify_gp_settings(&dev, gp_settings_development);

        if (opts.print_config)
            print_config(&dev);
    } else {
        // (assume production mode)

        if (argc - first < 1)
            exit_with_usage();

        dev.tty = open(argv[first], O_RDWR);
        if (dev.tty == -1)
            fatal_e(E_COMMON, "Can't open TTY device");
    }

    if (!opts.run && !opts.print_config && !opts.production) {
        if (argc - first < 2)
            exit_with_usage();

        FILE* f = fopen(argv[first + 1], "r");
        if (f == NULL)
            fatal_e(E_COMMON, "Can't open hex file");
        program_hex_file(&dev, f);
        fclose(f); // and ignore errors
    }

    if (opts.run)
        pic_exit_LVP(&dev);

    return 0;
}
