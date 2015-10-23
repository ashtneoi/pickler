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


int main(int argc, const char** argv)
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
        char name[256];
        if (-1 == ioctl(d, HIDIOCGNAME(lengthof(name)), name))
            fatal_e(E_RARE, "Can't get device name");
        printf("device name = %s\n", name);
    }

    {
        struct hiddev_devinfo di;
        if (0 != ioctl(d, HIDIOCGDEVINFO, &di))
            fatal(E_RARE, "Can't get device info");
        print("Device info:\n");
        print_devinfo(d, &di);
    }

    {
        struct hiddev_report_info ri = {
            .report_type = HID_REPORT_TYPE_OUTPUT,
            .report_id = HID_REPORT_ID_FIRST,
        };
        while (true) {
            if (0 != ioctl(d, HIDIOCGREPORTINFO, &ri))
                break;
            printf("Output report %d:\n", ri.report_id);
            printf("    num_fields = %d\n", ri.num_fields);

            struct hiddev_field_info fi = {
                .report_type = ri.report_type,
                .report_id = ri.report_id,
            };
            for (unsigned int f = 0; f < ri.num_fields; ++f) {
                fi.field_index = f;
                if (0 != ioctl(d, HIDIOCGFIELDINFO, &fi))
                    fatal_e(E_RARE, "Can't get field info");
                fi.field_index = f; // For some reason it's overwritten.
                printf("    Field %u:\n", fi.field_index);
                print_field_info(d, &fi);
            }

            ri.report_id |= HID_REPORT_ID_NEXT;
        }
    }
}
