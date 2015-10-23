#include "common.h"
#include "fail.h"
#include "info.h"

#include <fcntl.h>
#include <inttypes.h>
#include <linux/hiddev.h>
#include <stdbool.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>


int main(int argc, char** argv)
{
    if (argc != 2)
        fatal(E_USAGE, "Usage: %s DEVICE", argv[0]);

    int d = open(argv[1], O_RDWR);
    if (d == -1)
        fatal_e(E_COMMON, "Can't open device");

    {
        int version;
        if (0 != ioctl(d, HIDIOCGVERSION, &version))
            fatal(E_RARE, "Can't get hiddev version");
        printf("hiddev is version 0x%x\n", version);
    }

    {
        uint8_t data[64];
        data[0] = 0x61;
        for (unsigned int u = 0; u <= 63; ++u) {
            struct hiddev_usage_ref ur = {
                .report_type = HID_REPORT_TYPE_OUTPUT,
                .report_id = 0,
                .field_index = 0,
                .usage_index = u,
                .value = data[u],
            };
            if (0 != ioctl(d, HIDIOCSUSAGE, &ur))
                fatal_e(E_RARE, "Can't set usage %u", u);
        }
    }
}
