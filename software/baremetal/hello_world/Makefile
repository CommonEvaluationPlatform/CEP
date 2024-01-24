#************************************************************************
# Copyright 2024 Massachusetts Institute of Technology
# SPDX short identifier: BSD-3-Clause
#
# File Name:      Makefile
# Program:        Common Evaluation Platform (CEP)
# Description:    Standalone Makefile for baremetal RISC-V executables
# Notes:          
#
#************************************************************************

# RISCV *must* be defined (while BFM mode does not use RISCV executables, the SW process builds EVERYTHING, including RISCV)
ifeq "$(findstring clean,${MAKECMDGOALS})" ""
ifndef RISCV
$(error RISCV is unset.  You must set RISCV yourself, or through the Chipyard auto-generated env file)
endif
endif

PLATFORM_TARGET	?= fpga

# Settings not dependent on FPGA target
REPO_ROOT_DIR	:= $(shell git rev-parse --show-toplevel)
BASEDIR 		:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INCDIR 			:= $(BASEDIR)include
MAINPROGRAM		?= hello_world
HDRS 			:= $(wildcard *.h) $(wildcard $(INCDIR)/*.h)
GCC 			:= riscv64-unknown-elf-gcc
OBJDUMP 		:= riscv64-unknown-elf-objdump
OBJCOPY 		:= riscv64-unknown-elf-objcopy

ifeq ($(PLATFORM_TARGET), fpga)
CFLAGS			:= -DFPGA
else ifeq ($(PLATFORM_TARGET), verilator)
CFLAGS			:= -DVERILATOR
else
$(error $(PLATFORM_TARGET) is an invalid platform target)
endif

ifeq "$(findstring clean,${MAKECMDGOALS})" ""
$(info )
$(info Building for $(PLATFORM_TARGET)...)
$(info )
endif

# Common Flag settings, regardless of platform target
CFLAGS			:= -mcmodel=medany -O2 -fno-common -fno-builtin-printf -fno-builtin-puts -Wall -Wno-unused-function
CFLAGS			+= -I $(INCDIR)
LDFLAGS			:= -static

# Flags unique to the FPGA target
ifeq ($(PLATFORM_TARGET), fpga)
LDFLAGS 		+= -nostdlib -nostartfiles -lgcc
OBJS 			:= crt.o syscalls.o kprintf.o
LDSCRIPT 		:= link.ld

# Include libgloss if targetting verilator
else ifeq ($(PLATFORM_TARGET), verilator)
include $(REPO_ROOT_DIR)/tests/libgloss.mk
endif

.DEFAULT_GOAL 	:= default

default: riscv dump img elf
.PHONY: default riscv dump img elf

dump: $(addsuffix .dump,$(MAINPROGRAM))

# Common targets
%.o: %.S $(HDRS)
	$(GCC) $(CFLAGS) -D__ASSEMBLY__=1 -c $< -o $@

%.o: %.c $(HDRS)
	$(GCC) $(CFLAGS) -c $< -o $@

# FPGA unique targets
ifeq ($(PLATFORM_TARGET), fpga)
elf: $(addsuffix .elf,$(MAINPROGRAM))
img: $(addsuffix .img,$(MAINPROGRAM))

%.elf: %.o $(OBJS) $(LDSCRIPT)
	$(GCC) $(LDFLAGS) -T $(LDSCRIPT) -o $@ $< $(OBJS)
%.img: %.elf
	$(OBJCOPY) -O binary $< $@
%.dump: %.elf
	$(OBJDUMP) -d $< > $@
sd_write: img
ifneq (,$(wildcard ${DISK}))
	sudo dd if=$(MAINPROGRAM).img of=$(DISK) bs=4096 conv=fsync
else
	$(error Invalid DISK specified for SD write)
endif

# Verilator unique targets
else ifeq ($(PLATFORM_TARGET), verilator)
riscv: $(addsuffix .riscv,$(MAINPROGRAM))

%.riscv: %.o $(libgloss)
	$(GCC) $(LDFLAGS) $< -o $@
%.dump: %.riscv
	$(OBJDUMP) -D $< > $@
endif

.PHONY: clean
clean:
	rm -f *.riscv *.o *.dump *.elf *.img
	$(if $(libgloss),rm -rf $(libgloss_builddir)/)
