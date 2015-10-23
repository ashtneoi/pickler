MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

.SECONDEXPANSION:


EXE_SRC := get_info.c mcp2221.c
SRC := $(EXE_SRC) fail.c info.c

OBJ := $(SRC:%.c=%.o)
EXE := $(EXE_SRC:%.c=%)

CC := gcc
CFLAGS := -std=c99 -g -Wall -Wextra -Werror -Wno-unused-function


all: $(EXE) $(EXTRA_EXE)

$(OBJ): $$(patsubst %.o,%.c,$$@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(EXE) $(EXTRA_EXE):
	$(CC) -o $@ $^

$(EXE): $$@.o

clean:
	rm -f $(OBJ) $(EXE)


fail.o: common.h fail.h
get_info.o: common.h fail.h info.h
info.o: common.h fail.h info.h
mcp2221.o: common.h fail.h info.h


get_info: fail.o info.o
mcp2221: fail.o info.o


.DEFAULT_GOAL := all
.PHONY: all clean
