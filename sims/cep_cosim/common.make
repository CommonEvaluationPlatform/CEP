#--------------------------------------------------------------------------------------
# Copyright 2024 Massachusetts Institute of Technology
# SPDX short identifier: BSD-3-Clause
#
# File Name:      common.make
# Program:        Common Evaluation Platform (CEP)
# Description:    Top level common.make for CEP Cosimulation
# Notes:          
#
#--------------------------------------------------------------------------------------

# Without the following, RHEL7 does not execute the simulation process properly
.NOTPARALLEL:

# Capture the operating system for some downstream decisions
OPERATING_SYSTEM 			:= $(shell hostnamectl | grep Operating | xargs)

# Avoid redundant inclusions of common.make
ifndef $(COMMON_MAKE_CALLED)
COMMON_MAKE_CALLED			= 1

# RISCV *must* be defined (while BFM mode does not use RISCV executables, the SW process builds EVERYTHING, including RISCV)
# not require if all you are doing is cleaning
ifeq "$(findstring clean,${MAKECMDGOALS})" ""
ifndef RISCV
$(error CEP_COSIM: RISCV is unset.  You must set RISCV yourself, or through the Chipyard auto-generated env file)
endif
endif 

# Set the default tool based on the OS Distro.  This can be override from the command line
ifneq (, $(shell hostnamectl | grep "Ubuntu"))
	MODELSIM        		?= 1
	CADENCE 				?= 0
else ifneq (, $(shell hostnamectl | grep "Red Hat"))
	MODELSIM        		?= 0
	CADENCE 				?= 1
else
	MODELSIM        		?= 1
	CADENCE 				?= 0
endif

# The following flags / variables can be overridden by lower level makefiles or the command line
NOWAVE          			?= 1
TL_CAPTURE      			?= 0
OPENOCD_ENABLE				?= 0
BYPASS_PLL                  ?= 0
DISABLE_CHISEL_PRINTF		?= 1
BAREMETAL_PRINTF			?= none
COVERAGE					?= 0

# The following flags are defined here to support the eventual enablement of legacy functionality
override PROFILE   			= 0
override USE_GDB  			= 0

# Currently only MODELSIM (Questasim) and CADENCE (XCellium) are supported
# The following check ensures one and only one is set
ifeq (${CADENCE},1)
MODELSIM       				= 0
else ifeq (${MODELSIM},1)
CADENCE        				= 0
else
$(error "CEP_COSIM: Only MODELSIM (QuestaSim) and CADENCE (XCellium) are currently supported")
endif

# Perform DUT_SIM_MODE Check
ifeq "$(findstring BFM,${DUT_SIM_MODE})" "BFM"
override DUT_SIM_MODE = BFM_MODE
else ifeq "$(findstring BARE,${DUT_SIM_MODE})" "BARE"
override DUT_SIM_MODE = BARE_MODE
else
$(error CEP_COSIM: ${DUT_SIM_MODE} is invalid)
endif

# Perform BAREMETAL_PRINTF check
ifeq "$(findstring libgloss,${BAREMETAL_PRINTF})" "libgloss"
override BAREMETAL_PRINTF = libgloss
else ifeq "$(findstring kputc,${BAREMETAL_PRINTF})" "kputc"
override BAREMETAL_PRINTF = kputc
else
override BAREMETAL_PRINTF = none
endif

# If OpenOCD is enabled, it should be installed
ifeq (${OPENOCD_ENABLE},1)
ifeq (,$(shell which openocd))
$(error OpenOCD enabled in CEP Co-Simulation environment, but openocd is not installed)
else
OPENOCD_VERSION := $(shell openocd --version 2>&1 | head -1 | cut -d' ' -f4)
endif
endif

# Validate the Chipyard verilog has been built by looking for the generated makefile
# This is not required if the current make target is riscv_wrapper, riscv_wrapper_sd_write, or one of the cleans
ifeq "$(findstring riscv_wrapper,${MAKECMDGOALS})" ""
ifeq "$(findstring clean,${MAKECMDGOALS})" ""
ifeq (,$(wildcard $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make))
$(error "CEP_COSIM: CHIPYARD_BUILD_INFO.make does not exist. run make -f Makefile.chipyard in $(REPO_TOP_DIR)")
endif
endif
endif

# If the file exists, then include it
ifneq (,$(wildcard $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make))
include $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make
endif


# Override the ASIC mode based on inferrence from the CHIPYARD_SUB_PROJECT
ifeq "$(findstring asic,${CHIPYARD_SUB_PROJECT})" "asic"
override ASIC_MODE 			= 1
else
override ASIC_MODE 			= 0
endif	

# The following DEFINES control how the software is
# compiled and if will be overriden by lower level
# Makefiles as needed.

# Set some default flag values
RISCV_TESTS 				?= 0
VIRTUAL_MODE				?= 0
RANDOMIZE     				?= 1
UPDATE_INFO   				?= 1
TEST_INFO     				?= testHistory.txt

# Misc. variable definitions
WORK_DIR        			:= ${TEST_SUITE_DIR}/${TEST_SUITE_NAME}_work
COSIM_COVERAGE_PATH			:= ${TEST_SUITE_DIR}/coverage

# Additional Co-Simulation Paths
SHR_DIR						:= ${COSIM_TOP_DIR}/share
PLI_DIR						:= ${COSIM_TOP_DIR}/pli
DVT_DIR         			:= ${COSIM_TOP_DIR}/dvt
DRIVERS_DIR					:= ${COSIM_TOP_DIR}/drivers
LIB_DIR						:= ${COSIM_TOP_DIR}/lib

# More variables and paths
V2C_TAB_FILE				:= ${PLI_DIR}/v2c.tab
BUILD_HW_MAKEFILE			:= ${COSIM_TOP_DIR}/cep_buildHW.make
BUILD_SW_MAKEFILE			:= ${COSIM_TOP_DIR}/cep_buildSW.make
CADENCE_MAKE_FILE 			:= ${COSIM_TOP_DIR}/cadence.make
V2C_LIB            			:= ${LIB_DIR}/v2c_lib.a
VPP_LIB 					:= ${LIB_DIR}/libvpp.so
VPP_SV_LIB 					:= ${LIB_DIR}/libvpp
RISCV_LIB 					:= ${LIB_DIR}/libriscv.a
BIN_DIR 					:= ${COSIM_TOP_DIR}/bin

# Variables related to build the RISC-V ISA tests
ISA_SUITE_DIR				:= ${COSIM_TOP_DIR}/testSuites/isaTests
ISA_TEST_TEMPLATE 			:= ${ISA_SUITE_DIR}/testTemplate
RISCV_TEST_DIR 				:= ${REPO_TOP_DIR}/toolchains/riscv-tools/riscv-tests

# Pointers to various binaries
# With Chipyard 1.8+, which installs depdencies via conda, pointing these
# binaries is needed until libcrypto++ can be installed via conda
# g++ is taken from the conda environment
ifneq (, $(shell hostnamectl | grep "Red Hat"))
	DEVTOOLSET				= /opt/rh/devtoolset-7/root/usr/bin
	GCC     				= ${DEVTOOLSET}/g++
	AR 						= ${DEVTOOLSET}/ar
	RANLIB  				= ${DEVTOOLSET}/ranlib
else
	GCC     				= /usr/bin/g++
	AR 						= /usr/bin/ar
	RANLIB  				= /usr/bin/ranlib
endif
LD 							= ${GCC}
VPP_CMD						= ${BIN_DIR}/vpp.pl
V2C_CMD						= ${BIN_DIR}/v2c.pl

#--------------------------------------------------------------------------------------
# To detect if any important flags have changed since last run
#--------------------------------------------------------------------------------------
PERSUITE_CHECK = ${TEST_SUITE_DIR}/.PERSUITE_${DUT_SIM_MODE}_${NOWAVE}_${PROFILE}_${COVERAGE}_${DISABLE_CHISEL_PRINTF}_${BAREMETAL_PRINTF}_${TL_CAPTURE}_${USE_GDB}_${BYPASS_PLL}

${PERSUITE_CHECK}: .force
	@if test ! -f ${PERSUITE_CHECK}; then rm -f ${TEST_SUITE_DIR}/.PERSUITE_*; touch ${PERSUITE_CHECK}; fi
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Provide some status of the user contronable parameters
#--------------------------------------------------------------------------------------
sim_info:
	@echo ""
	@echo "CEP_COSIM: ----------------------------------------------------------------------"
	@echo "CEP_COSIM:        Common Evaluation Platform Co-Simulation Environment           "
	@echo "CEP_COSIM: ----------------------------------------------------------------------"
	@echo "CEP_COSIM:"
	@echo "CEP_COSIM: ${OPERATING_SYSTEM}"
ifeq (${ASIC_MODE}, 1)
	@echo "CEP_COSIM: Running AISC test with the following variables:"
else
	@echo "CEP_COSIM: Running non-ASIC test with the following variables:"
endif
	@echo "CEP_COSIM:   RISCV                  = $(RISCV))"
ifeq (${MODELSIM},1)
	@echo "CEP_COSIM:   QUESTASIM_PATH         = ${QUESTASIM_PATH}"
else ifeq (${CADENCE},1)
	@echo "CEP_COSIM:   VMGR_PATH              = ${VMGR_PATH}"
	@echo "CEP_COSIM:   XCELIUM_INSTALL        = ${XCELIUM_INSTALL}"
endif
	@echo "CEP_COSIM:   MODELSIM               = $(MODELSIM)"
	@echo "CEP_COSIM:   CADENCE                = $(CADENCE)"
	@echo "CEP_COSIM:   DUT_SIM_MODE           = ${DUT_SIM_MODE}"
	@echo "CEP_COSIM:   RISCV_TESTS            = ${RISCV_TESTS}"
	@echo "CEP_COSIM:   NOWAVE                 = ${NOWAVE}"
	@echo "CEP_COSIM:   PROFILE                = ${PROFILE}"
	@echo "CEP_COSIM:   COVERAGE               = ${COVERAGE}"
	@echo "CEP_COSIM:   USE_GDB                = ${USE_GDB}"
	@echo "CEP_COSIM:   TL_CAPTURE             = ${TL_CAPTURE}"
	@echo "CEP_COSIM:   VIRTUAL_MODE           = ${VIRTUAL_MODE}"
	@echo "CEP_COSIM:   BYPASS_PLL             = ${BYPASS_PLL}"
	@echo "CEP_COSIM:   DISABLE_CHISEL_PRINTF  = ${DISABLE_CHISEL_PRINTF}"
	@echo "CEP_COSIM:   BAREMETAL_PRINTF       = ${BAREMETAL_PRINTF}"
	@echo "CEP_COSIM:   OPENOCD_ENABLE         = ${OPENOCD_ENABLE}"
ifeq (${OPENOCD_ENABLE},1)
	@echo "CEP_COSIM:   OpenOCD Version        = $(OPENOCD_VERSION)"
endif
	@echo ""
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Include additional makefiles as needed (Cadence support has been moved to ${BUILD_HW_MAKEFILE}
#--------------------------------------------------------------------------------------
include ${BUILD_HW_MAKEFILE}
include ${BUILD_SW_MAKEFILE}
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Variable and Build target tasked with running the simulation
#
# ${VSIM_CMD_LINE} is set in the ${BUILD_HW_MAKEFILE} makefile based on simulator type
#--------------------------------------------------------------------------------------
MY_TEST = $(shell grep "\.v\|\.sv" ${COSIM_BUILD_LIST})

ifeq (${DUT_SIM_MODE},BARE_MODE)
.vrun_flag: sim_info ${LIB_DIR}/.buildLibs c_dispatch ${TEST_SUITE_DIR}/_info ${VSIM_DO_FILE} ${RISCV_WRAPPER_IMG} ${COMMON_DEPENDENCIES}
else
.vrun_flag: sim_info ${LIB_DIR}/.buildLibs c_dispatch ${TEST_SUITE_DIR}/_info ${VSIM_DO_FILE} ${COMMON_DEPENDENCIES}
endif

ifeq (${COVERAGE},1)
	@if test ! -d ${COSIM_COVERAGE_PATH}; then	\
		mkdir  ${COSIM_COVERAGE_PATH};			\
	fi
endif

# It is important to note that the arguments here are being passed to the ${VPP_CMD} external script and thus ALL of these arguments are required
# This line is subordinate to the .vrun_flag build target
	${VPP_CMD} ${TEST_DIR}/c_dispatch ${RANDOMIZE} ${UPDATE_INFO} ${TEST_INFO} ${USE_GDB} ${SIMULATION_LOGFILE} ${COVERAGE} \"${VSIM_CMD_LINE}\"
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Moselsim coverage related build targets
#--------------------------------------------------------------------------------------
merge::
ifeq (${MODELSIM},1)
	@if test -d ${COSIM_COVERAGE_PATH}; then	\
		(cd ${COSIM_COVERAGE_PATH}; ${VCOVER_CMD} merge -out ${TEST_SUITE}.ucdb ${COSIM_COVERAGE_PATH}/*.ucdb;) \
	fi
endif

# use "coverage open <file>.ucdb" under vsim to open and view
MODELSIM_TOP_COVERAGE  = ${COSIM_TOP_DIR}/coverage
MODELSIM_COV_DO_SCRIPT = ${COSIM_TOP_DIR}/modelsim_coverage.do

mergeAll:: .force
ifeq (${MODELSIM},1)
	@if test ! -d ${MODELSIM_TOP_COVERAGE}; then	\
	   mkdir  ${MODELSIM_TOP_COVERAGE};		\
	fi
	@rm -rf ${MODELSIM_TOP_COVERAGE}/*
	@for i in ${TEST_GROUP}; do	\
	   (cd $${i}; make merge; cp coverage/$${i}.ucdb ${MODELSIM_TOP_COVERAGE}/.);	\
	done
	@(cd ${MODELSIM_TOP_COVERAGE};  ${VSIM_CMD} -64 -do ${MODELSIM_COV_DO_SCRIPT})
endif
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Misc build targets
#--------------------------------------------------------------------------------------
.PHONY: clean cleanTest cleanTestDo cleanSuite cleanLib cleanComplete cleanAll

clean: cleanTest cleanSuite cleanLib

# isaTests have their executables built seperately, so the cleanTest behavior needs to be different
# (.img, elf, .dump, and .hex need to be kept)
# Clean test only makes sense when run within a test directory
cleanTest:
ifneq (,$(TEST_DIR))
ifeq (${TEST_SUITE_NAME}, isaTests)
	-rm -f ${TEST_DIR}/*.o ${TEST_DIR}/*.bobj
	-rm -f ${TEST_DIR}/*.wlf
	-rm -f ${TEST_DIR}/*history
	-rm -f ${TEST_DIR}/*.log
	-rm -f ${TEST_DIR}/wlf*
	-rm -f ${TEST_DIR}/c_dispatch
	-rm -f ${TEST_DIR}/*.KEY
	-rm -f ${TEST_DIR}/testHistory.txt
	-rm -f ${TEST_DIR}/transcript
	-rm -f ${TEST_DIR}/status
	-rm -f ${TEST_DIR}/*.vstf
	-rm -f ${TEST_DIR}/xrun.key 
	-rm -f ${TEST_DIR}/imp.h 
	-rm -f ${TEST_DIR}/*.trn
	-rm -f ${TEST_DIR}/*.dsn 
	-rm -f ${TEST_DIR}/*.err
	-rm -f ${TEST_DIR}/*.o
	-rm -rf ${TEST_DIR}/.simvision
	-rm -rf ${TEST_DIR}/.bpad
else ifeq (${TEST_NAME}, debugTest)
	-rm -f ${TEST_DIR}/*.o ${TEST_DIR}/*.bobj
	-rm -f ${TEST_DIR}/*.wlf
	-rm -f ${TEST_DIR}/*history
	-rm -f ${TEST_DIR}/*.log
	-rm -f ${TEST_DIR}/wlf*
	-rm -f ${TEST_DIR}/c_dispatch
	-rm -f ${TEST_DIR}/*.KEY
	-rm -f ${TEST_DIR}/testHistory.txt
	-rm -f ${TEST_DIR}/transcript
	-rm -f ${TEST_DIR}/status
	-rm -f ${TEST_DIR}/*.vstf
	-rm -f ${TEST_DIR}/xrun.key 
	-rm -f ${TEST_DIR}/imp.h 
	-rm -f ${TEST_DIR}/*.trn
	-rm -f ${TEST_DIR}/*.dsn 
	-rm -f ${TEST_DIR}/*.err
	-rm -f ${TEST_DIR}/*.o
	-rm -rf ${TEST_DIR}/.simvision
	-rm -rf ${TEST_DIR}/.bpad
else
	-rm -f ${TEST_DIR}/*.o ${TEST_DIR}/*.bobj
	-rm -f ${TEST_DIR}/*.wlf
	-rm -f ${TEST_DIR}/*history
	-rm -f ${TEST_DIR}/*.dump
	-rm -f ${TEST_DIR}/*.elf
	-rm -f ${TEST_DIR}/*.hex
	-rm -f ${TEST_DIR}/*.log
	-rm -f ${TEST_DIR}/wlf*
	-rm -f ${TEST_DIR}/c_dispatch
	-rm -f ${TEST_DIR}/*.KEY
	-rm -f ${TEST_DIR}/testHistory.txt
	-rm -f ${TEST_DIR}/transcript
	-rm -f ${TEST_DIR}/status
	-rm -f ${TEST_DIR}/*.vstf
	-rm -f ${TEST_DIR}/xrun.key 
	-rm -f ${TEST_DIR}/imp.h 
	-rm -f ${TEST_DIR}/*.trn
	-rm -f ${TEST_DIR}/*.dsn 
	-rm -f ${TEST_DIR}/*.err
	-rm -f ${TEST_DIR}/*.o
	-rm -rf ${TEST_DIR}/.simvision
	-rm -rf ${TEST_DIR}/.bpad
	-rm -f ${TEST_DIR}/*.img
endif
else
	@echo "CEP_COSIM: cleanTest not run"
endif

cleanDo:
ifneq (,$(TEST_DIR))
	-rm -f ${TEST_DIR}/*.do
endif

# Clean suite only make sense when in a testSuite or inidividual test directory
cleanSuite:
ifneq (,$(TEST_SUITE_DIR))
	-rm -f ${TEST_SUITE_DIR}/.cosim_build_list
	-rm -rf ${TEST_SUITE_DIR}/*_work
	-rm -f ${TEST_SUITE_DIR}/.PERSUITE*
	-rm -f ${TEST_SUITE_DIR}/.buildVlog
	-rm -f ${TEST_SUITE_DIR}/_info
	-rm -rf ${TEST_SUITE_DIR}/xcelium.d
	-rm -rf ${TEST_SUITE_DIR}/testSuiteSummary
	-rm -rf ${TEST_SUITE_DIR}/.cadenceBuild
	@for i in ${TEST_LIST}; do 							\
		(if [ -d ${TEST_SUITE_DIR}/$${i} ]; then cd ${TEST_SUITE_DIR}/$${i}; make cleanTest; fi)	\
	done
else
	@echo "CEP_COSIM: cleanSuite not run"
endif

cleanLib:
	-rm -f ${V2C_H_FILE_LIST}
	-rm -rf ${LIB_DIR}/*
	-rm -rf ${LIB_DIR}/.buildLibs
	
# cleanAll needs to be run from COSIM_TOP_DIR, so the makefile
# will change there if necessary
cleanAll:
ifneq ($(strip $(shell pwd)), ${COSIM_TOP_DIR})
	(cd ${COSIM_TOP_DIR}; make cleanAll)
else
	@for i in ${TEST_SUITES}; do 									\
		(cd ${COSIM_TOP_DIR}/testSuites/$${i}; make cleanSuite); 	\
	done
	-rm -f ${COSIM_TOP_DIR}/regressionSummary
	@make cleanLib
endif

.force:
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Usage Summary
#--------------------------------------------------------------------------------------
define MAKE_USAGE_HELP_BODY
Usage summary:

User controlled options: (0 = not set, 1 = set)
  NOWAVE                  : Default: 1: When not set, waveforms will be captured based on the rules in vsim.do
  TL_CAPTURE              : Default: 0: Enables capturing of CEP core tilelink I/O as required by bareMetal macroMix tests and unit simulation
  BYPASS_PLL              : Default, 0: Applicable only when running the ASIC simulation, enables PLL bypass when set.
  DISABLE_CHISEL_PRINTF	  : Default, 1: When not set, enables instruction trace of the Rocket Cores (not applicable in BFM mode)
  BAREMETAL_PRINTF        : <libgloss | kputc | none>: When compiling bare metal executables (e.g., riscv_wrapper.cc), controls how console I/O is handled.
                            Options are:
                            - libgloss : (VERILATOR)  Use libgloss + UCB Host Target Interface.  Only applicable to simulating with Verilator.
                            - kputc    : (FPGA/COSIM) Use console (UART) I/O routines.  Naturally slow in co-simulation.  Must have for FPGA.
                            - none     : (ALL)        Default. Disable BAREMETAL I/O routines (any prints will effectively be routed to a /dev/null).
  DISK                    : Specifies the target device for the riscv_wrapper_sd_write target (e.g., DISK=/dev/sdd1)

Targets:
  default                 : Single test: run the test with default settings, Testsuite / CoSim: print usage steps
  usage, help             : Print this usage information.
  sim_info                : Display the default/current environment/variable settings used by the cosim.
  summary                 : Defined at the testSuite and cosim level.  Aggregates test status into a single file.
  runAll                  : Run all the tests below the current level (cosim or testSuite)
  riscv_wrapper           : Build the riscv_wrapper.elf/.img/.dump/.hex, but don't run the simulation
  riscv_wrapper_sd_write  : Write the riscv_wrapper.img to the device specified by DISK.

Unique isaTests Targets (recommend following instructions in $(COSIM_TOP_DIR)/README.md)  
  createISATests          : Create individual cosim tests from riscv-tests (Only ISA tests are supported).
  removeISATests          : Remove the cosim tests built from riscv-tests.

Clean Targets: 
  cleanTest               : Clean the current test (e.g., regTest).
  cleanSuite              : Clean the current test suite (e.g., bareMetal).
  cleanLib                : Clean the cosim generated libraries (e.g., <CEP_ROOT>/lib).
  clean                   : Runs the following clean targets: cleanTest, cleanSuite, cleanLib.
  cleanDo                 : Clean any .do files within the current test directory.
  cleanAll                : Clean all tests, all suites, and libraries.

Default make targets at the cosim and testSuite directory are "usage".  At the individual test level, the simulation will be run with default options.

endef

export MAKE_USAGE_HELP_BODY

help: 
	@echo "$$MAKE_USAGE_HELP_BODY"
usage:
	@echo "$$MAKE_USAGE_HELP_BODY"
info: 
	@echo "$$MAKE_USAGE_HELP_BODY"
#--------------------------------------------------------------------------------------

# ifdef $(COMMON_MAKE_CALLED)
endif 
