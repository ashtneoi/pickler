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


struct hiddev_usage_ref ur[64];
struct hiddev_report_info ri;


static
void wait_consume_input(int d)
{
    struct pollfd pf = {
        .fd = d,
        .events = POLLIN,
    };

    int r = poll(&pf, 1, 1);
    if (r == -1)
        fatal_e(E_COMMON, "Can't poll() device");

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
        fatal(E_RARE,
            "Command not echoed (command = 0x%02X, response = 0x%02X)",
            command, ur[0].value);
    else if (ur[1].value != 0)
        fatal(E_COMMON, "Command failed");
}


struct hiddev_usage_ref* init_report(int d, struct hiddev_report_info* new_ri)
{
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
