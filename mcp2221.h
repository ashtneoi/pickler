#pragma once


#include "common.h"

#include <linux/hiddev.h>


void communicate(int d);
struct hiddev_usage_ref* init_report(int d, struct hiddev_report_info* new_ri);
