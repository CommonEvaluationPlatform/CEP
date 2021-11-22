#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      Makefile
#// Program:        Common Evaluation Platform (CEP)
#// Description:    
#// Notes:          
#//
#//************************************************************************

COSIM_TOP_DIR   	= $(strip $(shell cd ../..; pwd))
COSIM_BIN_DIR       = $(COSIM_TOP_DIR)/bin
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))
TEST_SUITE_DIR		= $(strip $(shell cd ..; pwd))
TEST_SUITE_NAME		= $(shell cd ..; basename `pwd`)
TEST_DIR			= $(strip $(shell cd .; pwd))

# default target
#all: .vrun_flag
all:
ifeq (,$(wildcard $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make))
	$(error "CHIPYARD_BUILD_INFO.make does not exist. run make -f Makefile.chipyard in $(COSIM_TOP_DIR)")
endif

# override anything here before calling the common file
include ${TEST_SUITE_DIR}/common.make

