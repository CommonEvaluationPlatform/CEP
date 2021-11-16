#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      Makefile
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Top level makefile for the CEP co-simulation
#//                 environment.  
#// Notes:          
#//
#//************************************************************************

# Default build target
all: runAll

# Always in regression mode
override NOWAVE  = 1
UPDATE_INFO = 1

# Basic test variables
COSIM_TOP_DIR  	= $(shell basename `pwd`)
REPO_TOP_DIR 	= $(shell cd ../..; pwd | ./${COSIM_TOP_DIR}/bin/strip_net.pl )
BLD_DIR     	= $(shell cd ./bfmTests; pwd | ../bin/strip_net.pl )
TEST_SUITE  	= $(shell basename ${BLD_DIR})

# Tests to run as part of the default build target
TEST_GROUP  =  	bareMetalTests	\
		bfmTests	\
		isaTests	\
		vBareTest	\

# Run tests for all members of the test group
runAll: 
	make cleanAll
	make buildLibs
	@for i in ${TEST_GROUP}; do				\
		rm -f $${i}/$${i}.log;				\
		(cd $${i}; make STAND_ALONE=0 runAll); 		\
	done

# Print summary
summary: .force
	@date > ${COSIM_TOP_DIR}/regressionSummary
	@for i in ${TEST_GROUP}; do								\
		(cd $${i}; make -s STAND_ALONE=0 summary | sort | tee -a ${COSIM_TOP_DIR}/regressionSummary);	\
	done

# Include the common makefile
include $(COSIM_TOP_DIR)/common.make


