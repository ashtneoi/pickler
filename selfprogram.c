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


struct opts {
    bool clk_test_pattern;
    bool program_file;
    bool print_config;
    bool run;
    bool test;
};


static
int process_opts(int argc, char** argv, struct opts* opts)
{
    opterr = 0;
    int r;
    while ((r = getopt(argc, argv, "cfprTv")) != -1) {
        if (r == 'c') {
            opts->clk_test_pattern = true;
        } else if (r == 'f') {
            opts->program_file = true;
        } else if (r == 'p') {
            opts->print_config = true;
        } else if (r == 'r') {
            opts->run = true;
        } else if (r == 'T') {
            opts->test = true;
        } else if (r == 'v') {
            ++verbosity;
        } else if (r == '?') {
            fatal(E_COMMON, "Invalid option '%c'", optopt);
        } else {
            fatal(E_RARE, "Impossible situation");
        }
    }

    return optind;
}


static
void verify_fix_gp_settings(int d, struct hiddev_usage_ref* ur)
{
    // Read flash data (read GP settings) //

    ur[0].value = 0xB0; // command
    ur[1].value = 0x01; // command

    communicate(d);

    bool correct = true;
    uint8_t ref[4] = {0x00, 0x00, 0x01, 0x00};
    for (unsigned int u = 0; u <= 3; ++u) {
        if (ref[u] != (uint8_t)ur[u + 4].value) {
            correct = false;
            printf("[%d]: 0x%02"PRIX8" should be 0x%02"PRIX8"\n",
                u, (uint8_t)ur[u + 4].value, ref[u]);
        }
    }
    if (!correct) {
        print("GP settings are incorrect. Fixing...\n");

        // Write flash data (write GP settings) //

        ur[0].value = 0xB1; // command
        ur[1].value = 0x01; // command

        for (unsigned int u = 2; u <= 5; ++u)
            ur[u].value = ref[u - 2];

        communicate(d);

        print("GP settings fixed.\n");
        fatal(E_COMMON,
            "Now reset the programmer and run this program again.");
    }
}


struct gp {
    int n_mclr;
    int clk;
    int dat;
    int dat_in;
};


static
void set_gp(int d, struct hiddev_usage_ref* ur, struct gp* gp)
{
    // Set GPIO output values //

    ur[0].value = 0x50; // command

    ur[2].value = 0x01; // set GP0
    ur[3].value = gp->n_mclr; // GP0 = ~MCLR
    ur[4].value = 0x00; // don't set GP0 dir

    ur[6].value = 0x01; // set GP1
    ur[7].value = gp->clk; // GP1 = ISCPCLK
    ur[8].value = 0x00; // don't set GP1 dir

    ur[10].value = 0x00; // don't set GP2
    ur[12].value = 0x00; // don't set GP2 dir

    ur[14].value = 0x01; // set GP3
    ur[15].value = gp->dat; // GP3 = ISCPDAT
    ur[16].value = 0x01; // set GP3 dir
    ur[17].value = gp->dat_in; // GP3 dir

    communicate(d);
}


static
int get_dat(int d, struct hiddev_usage_ref* ur)
{
    // Get GPIO values //

    ur[0].value = 0x51; // command

    communicate(d);

    return ur[8].value; // GP3 pin value
}


static
void send_data_array(int d, struct hiddev_usage_ref* ur, unsigned int* data,
        int len)
{
    struct gp gp = {0};

    for (int b = len - 1; b >= 0; --b) {
        gp.dat = data[b];
        gp.clk = 1;
        set_gp(d, ur, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(d, ur, &gp);

        usleep(T_CKL);
    }
}


static
void send_data(int d, struct hiddev_usage_ref* ur, unsigned int data, int len)
{
    struct gp gp = {0};

    for (int b = 0; b < len; ++b) {
        gp.dat = data & 1;
        data >>= 1;
        gp.clk = 1;
        set_gp(d, ur, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(d, ur, &gp);

        usleep(T_CKL);
    }
}


static
unsigned int get_data(int d, struct hiddev_usage_ref* ur, int len)
{
    struct gp gp = {0};

    gp.dat_in = 1;
    set_gp(d, ur, &gp);

    unsigned int n = 0;
    for (int b = 0; b < len; ++b) {
        gp.clk = 1;
        set_gp(d, ur, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(d, ur, &gp);

        n = (n >> 1) + (get_dat(d, ur) << (len - 1));

        usleep(T_CKL);
    }

    gp.dat_in = 0;
    set_gp(d, ur, &gp);

    return n;
}


static
void pic_enter_lvp(int d, struct hiddev_usage_ref* ur)
{
    struct gp gp = {0};

    gp.n_mclr = 1;
    set_gp(d, ur, &gp);

    usleep(T_ENTS);

    gp.n_mclr = 0;
    set_gp(d, ur, &gp);

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
    send_data_array(d, ur, key, lengthof(key));
}


static
void pic_load_configuration(int d, struct hiddev_usage_ref* ur)
{
    send_data(d, ur, 0x00, 6);
    usleep(T_DLY);
    send_data(d, ur, 0x00, 16);
    usleep(T_DLY);
}


static
void pic_load_data(int d, struct hiddev_usage_ref* ur, unsigned int word)
{
    send_data(d, ur, 0x02, 6);
    usleep(T_DLY);
    send_data(d, ur, word << 1, 16);
    usleep(T_DLY);
}


static
unsigned int pic_read_data(int d, struct hiddev_usage_ref* ur)
{
    send_data(d, ur, 0x04, 6);
    usleep(T_DLY);
    unsigned int n = (get_data(d, ur, 16) >> 1) & 0x3FFF;
    usleep(T_DLY);
    return n;
}


static
void pic_increment_address(int d, struct hiddev_usage_ref* ur)
{
    send_data(d, ur, 0x06, 6);
    usleep(T_DLY);
}


static
void pic_reset_address(int d, struct hiddev_usage_ref* ur)
{
    send_data(d, ur, 0x16, 6);
    usleep(T_DLY);
}


static
void pic_int_program(int d, struct hiddev_usage_ref* ur, bool config)
{
    send_data(d, ur, 0x08, 6);
    usleep(config ? T_PINTC : T_PINTP);
}


static
void pic_bulk_erase(int d, struct hiddev_usage_ref* ur)
{
    send_data(d, ur, 0x09, 6);
    usleep(T_ERAB);
}


static
void program_hex_file(int d, struct hiddev_usage_ref* ur, FILE* f)
{
    pic_reset_address(d, ur);
    pic_bulk_erase(d, ur);

    unsigned int pc = 0, len, newpc = 0;
    int r;
    while (true) {
        unsigned int newpc_l, type;
        r = fscanf(f, ":%2x%4x%2x", &len, &newpc_l, &type);
        if (ferror(f))
            fatal_e(E_COMMON, "Can't read from hex file");
        if (r < 3 || r == EOF)
            fatal(E_COMMON, "Expected colon, length, address, and type");

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
                fatal(E_COMMON, "Expected upper address");
            newpc = newpc_h << 15;
        } else if (type == 0x00) {
            newpc = (newpc & ~0x7FFF) | newpc_l;

            if ((pc < 0x8000 || pc > newpc) && newpc >= 0x8000) {
                pic_load_configuration(d, ur);
                pc = 0x8000;
            } else if ((pc >= 0x8000 || pc > newpc) && newpc < 0x8000) {
                pic_reset_address(d, ur);
                pc = 0x0000;
            }

            while (pc < newpc) {
                pic_increment_address(d, ur);
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
                pic_load_data(d, ur, word);
                pic_int_program(d, ur, false);
                printf("[0x%04X] = 0x%04X\n", pc, word);
                pic_increment_address(d, ur);
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
    struct opts opts = {0};
    int first = process_opts(argc, argv, &opts);
    if (opts.program_file + opts.print_config + opts.test > 1)
        fatal(E_USAGE, "-f, -p, and -T are mutually exclusive");
    if (argc - first != (opts.program_file ? 2 : 1))
        fatal(E_USAGE, "Usage: %s [OPTIONS] DEVICE [HEXFILE]", argv[0]);

    int d = open(argv[first], O_RDWR | O_NONBLOCK);
    if (d == -1)
        fatal_e(E_COMMON, "Can't open device");

    struct hiddev_usage_ref* ur;
    {
        struct hiddev_report_info ri;
        ri.report_id = 0;
        v1("Initializing...");
        ur = init_report(d, &ri);
    }
    verify_fix_gp_settings(d, ur);

    pic_enter_lvp(d, ur);

    if (opts.print_config) {
        pic_load_configuration(d, ur);

        unsigned int pc = 0x8000;
        print("User ID:\n");
        for (/* */; pc <= 0x8003; ++pc) {
            printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
                pc, pic_read_data(d, ur));
            pic_increment_address(d, ur);
        }
        for (/* */; pc <= 0x8004; ++pc)
            pic_increment_address(d, ur);
        print("Revision and device ID:\n");
        for (/* */; pc <= 0x8006; ++pc) {
            printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
                pc, pic_read_data(d, ur));
            pic_increment_address(d, ur);
        }
    }

    if (opts.test) {
        pic_load_configuration(d, ur);
        pic_bulk_erase(d, ur);
        pic_load_data(d, ur, 0x0123);
        pic_int_program(d, ur, true);
    }

    if (opts.program_file) {
        FILE* f = fopen(argv[first + 1], "r");
        if (f == NULL)
            fatal_e(E_COMMON, "Can't open hex file");
        program_hex_file(d, ur, f);
        fclose(f); // and ignore errors
    }

    if (opts.run) {
        struct gp gp = {
            .n_mclr = 1,
            .clk = 0,
            .dat = 0,
            .dat_in = 0,
        };
        set_gp(d, ur, &gp);
    }

    if (opts.clk_test_pattern) {
        struct gp gp = {
            .n_mclr = 1,
            .clk = 0,
            .dat = 0,
            .dat_in = 0,
        };

        while (true) {
            sleep(1);
            printf("ICSPCLK = %d\n", gp.clk);
            set_gp(d, ur, &gp);
            gp.clk = 1 - gp.clk;
        }
    }


    close(d); // and ignore errors

    return 0;
}
