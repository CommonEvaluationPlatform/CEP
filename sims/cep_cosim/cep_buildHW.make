#--------------------------------------------------------------------------------------
# Copyright 2021 Massachusetts Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      cep_buildHW.make
# Program:        Common Evaluation Platform (CEP)
# Description:    Co-Simulation makefile for CEP Hardware
# Notes:          This file cannot be invoked by itself
#
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Common defines to pass to compiled verilog
#--------------------------------------------------------------------------------------

# BFM Mode
ifeq "${DUT_SIM_MODE}" "BFM_MODE"
COSIM_VLOG_ARGS				+= +define+BFM_MODE

# Bare Metal Mode
else ifeq "${DUT_SIM_MODE}" "BARE_MODE"
COSIM_VLOG_ARGS         	+= +define+BARE_MODE
endif

# Enable the DPI
ifeq (${USE_DPI},1)
COSIM_VLOG_ARGS 			+= +define+USE_DPI
endif

# Virtual Mode
ifeq (${VIRTUAL_MODE},1)
COSIM_VLOG_ARGS 			+= +define+VIRTUAL_MODE
endif

# Disable wave capturing
ifeq (${NOWAVE},1)
COSIM_VLOG_ARGS				+= +define+NOWAVE
endif
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Common steps and settings regardless of simulator
#--------------------------------------------------------------------------------------
COSIM_VLOG_ARGS 			+= +libext+.v +libext+.sv

# Use specified GCC vs Questasim builtin
COSIM_VSIM_ARGS	  			+= -cpppath ${GCC}

# CEP Testbench related defines
COSIM_TB_TOP_MODULE			:= cep_tb
COSIM_TB_TOP_MODULE_OPT		:= ${COSIM_TB_TOP_MODULE}_opt
COSIM_TB_TOP_FILE			:= ${DVT_DIR}/${COSIM_TB_TOP_MODULE}.sv
COSIM_TB_CLOCK_PERIOD       := 5000
COSIM_TB_RESET_DELAY		:= 777.7

COSIM_VLOG_ARGS				+= 	-sv \
								+define+CLOCK_PERIOD=${COSIM_TB_CLOCK_PERIOD} \
								+define+RESET_DELAY=${COSIM_TB_RESET_DELAY} \
								+define+COSIM_TB_TOP_MODULE=${COSIM_TB_TOP_MODULE} \
								+define+CHIPYARD_TOP_MODULE=${CHIPYARD_TOP_MODULE}

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

# BFM Mode (Chipyard generated TestDriver.v is explicitly exluded)
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
	@sed -i '/TestDriver.v/d' ${COSIM_BUILD_LIST}
else
# Bare Metal Mode (Chipyard generated TestDriver.v is explicitly exluded)
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
	@sed -i '/TestDriver.v/d' ${COSIM_BUILD_LIST}
endif
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Questasim only related items
#--------------------------------------------------------------------------------------
ifeq (${MODELSIM}, 1)
QUESTASIM_PATH				?= /opt/questa-2019.1/questasim/bin
VLOG_CMD					= ${QUESTASIM_PATH}/vlog
VCOM_CMD					= ${QUESTASIM_PATH}/vcom
VOPT_CMD					= ${QUESTASIM_PATH}/vopt
VSIM_CMD 					= ${QUESTASIM_PATH}/vsim
VLIB_CMD					= ${QUESTASIM_PATH}/vlib
VMAP_CMD					= ${QUESTASIM_PATH}/vmap
VMAKE_CMD					= ${QUESTASIM_PATH}/vmake
VCOVER_CMD					= ${QUESTASIM_PATH}/vcover
VSIM_DO_FILE				= ${TEST_DIR}/vsim.do

# Quick sanity check if vsim exists
ifeq (,$(shell which ${VSIM_CMD}))
$(error CEP_COSIM: vsim not found.  Check QUESTASIM_PATH)
endif

# Create default local vsim do file if not there: one with sim for interactive and one for regression
define VSIM_DO_BODY
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
#
# Procedure to turn on/off wave and continue
# they are called from inside Verilog
#
proc wave_on {} {
     echo "Enable logging";	
     log -ports -r /* ;
}

proc wave_off {} {
     echo "Stop logging"	
     nolog -all;
}
proc dump_coverage {} {
     echo "Dumping Coverage";
     coverage save ../coverage/${TEST_NAME}.ucdb
}
#
# just run
#
run -all;
#
# should never get here anyway!!
#
quit
endef

export VSIM_DO_BODY

${VSIM_DO_FILE}:
	@if test ! -f $@; then	\
	echo "$$VSIM_DO_BODY" > $@; \
	fi

COSIM_VLOG_ARGS 			+= +acc -64 -incr +define+MODELSIM
COSIM_VSIM_ARGS				+= -64 -warning 3363 -warning 3053 -warning 8630
COSIM_VOPT_ARGS	  			+= +acc -64 +nolibcell +nospecify +notimingchecks

# Enable coverage for Modelsim
ifeq (${COVERAGE},1)
COSIM_VLOG_ARGS				+= +cover=sbceft +define+COVERAGE 
COSIM_VSIM_ARGS				+= -coverage 
COSIM_VOPT_ARGS				+= +cover=sbceft
endif

# Add profiling
ifeq (${PROFILE},1)
COSIM_VSIM_ARGS				+= -autoprofile=${TEST_NAME}_profile
endif

# Compile all the Verilog and SystemVerilog for the CEP
${TEST_SUITE_DIR}/.buildVlog : ${CHIPYARD_TOP_FILE_bfm} ${CHIPYARD_TOP_FILE_bare} ${COSIM_BUILD_LIST} ${COSIM_TOP_DIR}/common.make ${COSIM_TOP_DIR}/cep_buildHW.make ${PERSUITE_CHECK}
	${VLOG_CMD} -work ${WORK_DIR} ${COSIM_VLOG_ARGS} -f ${COSIM_BUILD_LIST}
	touch $@

# Test build target
buildVlog: ${TEST_SUITE_DIR}/.buildVlog

# Perform Questasim's optimization
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.buildVlog
	${VOPT_CMD} -work ${WORK_DIR} ${COSIM_VOPT_ARGS} ${WORK_DIR}.${COSIM_TB_TOP_MODULE} -o ${COSIM_TB_TOP_MODULE_OPT}
	touch $@

# Establish the MODELSIM command line for running simulation (which will be override when operating in CADENCE mode)
VSIM_CMD_LINE = "${VSIM_CMD} -work ${WORK_DIR} -t 100ps -tab ${V2C_TAB_FILE} -pli ${VPP_LIB} -sv_lib ${VPP_SV_LIB} -do ${VSIM_DO_FILE} ${COSIM_VSIM_ARGS} ${WORK_DIR}.${COSIM_TB_TOP_MODULE_OPT} -batch -logfile ${TEST_DIR}/${TEST_NAME}_modelsim.log +myplus=0"

endif
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# Cadence only related items
#--------------------------------------------------------------------------------------
ifeq (${CADENCE}, 1)
VMGR_VERSION					?= VMANAGERAGILE20.06.001
XCELIUM_VERSION					?= XCELIUMAGILE20.09.001
VMGR_PATH 						:= /brewhouse/cad4/x86_64/Cadence/${VMGR_VERSION}
XCELIUM_INSTALL					:= /brewhouse/cad4/x86_64/Cadence/${XCELIUM_VERSION}
IMC_INSTALL 					:= ${VMGR_PATH}
MDV_XLM_HOME 					:= ${XCELIUM_INSTALL}
XRUN_CMD 						:= ${XCELIUM_INSTALL}/tools/bin/xrun
IMC_CMD  						:= ${IMC_INSTALL}/tools/bin/imc
SAHANLDER_FILE    				:= ${SHR_DIR}/sahandler.c

# Allow Value Parameters without default values
export CADENCE_ENABLE_AVSREQ_44905_PHASE_1 = 1

# Quick sanity check if xrun exists
ifeq (,$(shell which ${XRUN_CMD}))
$(error CEP_COSIM: xrun not found.  Check XCELIUM_INSTALL)
endif

# Add to PATH if they are not there yet
XCELIUM_IN_PATH					= $(shell echo $PATH | grep '$(XCELIUM_VERSION)')
IMC_IN_PATH						= $(shell echo $PATH | grep '$(VMGR_VERSION)')
ifeq ($(XCELIUM_IN_PATH),)
export PATH 					:= ${XCELIUM_INSTALL}/tools/bin:${XCELIUM_INSTALL}/tools/dfII/bin:${PATH}
endif
ifeq ($(IMC_IN_PATH),)
export PATH 					:= ${IMC_INSTALL}/tools/bin:${PATH}
endif

COSIM_VLOG_ARGS 				+=  -64bit -elaborate -ALLOWREDEFINITION -smartorder +define+CADENCE

# Enable coverage for Cadence
ifeq (${COVERAGE},1)
COSIM_VLOG_ARGS 				+= -covfile ${COSIM_TOP_DIR}/cadence_cov.ccf
COSIM_VSIM_ARGS 				+= -write_metrics -covoverwrite -covworkdir ${COSIM_COVERAGE_PATH} -covscope ${TEST_SUITE} -covtest ${TEST_NAME} 
endif

CAD_TOP_COVERAGE				?= ${COSIM_TOP_DIR}/cad_coverage
override COSIM_COVERAGE_PATH  	= ${TEST_SUITE_DIR}/cad_coverage

# Cadence build target
${TEST_SUITE_DIR}/.cadenceBuild : ${LIB_DIR}/.buildLibs ${CHIPYARD_TOP_FILE_bfm} ${CHIPYARD_TOP_FILE_bare} ${COSIM_BUILD_LIST} ${COSIM_TOP_DIR}/common.make ${COSIM_TOP_DIR}/cep_buildHW.make ${PERSUITE_CHECK}
	${XRUN_CMD} ${COSIM_VLOG_ARGS} -f ${COSIM_BUILD_LIST} -afile ${V2C_TAB_FILE} -sv_lib ${COSIM_TOP_DIR}/lib/libvpp.so -dpiimpheader imp.h -loadpli1 ${COSIM_TOP_DIR}/lib/libvpp.so:export -xmlibdirname ${TEST_SUITE_DIR}/xcelium.d -log ${TEST_DIR}/${TEST_NAME}_compile_xrun.log ${CADENCE_COV_COM_ARGS} ${SAHANLDER_FILE} -loadvpi ${TEST_SUITE_DIR}/xcelium.d/run.d/librun.so:boot
	touch $@

# Test build target
cadenceBuild: ${TEST_SUITE_DIR}/.cadenceBuild

# NOTE: double :: rule!!
merge::
ifeq (${CADENCE},1)
	@if test ! -d ${CAD_TOP_COVERAGE}; then   \
		mkdir  ${CAD_TOP_COVERAGE};   \
	fi
	@if test ! -d ${CAD_TOP_COVERAGE}/${TEST_SUITE}; then \
		mkdir  ${CAD_TOP_COVERAGE}/${TEST_SUITE}; \
	fi
	rm -rf ${CAD_TOP_COVERAGE}/${TEST_SUITE}/*
	mkdir  ${CAD_TOP_COVERAGE}/${TEST_SUITE}/merge
	@if test -d ${COSIM_COVERAGE_PATH}/${TEST_SUITE}; then  \
		echo "Merging Cadene coverage files under ${COSIM_COVERAGE_PATH} ..."; \
		${IMC_CMD}  -execcmd "config analysis.enable_partial_toggle -set true; merge ${COSIM_COVERAGE_PATH}/${TEST_SUITE}/* -overwrite -message 1 -out ${COSIM_COVERAGE_PATH} "; \
	fi 
	cp ${COSIM_COVERAGE_PATH}/*.ucm ${CAD_TOP_COVERAGE}/${TEST_SUITE}/.
	cp ${COSIM_COVERAGE_PATH}/*.ucd ${CAD_TOP_COVERAGE}/${TEST_SUITE}/merge/.
endif

mergeAll:: .force
ifeq (${CADENCE},1)
	@if test ! -d ${CAD_TOP_COVERAGE}; then \
		mkdir  ${CAD_TOP_COVERAGE};   \
	fi
	rm -rf ${CAD_TOP_COVERAGE}/*
	touch ${CAD_TOP_COVERAGE}/runFile.txt
	@for i in ${TEST_GROUP}; do \
		echo "./$${i}/*" >> ${CAD_TOP_COVERAGE}/runFile.txt; \
		(cd $${i}; make merge); \
	done  
	(cd ${CAD_TOP_COVERAGE}; ${IMC_CMD}  -execcmd "config analysis.enable_partial_toggle -set true;  merge -runfile ${CAD_TOP_COVERAGE}/runFile.txt -initial_model union_all -message 1 -out ${CAD_TOP_COVERAGE}/merge;")
endif

remerge:
	(cd ${CAD_TOP_COVERAGE}; rm -rf merge; ${IMC_CMD}  -execcmd "config analysis.enable_partial_toggle -set true;  merge -runfile ${CAD_TOP_COVERAGE}/runFile.txt -initial_model union_all -message 1 -out ${CAD_TOP_COVERAGE}/merge;")

# Dummy build target to ensure complete dependencies when simulating
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.cadenceBuild
	touch $@

# override the VPP command for Cadence tool
override VSIM_CMD_LINE = "${XRUN_CMD} -64bit -R -xmlibdirname ${TEST_SUITE_DIR}/xcelium.d  -afile ${V2C_TAB_FILE} -loadpli1 ${LIB_DIR}/libvpp.so -sv_lib ${LIB_DIR}/libvpp.so -loadvpi ${TEST_SUITE_DIR}/xcelium.d/run.d/librun.so:boot -log ${TEST_DIR}/${TEST_NAME}_sim_xrun.log ${CADENCE_COV_RUN_ARGS} "

endif	
#--------------------------------------------------------------------------------------



