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


void print_devinfo(int d, const struct hiddev_devinfo* const di)
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
        uint16_t usage_code = (uint32_t)ci.usage & 0xFFFF;
        printf("    usage = page 0x%04"PRIX16", code 0x%04"PRIX16"\n",
            usage_page, usage_code);
        printf("    level = 0x%04"PRIX16"\n", (uint16_t)ci.level);
    }
}


void print_usage_ref(const struct hiddev_usage_ref* ur)
{
    uint16_t usage_page = (uint32_t)ur->usage_code >> 16;
    uint16_t usage_code = (uint32_t)ur->usage_code & 0xFFFF;
    printf("            usage = page 0x%04"PRIX16", code 0x%04"PRIX16"\n",
        usage_page, usage_code);
    printf("            value = 0x%04"PRIX32"\n", (uint32_t)ur->value);
}


void print_field_info(int d, const struct hiddev_field_info* const fi)
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

    for (unsigned int u = 0; u < fi->maxusage; ++u) {
        struct hiddev_usage_ref ur = {
            .report_type = fi->report_type,
            .report_id = fi->report_id,
            .field_index = fi->field_index,
            .usage_index = u,
        };
        if (0 != ioctl(d, HIDIOCGUCODE, &ur))
            fatal_e(E_RARE, "Can't get usage code");
        printf("        Usage %d:\n", u);
        print_usage_ref(&ur);
    }
}
