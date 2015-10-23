#include "common.h"
#include "fail.h"

#include <fcntl.h>
#include <inttypes.h>
#include <linux/hiddev.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>


#define E_COMMON 1
#define E_RARE 2
#define E_USAGE 127


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
        struct hiddev_devinfo devinfo;
        if (0 != ioctl(d, HIDIOCGDEVINFO, &devinfo))
            fatal(E_RARE, "Can't get device info");
        print("Device info:\n");
        printf("    bustype = %"PRIu32"\n", devinfo.bustype);
        printf("    busnum = %"PRIu32"\n", devinfo.busnum);
        printf("    devnum = %"PRIu32"\n", devinfo.devnum);
        printf("    ifnum = %"PRIu32"\n", devinfo.ifnum);
        printf("    vendor = 0x%04"PRIX16"\n", (uint16_t)devinfo.vendor);
        printf("    product = 0x%04"PRIX16"\n", (uint16_t)devinfo.product);
        printf("    version = 0x%04"PRIX16"\n", (uint16_t)devinfo.version);
        printf("    num_applications = %"PRIu32"\n", devinfo.num_applications);

        for (unsigned int i = 0; i < devinfo.num_applications; ++i) {
            printf("Application %u:\n", i);
            struct hiddev_collection_info coll_info;
            coll_info.index = i;
            if (-1 == ioctl(d, HIDIOCGCOLLECTIONINFO, &coll_info))
                fatal_e(E_RARE, "Can't get application usage %u", i);
            printf("    type = 0x%04"PRIX16"\n", (uint16_t)coll_info.type);
            uint16_t usage_page = (uint32_t)coll_info.usage >> 16;
            uint16_t usage = (uint32_t)coll_info.usage & 0xFFFF;
            printf("    usage = 0x%04"PRIX16", 0x%04"PRIX16"\n", usage_page, usage);
            printf("    level = 0x%04"PRIX16"\n", (uint16_t)coll_info.level);
        }
    }
}
