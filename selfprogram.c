#include "common.h"
#include "fail.h"
#include "mcp2221.h"

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <linux/hiddev.h>
#include <poll.h>
#include <stdbool.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>


#define SCALE 1


#define T_ENTS 1 * SCALE
// >= 100 ns

#define T_ENTH 250 * SCALE
// >= 250 µs

#define T_CKL 1 * SCALE
// >= 100 ns

#define T_CKH 1 * SCALE
// >= 100 ns

#define T_DLY 1 * SCALE
// >= 1 µs

#define T_ERAB 5000 * SCALE
// >= 5 ms

#define T_PINTP 2500 * SCALE
// >= 2.5 ms

#define T_PINTC 5000 * SCALE
// >= 5 ms

#define T_EXIT 1 * SCALE
// >= 1 µs


int verbosity;


static
int process_opts(int argc, char** argv)
{
    opterr = 0;
    int r;
    while ((r = getopt(argc, argv, "v")) != -1) {
        if (r == 'v') {
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
void send_data(int d, struct hiddev_usage_ref* ur, uint8_t* data, int len)
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
int get_data(int d, struct hiddev_usage_ref* ur)
{
    struct gp gp = {0};

    gp.dat_in = 1;
    set_gp(d, ur, &gp);

    int n = 0;
    for (int b = 0; b <= 15; ++b) {
        gp.clk = 1;
        set_gp(d, ur, &gp);

        usleep(T_CKH);

        gp.clk = 0;
        set_gp(d, ur, &gp);

        if (1 <= b && b <= 14)
            n = (n >> 1) + (get_dat(d, ur) << 13);

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

    uint8_t key[33] = {
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
    send_data(d, ur, key, lengthof(key));
}


static
void pic_load_configuration(int d, struct hiddev_usage_ref* ur)
{
    uint8_t command[6] = { 0, 0, 0, 0, 0, 0 };
    send_data(d, ur, command, lengthof(command));

    usleep(T_DLY);

    uint8_t data[16] = {0};
    send_data(d, ur, data, lengthof(data));

    usleep(T_DLY);
}


static
void pic_increment_address(int d, struct hiddev_usage_ref* ur)
{
    uint8_t command[6] = { 0, 0, 0, 1, 1, 0 };
    send_data(d, ur, command, lengthof(command));

    usleep(T_DLY);
}


static
int pic_read_data(int d, struct hiddev_usage_ref* ur)
{
    uint8_t command[6] = { 0, 0, 0, 1, 0, 0 };
    send_data(d, ur, command, lengthof(command));

    usleep(T_DLY);

    int n = get_data(d, ur);

    usleep(T_DLY);

    return n;
}


int main(int argc, char** argv)
{
    int d;
    {
        int first = process_opts(argc, argv);
        if (argc - first < 1)
            fatal(E_USAGE, "Usage: %s [OPTIONS] DEVICE", argv[0]);

        d = open(argv[first], O_RDWR | O_NONBLOCK);
        if (d == -1)
            fatal_e(E_COMMON, "Can't open device");
    }

    {
        struct hiddev_usage_ref* ur;
        {
            struct hiddev_report_info ri;
            ri.report_id = 0;
            v1("Initializing...");
            ur = init_report(d, &ri);
        }

        verify_fix_gp_settings(d, ur);

        pic_enter_lvp(d, ur);

        pic_load_configuration(d, ur);

        unsigned int addr = 0x8000;

        print("User ID:\n");
        for (/* */; addr <= 0x8003; ++addr) {
            printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
                addr, pic_read_data(d, ur));
            pic_increment_address(d, ur);
        }

        for (/* */; addr <= 0x8004; ++addr)
            pic_increment_address(d, ur);

        print("Revision and device ID:\n");
        for (/* */; addr <= 0x8006; ++addr) {
            printf("    [0x%04"PRIX16"]: 0x%04"PRIX16"\n",
                addr, pic_read_data(d, ur));
            pic_increment_address(d, ur);
        }
    }
}
