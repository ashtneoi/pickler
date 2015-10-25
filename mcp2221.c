#include "common.h"
#include "fail.h"
#include "info.h"

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


struct hiddev_usage_ref ur[64];
struct hiddev_report_info ri;


int verbosity;


int process_opts(int argc, char** argv)
{
    opterr = 0;
    int r;
    while ((r = getopt(argc, argv, "v")) != -1) {
        if (r == 'v') {
            ++verbosity;
        } else if (r == '?') {
            fatal(E_COMMON, "Invalid option '%c'", r);
        } else {
            fatal(E_RARE, "Impossible situation");
        }
    }

    return optind;
}


void wait_consume_input(int d)
{
    struct pollfd pf = {
        .fd = d,
        .events = POLLIN,
    };

    int r = poll(&pf, 1, 100);
    if (r == -1)
        fatal_e(E_COMMON, "Can't poll() device");
    else if (r == 0)
        print("poll() timed out\n");

    struct hiddev_event garbage;
    while (true) {
        if (-1 == read(d, &garbage, sizeof(garbage))) {
            if (errno == EAGAIN)
                break;
            fatal_e(E_COMMON, "Can't read from device");
        }
    }
}


void communicate(int d)
{
    int32_t command = ur[0].value;

    ri.report_type = HID_REPORT_TYPE_OUTPUT;
    for (unsigned int u = 0; u <= 63; ++u) {
        ur[u].report_type = ri.report_type;
        if (0 != ioctl(d, HIDIOCSUSAGE, &ur[u]))
            fatal_e(E_RARE, "Can't set usage %u", u);
    }
    if (0 != ioctl(d, HIDIOCSREPORT, &ri))
        fatal_e(E_COMMON, "Can't send report");

    wait_consume_input(d);
    /*if (!wait_consume_input(d))*/
        /*fatal(E_RARE, "Didn't consume any input\n");*/

    ri.report_type = HID_REPORT_TYPE_INPUT;
    if (0 != ioctl(d, HIDIOCGREPORT, &ri))
        fatal_e(E_COMMON, "Can't get report");
    for (unsigned int u = 0; u <= 63; ++u) {
        ur[u].report_type = ri.report_type;
        if (0 != ioctl(d, HIDIOCGUSAGE, &ur[u]))
            fatal_e(E_RARE, "Can't get value of usage %u", u);
    }

    if (ur[0].value != command)
        fatal(E_RARE, "Command not echoed");
    else if (ur[1].value != 0)
        fatal(E_COMMON, "Command failed");
}


struct hiddev_usage_ref* init_report(int d, struct hiddev_report_info* new_ri)
{
    {
        struct hiddev_event garbage;
        ssize_t count;
        while ( !(count == -1 && errno == EAGAIN) )
            count = read(d, &garbage, sizeof(garbage));
    }

    ri = *new_ri;
    ri.report_type = HID_REPORT_TYPE_OUTPUT;

    {
        int version;
        if (0 != ioctl(d, HIDIOCGVERSION, &version))
            fatal(E_RARE, "Can't get hiddev version");
        /*printf("hiddev is version 0x%x\n", version);*/
    }

    for (unsigned int u = 0; u <= 63; ++u) {
        ur[u].report_type = HID_REPORT_TYPE_OUTPUT;
        ur[u].report_id = ri.report_id;
        ur[u].field_index = 0;
        ur[u].usage_index = u;
        if (0 != ioctl(d, HIDIOCGUCODE, &ur[u]))
            fatal_e(E_RARE, "Can't get usage code %u", u);
    }

    wait_consume_input(d);

    ur[0].value = 0x10;
    communicate(d);

    return ur;
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
        struct hiddev_report_info myri;
        myri.report_id = 0;
        v1("Initializing...");
        struct hiddev_usage_ref* myur = init_report(d, &myri);

        print("Status/set parameters:\n");
        myur[0].value = 0x10;
        myur[3].value = 0x00;
        communicate(d);
        for (unsigned int u = 0; u <= 25; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)myur[u].value);
        for (unsigned int u = 46; u <= 55; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)myur[u].value);

        print("Read data (read chip settings):\n");
        myur[0].value = 0xB0;
        myur[1].value = 0x00;
        communicate(d);
        for (unsigned int u = 0; u <= 13; ++u)
            printf("    [%2d] = 0x%02"PRIX8"\n", u, (uint8_t)myur[u].value);
    }
}
