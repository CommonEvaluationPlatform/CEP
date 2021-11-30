#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-2-Clause
#//
#// File Name:      cep_buildHW.make
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Co-Simulation makefile for CEP Hardware
#// Notes:          
#//
#//************************************************************************

# BFM Mode
ifeq "${DUT_SIM_MODE}" "BFM_MODE"
COSIM_VLOG_ARGS				+= +define+BFM_MODE

# Bare Metal Mode
else ifeq "${DUT_SIM_MODE}" "BARE_MODE"
COSIM_VLOG_ARGS         	+= +define+BARE_MODE
endif

# Virtual Mode
ifeq (${VIRTUAL_MODE},1)
COSIM_VLOG_ARGS 			+= +define+VIRTUAL_MODE
endif

# Default arguments
COSIM_VLOG_ARGS 			+= -incr +define+MODELSIM +libext+.v +libext+.sv

# Add switches based on environmental arguments
ifeq (${PROFILE},1)
COSIM_VSIM_ARGS				+= -autoprofile=${TEST_NAME}_profile
endif

ifeq (${COVERAGE},1)
COSIM_VSIM_ARGS				+= -coverage 
COSIM_VLOG_ARGS				+= +cover=sbceft +define+COVERAGE 
COSIM_VOPT_ARGS				+= +cover=sbceft
endif

# Disable wave capturing
ifeq (${NOWAVE},1)
COSIM_VLOG_ARGS				+= +define+NOWAVE
endif

# Use specified GCC vs Questasim builtin
COSIM_VSIM_ARGS	  			+= -cpppath ${GCC}

# Define DPI if enabled
ifeq (${USE_DPI},1)
COSIM_VLOG_ARGS 			+= +define+USE_DPI
endif


# CEP Testbench related defines
COSIM_TB_TOP_MODULE			:= cep_tb
COSIM_TB_TOP_FILE			:= ${DVT_DIR}/${COSIM_TB_TOP_MODULE}.v
COSIM_TB_CLOCK_PERIOD       := 5000
COSIM_TB_RESET_DELAY		:= 777.7
CHIPYARD_TOP_MODULE_OPT		:= ${CHIPYARD_TOP_MODULE}_opt

COSIM_VOPT_ARGS	  			+= +acc -64 +nolibcell +nospecify +notimingchecks
COSIM_VLOG_ARGS				+= +acc -64 -sv +define+CLOCK_PERIOD=${COSIM_TB_CLOCK_PERIOD} +define+RESET_DELAY=${COSIM_TB_RESET_DELAY} +define+COSIM_TB_TOP_MODULE=${COSIM_TB_TOP_MODULE}
COSIM_VSIM_ARGS				+= -64 -warning 3363 -warning 3053 -warning 8630

# Defines inherited from Chipyard
COSIM_VLOG_ARGS				+= +define+RANDOMIZE_MEM_INIT+RANDOMIZE_REG_INIT+RANDOM="1'b0"

COSIM_INCDIR_LIST			:= 	${TEST_SUITE_DIR} \
								${DVT_DIR} \
								${BHV_DIR} \
								${CHIPYARD_BLD_DIR}

CHIPYARD_TOP_FILE_bfm		:= ${CHIPYARD_BLD_DIR}/${CHIPYARD_LONG_NAME}_bfm.v
CHIPYARD_TOP_FILE_bare		:= ${CHIPYARD_BLD_DIR}/${CHIPYARD_LONG_NAME}_bare.v
COSIM_BUILD_LIST 			:= ${TEST_SUITE_DIR}/.cosim_build_list

# Create a BFM compatible verion of the CHIPYARD_TOP_FILE
${CHIPYARD_TOP_FILE_bfm}: .force ${CHIPYARD_TOP_FILE} 
	@rm -f $@
	@echo "\`include \"suite_config.v\"" > ${CHIPYARD_TOP_FILE_bfm}
	@sed -e 's/RocketTile tile/RocketTile_beh tile/g' ${CHIPYARD_TOP_FILE} >> ${CHIPYARD_TOP_FILE_bfm}
	@touch $@

# Create a BARE compatible version of the CHIPYARD_TOP_FILE
${CHIPYARD_TOP_FILE_bare}: .force ${CHIPYARD_TOP_FILE}
	@rm -f $@
	@echo "\`include \"suite_config.v\"" > ${CHIPYARD_TOP_FILE_bare}
	@touch $@

# Create an ordered list of SystemVerilog/Verilog files to compile

# BFM Mode
ifeq "$(findstring BFM,${DUT_SIM_MODE})" "BFM"
${COSIM_BUILD_LIST}: ${COSIM_TOP_DIR}/cep_buildHW.make .force
	@rm -f ${COSIM_BUILD_LIST}
	@for i in ${COSIM_INCDIR_LIST}; do \
		echo "+incdir+"$${i} >> ${COSIM_BUILD_LIST}; \
	done
	@for i in $(shell ls -x ${BHV_DIR}/*.{v,sv} 2>/dev/null); do \
		echo $${i} >> ${COSIM_BUILD_LIST}; \
	done
	@cat ${CHIPYARD_SIM_TOP_BLACKBOXES} >> ${COSIM_BUILD_LIST}
	@echo "" >> ${COSIM_BUILD_LIST}
	@cat ${CHIPYARD_SIM_FILES} >> ${COSIM_BUILD_LIST}
	@echo ${CHIPYARD_TOP_SMEMS_FILE} >> ${COSIM_BUILD_LIST}
	@echo ${CHIPYARD_TOP_FILE_bfm} >> ${COSIM_BUILD_LIST}
	@echo ${COSIM_TB_TOP_FILE} >> ${COSIM_BUILD_LIST}
else
# Bare Metal Mode
${COSIM_BUILD_LIST}: ${COSIM_TOP_DIR}/cep_buildHW.make .force
	@rm -f ${COSIM_BUILD_LIST}
	@for i in ${COSIM_INCDIR_LIST}; do \
		echo "+incdir+"$${i} >> ${COSIM_BUILD_LIST}; \
	done
	@for i in $(shell ls -x ${BHV_DIR}/*.{v,sv} 2>/dev/null); do \
		echo $${i} >> ${COSIM_BUILD_LIST}; \
	done
	@cat ${CHIPYARD_SIM_TOP_BLACKBOXES} >> ${COSIM_BUILD_LIST}
	@echo "" >> ${COSIM_BUILD_LIST}
	@cat ${CHIPYARD_SIM_FILES} >> ${COSIM_BUILD_LIST}
	@echo ${CHIPYARD_TOP_SMEMS_FILE} >> ${COSIM_BUILD_LIST}
	@echo ${CHIPYARD_TOP_FILE_bare} >> ${COSIM_BUILD_LIST}
	@echo ${COSIM_TB_TOP_FILE} >> ${COSIM_BUILD_LIST}
endif

# Modelsim only related steps
ifeq (${MODELSIM}, 1)
 
# When using Questasim, use the optimized module
COSIM_VLOG_ARGS += +define+CHIPYARD_TOP_MODULE=${CHIPYARD_TOP_MODULE_OPT} +define+CHIPYARD_TOP_MODULE_inst=${CHIPYARD_TOP_MODULE}_inst

# Compile all the Verilog and SystemVerilog for the CEP
${TEST_SUITE_DIR}/.buildVlog : ${CHIPYARD_TOP_FILE_bfm} ${CHIPYARD_TOP_FILE_bare} ${COSIM_BUILD_LIST} ${COSIM_TOP_DIR}/common.make ${COSIM_TOP_DIR}/cep_buildHW.make ${PERSUITE_CHECK}
	${VLOG_CMD} -work ${WORK_DIR} ${COSIM_VLOG_ARGS} -f ${COSIM_BUILD_LIST}
	touch $@

# Perform Questasim's optimization
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.buildVlog
	${VOPT_CMD} -work ${WORK_DIR} ${COSIM_VOPT_ARGS} ${WORK_DIR}.${CHIPYARD_TOP_MODULE} -o ${CHIPYARD_TOP_MODULE_OPT}
	touch $@
else

# When using Cadence's XCellium, use the original module name
COSIM_VLOG_ARGS += +define+CHIPYARD_TOP_MODULE=${CHIPYARD_TOP_MODULE}

# Cadence XCellium Steps
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.cadenceBuild
	touch $@
endif

