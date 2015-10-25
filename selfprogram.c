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
        struct hiddev_report_info ri;
        ri.report_id = 0;
        v1("Initializing...");
        struct hiddev_usage_ref* ur = init_report(d, &ri);

        print("Status/set parameters:\n");
        ur[0].value = 0x10;
        ur[3].value = 0x00;
        communicate(d);
        for (unsigned int u = 0; u <= 25; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)ur[u].value);
        for (unsigned int u = 46; u <= 55; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)ur[u].value);

        print("Read data (read chip settings):\n");
        ur[0].value = 0xB0;
        ur[1].value = 0x00;
        communicate(d);
        for (unsigned int u = 0; u <= 13; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)ur[u].value);
    }
}
