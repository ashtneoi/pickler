#pragma once


#define _POSIX_C_SOURCE 2
#define _BSD_SOURCE 1


#define lengthof(x) (sizeof(x) / sizeof((x)[0]))


#define E_COMMON 1
#define E_RARE 2
#define E_USAGE 127
