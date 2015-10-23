MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

.SECONDEXPANSION:


EXE_SRC := info.c
SRC := $(EXE_SRC) fail.c

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


fail.o: fail.h common.h
info.o: fail.h

info: fail.o


.DEFAULT_GOAL := all
.PHONY: all clean
