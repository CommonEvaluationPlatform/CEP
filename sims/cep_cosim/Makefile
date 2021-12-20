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

# The following flags / variables can be overridden by lower level makefiles or the command line
MODELSIM        			?= 1
CADENCE 					?= 0
override NOWAVE          	= 1
PROFILE         			?= 0
COVERAGE        			?= 0
USE_GDB       				?= 0
TL_CAPTURE      			?= 0
UPDATE_INFO 				= 1
# Each test suite will set its own value
DUT_SIM_MODE				= BFM

# Basic test variables
COSIM_TOP_DIR   			= $(strip $(shell pwd))
COSIM_BIN_DIR       		= $(COSIM_TOP_DIR)/bin
REPO_TOP_DIR 				= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))

# Tests to run as part of the default build target
TEST_SUITES  =  	bareMetalTests	\
					bfmTests		\
					isaTests		\
					vBareTest

# Run tests for all members of the test group
runAll: 
	make cleanAll
	make buildLibs
	@for i in ${TEST_SUITES}; do							\
		rm -f $${i}/$${i}.log;								\
		(cd testSuites/$${i}; make STAND_ALONE=0 runAll); 	\
	done

# Print summary
summary: .force
	@date > ${COSIM_TOP_DIR}/regressionSummary
	@for i in ${TEST_SUITES}; do								\
		(cd testSuites/$${i}; make -s STAND_ALONE=0 summary | sort | tee -a ${COSIM_TOP_DIR}/regressionSummary);	\
	done

# Include the common makefile
include $(COSIM_TOP_DIR)/common.make


