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


bool wait_consume_input(int d)
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
    bool consumed = false;
    while (true) {
        if (-1 == read(d, &garbage, sizeof(garbage))) {
            if (errno == EAGAIN)
                break;
            fatal_e(E_COMMON, "Can't read from device");
        }
        consumed = true;
    }

    return consumed;
}


void send_report(int d)
{
    ri.report_type = HID_REPORT_TYPE_OUTPUT;
    for (unsigned int u = 0; u <= 63; ++u) {
        ur[u].report_type = ri.report_type;
        if (0 != ioctl(d, HIDIOCSUSAGE, &ur[u]))
            fatal_e(E_RARE, "Can't set usage %u", u);
    }
    if (0 != ioctl(d, HIDIOCSREPORT, &ri))
        fatal_e(E_COMMON, "Can't send report");
}


void communicate(int d)
{
    int32_t command = ur[0].value;

    send_report(d);

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
    send_report(d);

    wait_consume_input(d);

    return ur;
}


int main(int argc, char** argv)
{
    if (argc != 2)
        fatal(E_USAGE, "Usage: %s DEVICE", argv[0]);

    int d = open(argv[1], O_RDWR | O_NONBLOCK);
    if (d == -1)
        fatal_e(E_COMMON, "Can't open device");

    {
        struct hiddev_report_info myri;
        myri.report_id = 0;
        print("Initializing...\n");
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
