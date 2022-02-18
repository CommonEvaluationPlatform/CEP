#//************************************************************************
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      Makefile
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Top level Makefile for the CEP co-simulation
#//                 environment 
#// Notes:          
#//
#//************************************************************************

# Default build target
all: runAll

COSIM_TOP_DIR   	= $(strip $(shell cd .; pwd))
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))
TEST_SUITE_DIR		= $(strip $(shell cd .; pwd))
TEST_SUITE_NAME		= $(shell cd .; basename `pwd`)

# Default parameters usually set by thbe test suite
DUT_SIM_MODE		= BFM

# Tests to run as part of the default build target
TEST_SUITES  		= bareMetalTests	
#					bfmTests		\
#					isaTests		\
#					vBareTest


# Run tests for all members of the test group
runAll: 
	@for i in ${TEST_SUITES}; do												\
		(cd ${COSIM_TOP_DIR}/testSuites/$${i}; make STAND_ALONE=0 runAll); 	\
	done

# Print summary
summary: .force
	@date > ${COSIM_TOP_DIR}/regressionSummary
	@for i in ${TEST_SUITES}; do								\
		(cd testSuites/$${i}; make -s STAND_ALONE=0 summary | sort | tee -a ${COSIM_TOP_DIR}/regressionSummary);	\
	done

# Include the common makefile
include $(COSIM_TOP_DIR)/common.make


