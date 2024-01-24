#************************************************************************
# Copyright 2024 Massachusetts Institute of Technology
# SPDX short identifier: BSD-3-Clause
#
# File Name:      Makefile
# Program:        Common Evaluation Platform (CEP)
# Description:    Top Level Makefile for CEP CoSim
# Notes:          
#
#************************************************************************

# Without the following, RHEL7 does not execute the simulation process properly
.NOTPARALLEL:

COSIM_TOP_DIR   	= $(strip $(shell cd .; pwd))
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))

# Each test suite will set its own values
DUT_SIM_MODE		= BFM
ELF_MODE   			= LOCAL

default: usage

# Tests to run as part of the default build target
TEST_SUITES  =  	bareMetalTests	\
					bfmTests		\
					isaTests

# Run tests for all members of the test group
runAll: 
	@for i in ${TEST_SUITES}; do											\
		(cd ${COSIM_TOP_DIR}/testSuites/$${i}; make cleanSuite runAll); 	\
	done

# Print summary
summary: .force
	@date > ${COSIM_TOP_DIR}/regressionSummary
	@for i in ${TEST_SUITES}; do								\
		(cd ${COSIM_TOP_DIR}/testSuites/$${i}; make -s summary | sort | tee -a ${COSIM_TOP_DIR}/regressionSummary);	\
	done

# Allow for createISATests and removeISATests to be run from the root CEP sim directory
createISATests:
	make -C $(COSIM_TOP_DIR)/testSuites/isaTests $@
removeISATests:
	make -C $(COSIM_TOP_DIR)/testSuites/isaTests $@

# Include the common makefile
include $(COSIM_TOP_DIR)/common.make