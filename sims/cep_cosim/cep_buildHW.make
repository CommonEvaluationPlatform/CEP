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

# BFM
ifeq "$(findstring BFM,${DUT_SIM_MODE})" "BFM"
DUT_VLOG_ARGS 			+= +define+BFM_MODE

# Bare Metal
else ifeq "$(findstring BARE,${DUT_SIM_MODE})" "BARE"
DUT_VLOG_ARGS           += +define+BARE_MODE
RISCV_WRAPPER           = ./riscv_wrapper.elf

else
ERROR_MESSAGE			= "DUT_SIM_MODE=${DUT_SIM_MODE} is either not supported or please check spelling"
endif

# Define DPI if enabled
ifeq (${USE_DPI},1)
DUT_VLOG_ARGS           += +define+USE_DPI
endif

# 
BARE_SRC_DIR    		= ${SIM_DIR}/drivers/bare

# Variables related to the RISCV Toolset (RISCV must already be defined)
RISCV_GCC         		:= ${RISCV}/bin/riscv64-unknown-elf-gcc
RISCV_OBJDUMP     		:= ${RISCV}/bin/riscv64-unknown-elf-objdump
RISCV_HEXDUMP     		= /usr/bin/hexdump
RISCV_AR          		:= ${RISCV}/bin/riscv64-unknown-elf-gcc-ar
RISCV_RANLIB      		:= ${RISCV}/bin/riscv64-unknown-elf-gcc-ranlib

# Flags related to RISCV Virtual Tests
RISCV_VIRT_CFLAGS  		+= -march=rv64g -mabi=lp64 -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -DENTROPY=0xdb1550c -static 
RISCV_VIRT_LFLAGS  		+= -T${XX_SIM_DIR}/drivers/virtual/link.ld
RISCV_VIRT_CFILES  		+= ${XX_SIM_DIR}/drivers/virtual/*.c ${XX_SIM_DIR}/drivers/virtual/multi_entry.S 
RISCV_VIRT_INC     		+= -I${XX_SIM_DIR}/drivers/virtual -I${RISCV_TEST_DIR}/isa/macros/scalar 

# use the one build during verilog generation
RISCV_BARE_BOOT_DIR     := ${REPO_TOP_DIR}/hdl_cores/freedom/builds/vc707-u500devkit
RISCV_BARE_BOOT_ROM     := sdboot_fpga_sim.hex

%.hex: ${INC_DIR}/cep_adrMap.h %.c
	(cd ${RISCV_BARE_BOOT_DIR}; make clean; make;)


COSIM_TB_TOP_MODULE		:= cep_tb
COSIM_TB_TOP_FILE		:= ${DVT_DIR}/${COSIM_TB_TOP_MODULE}.v
COSIM_HW_FILELIST		:= ${DUT_COMMON_FILES} ${FREEDOM_FILES} ${RISCV_FILES} ${DUT_XILINX_FILES} ${DUT_XILINX_TOP_FILE}			
COSIM_DUT_MODULE	  	:= ${DUT_XILINX_TOP_MODULE}
COSIM_DUT_OPT_MODULE	:= ${DUT_XILINX_TOP_MODULE}_opt	
COSIM_DUT_VOPT_ARGS	  	+= +acc -64 +nolibcell +nospecify +notimingchecks
COSIM_DUT_VLOG_ARGS		+= +acc -64 -sv +define+RANDOMIZE_MEM_INIT+RANDOMIZE_REG_INIT+RANDOM="1'b0"
COSIM_DUT_VSIM_ARGS		+= -64 -warning 3363 -warning 3053 -warning 8630

SEARCH_DIR_LIST			:= 	${DVT_DIR} \
							${CHIPYARD_BLD_DIR} \
							${BHV_DIR}

INCDIR_LIST				:= ${SEARCH_DIR_LIST}

CHIPYARD_TOP_FILE_bfm	:= ${CHIPYARD_BLD_DIR}/${CHIPYARD_LONG_NAME}_bfm.v
CHIPYARD_TOP_FILE_bare	:= ${CHIPYARD_BLD_DIR}/${CHIPYARD_LONG_NAME}_bare.v

# Create a BFM compatible verion of the CHIPYARD_TOP_FILE
${CHIPYARD_TOP_FILE_bfm}: ${CHIPYARD_TOP_FILE}
	echo "\`include \"config.v\"" > ${CHIPYARD_TOP_FILE_bfm}
	sed -e 's/RocketTile tile/RocketTile_beh tile/g' ${CHIPYARD_TOP_FILE} >> ${CHIPYARD_TOP_FILE_bfm}
	touch $@

# Create a BARE compatible version of the CHIPYARD_TOP_FILE
${CHIPYARD_TOP_FILE_bare}: ${CHIPYARD_TOP_FILE}
	echo "\`include \"config.v\"" > ${CHIPYARD_TOP_FILE_bare}
	touch $@

.PHONY: filelist
filelist:
	COSIM_FILE_LIST = $(shell cat ${CHIPYARD_SIM_TOP_BLACKBOXES})


# Use Auto generate makefile from vmake output else force a rebuild
DEPEND_MAKEFILE = ${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}.make

# if makefile is there derived from vmake, use it else force a rebuild
ifeq ($(wildcard $(DEPEND_MAKEFILE)),)
${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}: .force
	if test ! -d ${WORK_DIR}; then ${VLIB_CMD} ${WORK_DIR}; fi
	${VMAP_CMD} ${WORK_NAME} ${WORK_DIR}
	@echo "Force a make because file ${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}.make not detected"
	touch $@

${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}_VHDL_LIST: .force
	touch $@

${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}_OTHER_LIST: .force
	touch $@
else
include ${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}.make
endif

# Build Verilog and VHDL seperately to save time since VHDL takes a long time
ifeq (${MODELSIM},1)
${TEST_SUITE_DIR}/.buildVcom : ${VERILOG_DEFINE_LIST} ${SIM_DIR}/common.make ${MKFILE_DIR}/cep_buildChips.make  ${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}_VHDL_LIST 
	@for i in ${CEP_VHDL_FLIST}; do                        		\
		${VCOM_CMD} -work ${WORK_DIR} ${DUT_VCOM_ARGS} $$i;		\
	done
	touch $@


${TEST_SUITE_DIR}/.buildVlog : ${VERILOG_DEFINE_LIST} ${SIM_DIR}/common.make ${MKFILE_DIR}/cep_buildChips.make ${DUT_XILINX_TOP_FILE} ${TEST_SUITE_DIR}/${SIM_DEPEND_TARGET}_OTHER_LIST ${BHV_DIR}/ddr3.v
	$(RM) ${TEST_SUITE_DIR}/searchPaths_build
	@for i in ${SEARCH_DIR_LIST}; do                        			\
		echo "-y" $${i} >> ${TEST_SUITE_DIR}/searchPaths_build;			\
	done
	@for i in ${INCDIR_LIST}; do                            			\
		echo "+incdir+"$${i} >> ${TEST_SUITE_DIR}/searchPaths_build;    		\
	done
	${VLOG_CMD} -work ${WORK_DIR} -f ${TEST_SUITE_DIR}/searchPaths_build +libext+.v +libext+.sv ${TEST_SUITE_DIR}/config.v ${DUT_VLOG_ARGS} +define+MODELSIM -incr ${DUT_VERILOG_FLIST} ${DUT_XILINX_TOP_TB}
	touch $@
endif 

#
# Now do the optimization after vlog and vcom
# make sure vlog is done first!!
# after that auto-generate the dependencies if there is any change
#
ifeq (${CADENCE},0)
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.is_checked ${TEST_SUITE_DIR}/.buildVlog ${TEST_SUITE_DIR}/.buildVcom ${RISCV_BARE_BOOT_DIR}/${RISCV_BARE_BOOT_ROM}
	${VOPT_CMD} -work ${WORK_DIR} ${DUT_VOPT_ARGS} ${WORK_DIR}.${DUT_MODULE} -o ${DUT_OPT_MODULE}
	(cd ${TEST_SUITE_DIR}; ${VMAKE_CMD} ${WORK_NAME} > ${TEST_SUITE_DIR}/.vmake_out; ${MKDEPEND} ${TEST_SUITE_DIR}/.vmake_out ${TEST_SUITE_DIR} ${SIM_DEPEND_TARGET} )
	touch $@
else
${TEST_SUITE_DIR}/_info: ${TEST_SUITE_DIR}/.is_checked ${TEST_SUITE_DIR}/.cadenceBuild ${RISCV_BARE_BOOT_DIR}/${RISCV_BARE_BOOT_ROM}
	touch $@
endif

buildSim: .force ${TEST_SUITE_DIR}/_info 
