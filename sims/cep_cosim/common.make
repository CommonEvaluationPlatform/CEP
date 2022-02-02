#--------------------------------------------------------------------------------------
# Copyright 2021 Massachusetts Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      common.make
# Program:        Common Evaluation Platform (CEP)
# Description:    Top level common.make for CEP Cosimulation
# Notes:          
#
#--------------------------------------------------------------------------------------

# Avoid redundant inclusions of common.make
ifndef $(COMMON_MAKE_CALLED)
COMMON_MAKE_CALLED			= 1

# RISCV *must* be defined (while BFM mode does not use RISCV executables, the SW process builds EVERYTHING, including RISCV)
ifndef RISCV
$(error CEP_COSIM: RISCV is unset.  You must set RISCV yourself, or through the Chipyard auto-generated env file)
endif

# The following flags / variables can be overridden by lower level makefiles or the command line
MODELSIM        			?= 1
CADENCE 					?= 0
NOWAVE          			?= 0
PROFILE         			?= 0
COVERAGE        			?= 0
USE_GDB       				?= 0
TL_CAPTURE      			?= 0
BYPASS_PLL                  ?= 0
ASIC_MODE                   ?= 1

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


# Validate the Chipyard verilog has been build by looking for the generated makefile
ifeq (,$(wildcard $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make))
$(error "CEP_COSIM: CHIPYARD_BUILD_INFO.make does not exist. run make -f Makefile.chipyard in $(COSIM_TOP_DIR)")
endif

# Include the file that contains info about the chipyard build
include $(COSIM_TOP_DIR)/CHIPYARD_BUILD_INFO.make

# The following DEFINES control how the software is
# compiled and if will be overriden by lower level
# Makefiles as needed.

# Set some default flag values
SINGLE_THREAD 				= 0
VIRTUAL_MODE				= 0
RANDOMIZE     				= 1
UPDATE_INFO   				= 1
PASS_IS_TO_HOST				= 0;
TEST_INFO     				= testHistory.txt

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
VPP_LIB 					:= ${LIB_DIR}/libvpp.so
VPP_SV_LIB 					:= ${LIB_DIR}/libvpp
RISCV_LIB 					:= ${LIB_DIR}/riscv_lib.a
BIN_DIR 					:= ${COSIM_TOP_DIR}/bin
ISA_TEST_TEMPLATE 			:= ${TEST_SUITE_DIR}/testTemplate

# Points to the root directory of the riscv-test repo
RISCV_TEST_DIR 				:= ${REPO_TOP_DIR}/software/riscv-tests

# Pointers to various binaries
GCC     					= /usr/bin/g++
AR 							= /usr/bin/ar
RANLIB  					= /usr/bin/ranlib
LD 							= ${GCC}
VPP_CMD						= ${BIN_DIR}/vpp.pl
V2C_CMD						= ${BIN_DIR}/v2c.pl

#--------------------------------------------------------------------------------------
# To detect if any important flag has changed since last run
#--------------------------------------------------------------------------------------
PERSUITE_CHECK = ${TEST_SUITE_DIR}/.PERSUITE_${DUT_SIM_MODE}_${NOWAVE}_${PROFILE}_${COVERAGE}

${PERSUITE_CHECK}: .force
	@if test ! -f ${PERSUITE_CHECK}; then rm -f ${TEST_SUITE_DIR}/.PERSUITE_*; touch ${PERSUITE_CHECK}; fi
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Include additional makefiles as needed (Cadence support has been moved to ${BUILD_HW_MAKEFILE}
#--------------------------------------------------------------------------------------
include ${BUILD_HW_MAKEFILE}
include ${BUILD_SW_MAKEFILE}
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# Provide some status of the user contronable parameters
#--------------------------------------------------------------------------------------
sim_info:
	@echo ""
	@echo "CEP_COSIM: ----------------------------------------------------------------------"
	@echo "CEP_COSIM:        Common Evaluation Platform Co-Simulation Environment           "
	@echo "CEP_COSIM: ----------------------------------------------------------------------"
	@echo ""
	@echo " CEP_COSIM: Running with the following variables:"
	@echo " CEP_COSIM:   RISCV                  = $(RISCV))"
ifeq (${MODELSIM},1)
	@echo " CEP_COSIM:   QUESTASIM_PATH         = ${QUESTASIM_PATH}"
else ifeq (${CADENCE},1)
	@echo " CEP_COSIM:   VMGR_PATH              = ${VMGR_PATH}"
	@echo " CEP_COSIM:   XCELIUM_INSTALL        = ${XCELIUM_INSTALL}"
endif
	@echo " CEP_COSIM:   MODELSIM               = $(MODELSIM)"
	@echo " CEP_COSIM:   CADENCE                = $(CADENCE)"
	@echo " CEP_COSIM:   DUT_SIM_MODE           = ${DUT_SIM_MODE}"
	@echo " CEP_COSIM:   NOWAVE                 = ${NOWAVE}"
	@echo " CEP_COSIM:   PROFILE                = ${PROFILE}"
	@echo " CEP_COSIM:   COVERAGE               = ${COVERAGE}"
	@echo " CEP_COSIM:   USE_GDB                = ${USE_GDB}"
	@echo " CEP_COSIM:   TL_CAPTURE             = ${TL_CAPTURE}"
	@echo " CEP_COSIM:   VIRTUAL_MODE           = ${VIRTUAL_MODE}"
	@echo " CEP_COSIM:   SINGLE_THREAD          = ${SINGLE_THREAD}"
	@echo " CEP_COSIM:   BYPASS_PLL             = ${BYPASS_PLL}"
	@echo " CEP_COSIM:   ASIC_MODE              = ${ASIC_MODE}"
	@echo ""
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Variable and Build target tasked with running the simulation
#
# ${VSIM_CMD_LINE} is set in the ${BUILD_HW_MAKEFILE} makefile based on simulator type
#--------------------------------------------------------------------------------------
.vrun_flag: sim_info ${TEST_SUITE_DIR}/_info ${LIB_DIR}/.buildLibs ${VSIM_DO_FILE} c_dispatch ${RISCV_WRAPPER_ELF}
ifeq (${COVERAGE},1)
	@if test ! -d ${COSIM_COVERAGE_PATH}; then	\
		mkdir  ${COSIM_COVERAGE_PATH};		\
	fi
endif

# It is important to note that the arguments here are being passed to the ${VPP_CMD} external script and thus ALL of these arguments are required
# This line is subordinate to the .vrun_flag build target
	${VPP_CMD} ${TEST_DIR}/c_dispatch ${RANDOMIZE} ${UPDATE_INFO} ${TEST_INFO} ${USE_GDB} ${SIMULATION_LOGFILE} ${COVERAGE} \"${VSIM_CMD_LINE}\"
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Targets to support automatic generate of the ISA Tests
#--------------------------------------------------------------------------------------
makeIsaTest: ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump
	@echo "Done"


${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump : ${RISCV_TEST_DIR}/isa/${TEST_NAME}
	@if test ! -d ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}; then	\
		mkdir  ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}; \
	fi
	@cp -f ${ISA_TEST_TEMPLATE}/Makefile        ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@cp -f ${ISA_TEST_TEMPLATE}/*.h             ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@cp -f ${ISA_TEST_TEMPLATE}/c_module.cc     ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@rm -f ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
ifeq (${SINGLE_THREAD},1)
	@echo "#define SINGLE_THREAD_ONLY" >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifneq (${SINGLE_CORE_ONLY},)
	@echo "#define SINGLE_CORE_ONLY ${SINGLE_CORE_ONLY}" >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifeq (${VIRTUAL_MODE},1)
	@echo "#define MAX_TIMEOUT 200"    >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
	@echo "#define VIRTUAL_MODE"       >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
else
	@echo "#define MAX_TIMEOUT 200"    >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifeq (${PASS_IS_TO_HOST},1)
	@echo "#define PASS_IS_TO_HOST"    >> ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
	@cat ${ISA_TEST_TEMPLATE}/c_dispatch.cc >>        ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
	@cp -f ${RISCV_TEST_DIR}/isa/${TEST_NAME}      ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/riscv_wrapper.elf
	@cp -f ${RISCV_TEST_DIR}/isa/${TEST_NAME}.dump ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump
	@${BIN_DIR}/createPassFail.pl ${RISCV_TEST_DIR}/isa/${TEST_NAME}.dump ${TEST_SUITE_DIR}/${TEST_NAME}${SFX}/PassFail.hex
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
clean: cleanLocal

cleanLocal:
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
	
cleanLocalDo:
	-rm -f ${TEST_DIR}/*.do

cleanSuite:
	-rm -f ${TEST_SUITE_DIR}/.cosim_build_list
	-rm -rf ${TEST_SUITE_DIR}/*_work
	-rm -f ${TEST_SUITE_DIR}/.PERSUITE*
	-rm -f ${TEST_SUITE_DIR}/.buildVlog

cleanLib:
	-rm -f ${CHIPYARD_TOP_FILE_bfm}
	-rm -f ${CHIPYARD_TOP_FILE_bare}
	-rm -f ${CHIPYARD_TOP_SMEMS_FILE_sim}
	-rm -f ${V2C_H_FILE_LIST}
	-rm -rf ${LIB_DIR}/*
	-rm -rf ${LIB_DIR}/.buildLibs
	
cleanAll:
	-rm -f ${CHIPYARD_TOP_FILE_bfm}
	-rm -f ${CHIPYARD_TOP_FILE_bare}
	-rm -f ${CHIPYARD_TOP_SMEMS_FILE_sim}
	-rm -f ${COSIM_TOP_DIR}/testSuites/*/.cosim_build_list
	-rm -f ${COSIM_TOP_DIR}/testSuites/*/*/*.do
	-rm -rf ${COSIM_TOP_DIR}/testSuites/*/*_work
	-rm -f ${COSIM_TOP_DIR}/testSuites/*/.PERSUITE*
	-rm -f ${COSIM_TOP_DIR}/testSuites/*/.buildVlog
	-rm -f ${V2C_H_FILE_LIST}
	-rm -rf ${LIB_DIR}/*
	-rm -rf ${LIB_DIR}/.buildLibs
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*.bo* ${COSIM_TOP_DIR}/*/*/*/*.o*
	-rm -f ${COSIM_TOP_DIR}/*/*/*/c_dispatch ${COSIM_TOP_DIR}/*/*/*/*.log
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*.KEY ${COSIM_TOP_DIR}/*/*/*/testHistory.txt
	-rm -f ${COSIM_TOP_DIR}/*/*/*/status
	-rm -f ${COSIM_TOP_DIR}/*/*/_info
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*.wlf
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*history
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*dump
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*elf
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*hex
	-rm -f ${COSIM_TOP_DIR}/*/*/*/*vstf
	-rm -f ${COSIM_TOP_DIR}/*/*/*/wlf*
	-rm -f ${COSIM_TOP_DIR}/*/*/*/transcript
	-rm -f ${COSIM_TOP_DIR}/drivers/vectors/*
	-rm -f ${V2C_H_FILE_LIST}

# Use to force rebuilds for rules that include this dependency
.force:
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Usage Summary
#--------------------------------------------------------------------------------------
define MAKE_USAGE_HELP_BODY
Usage summary:
make [NOWAVE=0|1] [COVERAGE=0|1] [PROFILE=0|1] [USE_GDB=0|1] <all|summary|cleanAll|merge|usage>

Options:
  NOWAVE=1      : turn off wave capturing. Default is ON for interactive. OFF for regression
  USE_GDB=1     : run the test under "gdb" debugger. Default is OFF. Should only be used for interactive session.
  COVERAGE=1    : run the test with coverage capture enable. Default is OFF
  PROFILE=1     : run the test with profiling turn on. Default is OFF
  TL_CAPTURE=1  : turn on Title-Link comand sequence capturing to be used for BARE Metal (and Unit-level testbench)
  
Targets:
  all        : run the test. Default target (empty string = same as "all")
  summary    : print out regression summary (run at the top or suite directories.
  cleanAll   : clean up and force a rebuild of every thing
  merge      : merge coverage reports
  usage      : print this help lines

  see <common.make> for more options and targets

endef

export MAKE_USAGE_HELP_BODY

usage: sim_info
	@echo "$$MAKE_USAGE_HELP_BODY"
#--------------------------------------------------------------------------------------

# ifdef $(COMMON_MAKE_CALLED)
endif 