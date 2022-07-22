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

REPOROOT     	:= $(shell git rev-parse --show-toplevel)
BASEDIR 		:= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
MAINPROGRAM		?= helloworld
PACKAGE     	= BR2_PACKAGE_HOST_$(shell echo $(MAINPROGRAM) | tr '[:lower:]' '[:upper:]')
INSTALL_DIR		= ${REPOROOT}/software/firemarshal/boards/prototype/distros/br/buildroot/package/$(MAINPROGRAM)
CONFIG_HOST		= ${REPOROOT}/software/firemarshal/boards/prototype/distros/br/buildroot/package/Config.in.host
BR_CONFIG		= ${REPOROOT}/software/firemarshal/boards/prototype/base-workloads/br-base/buildroot-config

CC 				:= riscv64-unknown-linux-gnu-gcc
OBJDUMP 		:= riscv64-unknown-linux-gnu-objdump
OBJCOPY 		:= riscv64-unknown-linux-gnu-objcopy
CFLAGS 			:= -mcmodel=medany -O2 -Wall
LDFLAGS 		:= 
OBJS 			:= $(MAINPROGRAM).o
LDSCRIPT 		:= 
HDRS 			:= $(wildcard *.h)
HDRS_SRC		:= $(wildcard *.h) $(wildcard *.c)

%.o: %.c $(HDRS)
	$(CC) $(CFLAGS) -o $@ -c $<
%.o: %.S $(hdrs)
	$(CC) $(CFLAGS) -D__ASSEMBLY__=1 -o $@ -c $<
$(MAINPROGRAM): $(OBJS) $(LDSCRIPT)
	$(CC) $(LDFLAGS) $(if $(LDSCRIPT),-T $(LDSCRIPT)) -o $@ $(OBJS)

.DEFAULT: $(MAINPROGRAM)

install:
	@echo "Installing $(MAINPROGRAM) into firemarshal's buildroot..."
ifeq (,$(shell grep ${PACKAGE} ${BR_CONFIG}))
	echo "$(PACKAGE)=y" >> $(BR_CONFIG)
endif	
ifeq (,$(shell grep "package/${MAINPROGRAM}/Config.in.host" ${CONFIG_HOST}))
	sed -i '/endmenu/i\ \ \ \ source "package\/${MAINPROGRAM}\/Config.in.host"' $(CONFIG_HOST)
endif
	rm -rf $(INSTALL_DIR)
	mkdir $(INSTALL_DIR)
	-cp Config.in.host $(MAINPROGRAM).mk $(HDRS_SRC) $(INSTALL_DIR)

.PHONY: clean
clean:
	rm -f -- $(MAINPROGRAM) *.o
clean_br:
	rm -rf $(INSTALL_DIR)
ifneq (,$(shell grep ${PACKAGE} ${BR_CONFIG}))
	sed -i '/$(PACKAGE)/d' $(BR_CONFIG)
endif	
ifneq (,$(shell grep "package/${MAINPROGRAM}/Config.in.host" ${CONFIG_HOST}))
	sed -i '/package\/${MAINPROGRAM}\/Config.in.host/d' $(BR_CONFIG)
endif
