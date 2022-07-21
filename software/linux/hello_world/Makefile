#************************************************************************
# Copyright 2022 Massachusets Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      Makefile
# Program:        Common Evaluation Platform (CEP)
# Description:    Standalone Makefile for a RISC-V linux application
# Notes:          
#
#************************************************************************

# RISCV *must* be defined (while BFM mode does not use RISCV executables, the SW process builds EVERYTHING, including RISCV)
ifndef RISCV
$(error RISCV is unset.  You must set RISCV yourself, or through the Chipyard auto-generated env file)
endif

BASEDIR 	:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INCDIR 		:= $(BASEDIR)/include
MAINPROGRAM	?= hello_world

CC 			:= riscv64-unknown-linux-gnu-gcc
OBJDUMP 	:= riscv64-unknown-linux-gnu-objdump
OBJCOPY 	:= riscv64-unknown-linux-gnu-objcopy
CFLAGS 		:= -mcmodel=medany -O2 -Wall
CFLAGS 		+= -I $(INCDIR)
LDFLAGS 	:= 
OBJS 		:= 
LDSCRIPT 	:= 
HDRS 		:= $(wildcard *.h) $(wildcard $(INCDIR)/*.h)

%.o: %.c $(HDRS)
	$(CC) $(CFLAGS) -o $@ -c $<
%.o: %.S $(hdrs)
	$(CC) $(CFLAGS) -D__ASSEMBLY__=1 -o $@ -c $<
%.elf: %.o $(OBJS) $(LDSCRIPT)
	$(CC) $(LDFLAGS) $(if $(LDSCRIPT),-T $(LDSCRIPT)) -o $@ $< $(OBJS)
%.dump: %.elf
	$(OBJDUMP) -d $< > $@

.DEFAULT: elf

.PHONY: elf dump
elf: $(addsuffix .elf,$(MAINPROGRAM))
dump: $(addsuffix .dump,$(MAINPROGRAM))

.PHONY: clean
clean:
	rm -f -- *.elf *.o *.dump *.img

.SUFFIXES:
.SUFFIXES: .o .c .S
