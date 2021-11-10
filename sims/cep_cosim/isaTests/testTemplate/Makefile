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
REPO_TOP_DIR = $(shell cd ../../..; pwd )
BLD_DIR     = $(shell cd ..; pwd )
TEST_SUITE  = $(shell basename ${BLD_DIR})
TEST_DIR    = $(shell cd .; pwd )
TEST_NAME   = $(shell basename `pwd`)
SIM_DIR     = ${REPO_TOP_DIR}/${COSIM_TOP_DIR}
ELF_FILE    = ${RISCV_TEST_DIR}/isa/${TEST_NAME}

#
# Top target!!!
#
all: .vrun_flag 

#
# override anything here before calling the common file
#
include ${BLD_DIR}/common.make



