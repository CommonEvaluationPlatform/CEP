#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      
#// Program:        Common Evaluation Platform (CEP)
#// Description:    
#// Notes:          
#//
#//************************************************************************
#
#
#
COSIM_TOP_DIR  = $(shell cd ../..; basename `pwd`)
REPO_TOP_DIR = $(shell cd ../../..; pwd | ./${COSIM_TOP_DIR}/bin/strip_net.pl )
BLD_DIR     = $(shell cd ..; pwd | ../bin/strip_net.pl )
TEST_SUITE  = $(shell basename ${BLD_DIR})
TEST_DIR    = $(shell cd .; pwd | ../../bin/strip_net.pl )
TEST_NAME   = $(shell basename `pwd`)
SIM_DIR     = ${REPO_TOP_DIR}/${COSIM_TOP_DIR}


#
# Top target!!!
#
all: .vrun_flag riscv_wrapper.elf

#
# override anything here before calling the common file
#
include ${BLD_DIR}/common.make

