#//************************************************************************
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      Makefile
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Makefile for bareMetalTest test suite
#// Notes:          
#//
#//************************************************************************

all: runAll

COSIM_TOP_DIR   	= $(strip $(shell cd ../..; pwd))
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))
TEST_SUITE_DIR		= $(strip $(shell cd .; pwd))
TEST_SUITE_NAME		= $(shell cd .; basename `pwd`)

# Include current test suite common.make
include ./common.make


TEST_LIST 		= 		\
	accessTest 			\
	atomicOps			\
	cacheCoherence		\
	clintIntr 			\
	clintTest 			\
	csrTest 			\
	idcache_smc 		\
	lockfreeAtomic 		\
	lockTest 			\
	lrscOps 			\
	macroMix 			\
	miscTests 			\
	multiLock 			\
	plicPrioIntr 		\
	plicTest 			\
	regTest 			\
	srotMemTest

runAll: 
	make cleanAll
	@for i in ${TEST_LIST}; do 					\
		(cd ${TEST_SUITE_DIR}/$${i}; make);		\
	done

summary:
	@date > ${TEST_SUITE_DIR}/regressionSummary
	@for i in ${BARE_TEST_LIST}; do				\
		cat ${TEST_SUITE_DIR}/$${i}/status | tee -a regressionSummary;	\
	done




