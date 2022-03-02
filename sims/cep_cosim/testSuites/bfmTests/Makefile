#//************************************************************************
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX License Identifier: BSD-2-Clause
#//
#// File Name:      
#// Program:        Common Evaluation Platform (CEP)
#// Description:    
#// Notes:          
#//
#//************************************************************************

# Causes a cleaning prior to running the test suite
STAND_ALONE 	?= 1

all: runAll

COSIM_TOP_DIR   	= $(strip $(shell cd ../..; pwd))
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))
TEST_SUITE_DIR		= $(strip $(shell cd .; pwd))
TEST_SUITE_NAME		= $(shell cd .; basename `pwd`)

# Include current test suite common.make
include ./common.make

TEST_LIST = 		\
	accessTest		\
	clintTest		\
	lockTest		\
	macroMix		\
	miscTests		\
	multiLock		\
	multiThread		\
	plicPrioIntr	\
	plicTest		\
	regTest			\
	scratchpadTest	\
	srotMemTest

# Tests yet to run/fix/debug
#	srotBadKeys
#	srotKeyTest
#	srotErrorTest


runAll: 
ifeq (${STAND_ALONE},1)
	make cleanAll
	make buildLibs
endif
	@for i in ${TEST_LIST}; do 					\
		(cd ${TEST_SUITE_DIR}/$${i}; make);		\
	done

summary:
	@date > ${TEST_SUITE_DIR}/testSuiteSummary
	@for i in ${TEST_LIST}; do				\
		cat ${TEST_SUITE_DIR}/$${i}/status | sort | tee -a testSuiteSummary;	\
	done

