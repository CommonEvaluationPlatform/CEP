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
COSIM_DIR_NAME  = $(shell cd ../..; basename `pwd`)
REPO_TOP_DIR =  $(shell cd ../../..; pwd | ./${COSIM_DIR_NAME}/bin/strip_net.pl )
BLD_DIR     =  $(shell cd ..; pwd | ../bin/strip_net.pl )
TEST_SUITE  =  $(shell basename ${BLD_DIR})
TEST_DIR    =  $(shell cd .; pwd | ../../bin/strip_net.pl )
TEST_NAME   =  $(shell basename `pwd`)
SIM_DIR     = ${REPO_TOP_DIR}/${COSIM_DIR_NAME}

#
# Top target!!!
#
all: .vrun_flag

#
# override anything here before calling the common file
#
include ${BLD_DIR}/common.make

