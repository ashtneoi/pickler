#include "common.h"
#include "fail.h"

#include <fcntl.h>
#include <inttypes.h>
#include <linux/hiddev.h>
#include <stdbool.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>


#define E_COMMON 1
#define E_RARE 2
#define E_USAGE 127


void print_devinfo(int d, struct hiddev_devinfo* di)
{
    printf("    bustype = %"PRIu32"\n", di->bustype);
    printf("    busnum = %"PRIu32"\n", di->busnum);
    printf("    devnum = %"PRIu32"\n", di->devnum);
    printf("    ifnum = %"PRIu32"\n", di->ifnum);
    printf("    vendor = 0x%04"PRIX16"\n", (uint16_t)di->vendor);
    printf("    product = 0x%04"PRIX16"\n", (uint16_t)di->product);
    printf("    version = 0x%04"PRIX16"\n", (uint16_t)di->version);
    printf("    num_applications = %"PRIu32"\n", di->num_applications);

    for (unsigned int i = 0; i < di->num_applications; ++i) {
        struct hiddev_collection_info ci = { .index = i };
        if (-1 == ioctl(d, HIDIOCGCOLLECTIONINFO, &ci))
            fatal_e(E_RARE, "Can't get application usage %u", i);
        printf("Application usage %u:\n", i);
        printf("    type = 0x%04"PRIX16"\n", (uint16_t)ci.type);
        uint16_t usage_page = (uint32_t)ci.usage >> 16;
        uint16_t usage = (uint32_t)ci.usage & 0xFFFF;
        printf("    usage = 0x%04"PRIX16", 0x%04"PRIX16"\n", usage_page,
            usage);
        printf("    level = 0x%04"PRIX16"\n", (uint16_t)ci.level);
    }
}


void print_field_info(struct hiddev_field_info* fi)
{
    printf("        maxusage = 0x%04"PRIX32"\n", fi->maxusage);
    printf("        flags = 0x%04"PRIX32"\n", fi->flags);
    printf("        physical usage = 0x%04"PRIX32"\n", fi->physical);
    printf("        logical usage = 0x%04"PRIX32"\n", fi->logical);
    printf("        application usage = 0x%04"PRIX32"\n", fi->maxusage);
    printf("        logical min = %"PRId32"\n", fi->logical_minimum);
    printf("        logical max = %"PRId32"\n", fi->logical_maximum);
    printf("        physical min = %"PRId32"\n", fi->physical_minimum);
    printf("        physical max = %"PRId32"\n", fi->physical_maximum);
    printf("        unit_exponent = 0x%04"PRIX32"\n", fi->unit_exponent);
    printf("        unit = 0x%04"PRIX32"\n", fi->unit);
}


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
            .report_type = HID_REPORT_TYPE_INPUT,
            .report_id = HID_REPORT_ID_FIRST,
        };
        while (true) {
            if (0 != ioctl(d, HIDIOCGREPORTINFO, &ri))
                break;
            printf("Input report %d:\n", ri.report_id);
            printf("    num_fields = %d\n", ri.num_fields);

            for (unsigned int i = 0; i < ri.num_fields; ++i) {
                struct hiddev_field_info fi = {
                    .report_type = ri.report_type,
                    .report_id = ri.report_id,
                    .field_index = i,
                };
                if (0 != ioctl(d, HIDIOCGFIELDINFO, &fi))
                    fatal_e(E_RARE, "Can't get field info");
                printf("    Field %u:\n", i);
                print_field_info(&fi);
            }

            ri.report_id |= HID_REPORT_ID_NEXT;
        }
    }
}
