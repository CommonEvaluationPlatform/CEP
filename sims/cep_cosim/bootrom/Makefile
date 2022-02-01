#--------------------------------------------------------------------------------------
# Copyright 2021 Massachusetts Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      Makefile
# Program:        Common Evaluation Platform (CEP)
# Description:    Makefile for CEP Bootrom
# Notes:          The original was copied from the Chipyard FPGA resources (VCU118)
#
#--------------------------------------------------------------------------------------

# RISCV *must* be defined (while BFM mode does not use RISCV executables, the SW process builds EVERYTHING, including RISCV)
ifndef RISCV
$(error CEP_COSIM: RISCV is unset. You must set RISCV yourself, or through the Chipyard auto-generated env file)
endif

# By default, FULL_BOOT is NOT enabled
FULL_BOOT		?= 0

# RISCV environment variable must be set
ROOT_DIR		:= $(strip $(shell cd .; pwd))
COSIM_DIR 		:= $(strip $(shell cd ..; pwd))
CONVERT_BOOTROM	:= ${COSIM_DIR}/bin/convert-bootrom.py

BOOTROM_IMG 	= bootrom.rv64.img bootrom.rv32.img
BOOTROM_DUMP	= bootrom.rv64.dump bootrom.rv32.dump
BOOTROM_ELF  	= bootrom.rv64.elf bootrom.rv32.elf

CEP_LDS_FILE    = ${ROOT_DIR}/cep_boot.lds

CC 				= $(RISCV)/bin/riscv64-unknown-elf-gcc
OBJCOPY 		= $(RISCV)/bin/riscv64-unknown-elf-objcopy
OBJDUMP 		= $(RISCV)/bin/riscv64-unknown-elf-objdump
CFLAGS 			= -mcmodel=medany -O2 -std=gnu11 -Wall -nostartfiles
CFLAGS 			+= -fno-common -g -DENTROPY=0 -DNONSMP_HART=0
ifeq (${FULL_BOOT},1)
	CFLAGS  		+= -I $(ROOT_DIR)/include -I ${ROOT_DIR}
else 
	CFLAGS  		+= -I $(ROOT_DIR)/include -I ${ROOT_DIR} -D_SIM_ONLY
endif
CFLAGS_RV64		= -mabi=lp64 -march=rv64ima
CFLAGS_RV32		= -mabi=ilp32 -march=rv32ima
LFLAGS 			= -static -nostdlib -T ${CEP_LDS_FILE}

# default to 1MHz but really should be overridden
PBUS_CLK 		?= 200000000

default: img dump elf rcf

img: $(BOOTROM_IMG)

dump: $(BOOTROM_DUMP)

elf: $(BOOTROM_ELF)

rcf: img
	$(CONVERT_BOOTROM) bootrom.rv64.img bootrom.rv64.rcf 4096

%.img: %.elf
	$(OBJCOPY) -O binary --change-addresses=-0x10000 $< $@

%.dump: %.elf
	$(OBJDUMP) -d $< > $@

bootrom.rv32.elf: head.S kprintf.c sd.c ${CEP_LDS_FILE}
	$(CC) $(CFLAGS) $(CFLAGS_RV32) -DTL_CLK="$(PBUS_CLK)UL" $(LFLAGS) -o $@ head.S sd.c kprintf.c

bootrom.rv64.elf: head.S kprintf.c sd.c ${CEP_LDS_FILE}
	$(CC) $(CFLAGS) $(CFLAGS_RV64) -DTL_CLK="$(PBUS_CLK)UL" $(LFLAGS) -o $@ head.S sd.c kprintf.c

clean:
	rm -f *.elf *.img *.dump *.hex *.rcf

