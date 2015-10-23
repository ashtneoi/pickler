#pragma once


#include "common.h"


#include <linux/hiddev.h>


void print_devinfo(int d, const struct hiddev_devinfo* const di);
void print_usage_ref(const struct hiddev_usage_ref* ur);
void print_field_info(int d, const struct hiddev_field_info* const fi);
