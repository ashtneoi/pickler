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


int verbosity;


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
        print("GPIO settings are incorrect. Re-writing...\n");

        // Write flash data (write GP settings) //

        ur[0].value = 0xB1; // command
        ur[1].value = 0x01; // command

        for (unsigned int u = 2; u <= 5; ++u)
            ur[u].value = ref[u - 2];

        communicate(d);
    }
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
    }
}
