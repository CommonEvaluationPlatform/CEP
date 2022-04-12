#************************************************************************
# Copyright 2022 Massachusets Institute of Technology
#
# File Name:      Makefile
# Program:        Common Evaluation Platform (CEP)
# Description:    Makefile for isaTests test suite
# Notes:          Depending on the test category, the following
#                 defines are added to a particular tests c_dispatch.cc:
#					MAX_TIMEOUT 		- Passes the timeout parameter
#                     to the thread via the seed parameter.  Used both
#                     in checking if the program is loaded and if it has
#                     completed execution.
#                   SINGLE_CORE_ONLY	- 
#					SINGLE_THREAD_ONLY	-
#					PASS_WRITETOHOST	- Somes tests are considered
#                     passed when they reach the write_tohost function
#					VIRTUAL_MODE		- Affects both compilation and
#					  runtime behavior.
#
#************************************************************************

# Causes a cleaning prior to running the test suite
STAND_ALONE 		?= 1

all: runAll

COSIM_TOP_DIR   	= $(strip $(shell cd ../..; pwd))
REPO_TOP_DIR 		= $(strip $(shell cd ${COSIM_TOP_DIR}/../..; pwd))
TEST_SUITE_DIR		= $(strip $(shell cd .; pwd))
TEST_SUITE_NAME		= $(shell cd .; basename `pwd`)

# Include current test suite common.make
include ./common.make

# Virtual-Mode test (single thread ONLY)
# Dont need to use all of them.. Just the pne has more page faults
ISA_VM_1CORE_ONLY_LIST	= 		\
	rv64uc-v-rvc				\
	rv64ui-v-srliw				\
	rv64um-v-remw				\
	rv64ua-v-amoswap_d			\
	rv64uf-v-recoding			\
	rv64ud-v-move

# make 4 cores
ISA_VM_LIST = $(foreach t,${ISA_VM_1CORE_ONLY_LIST},${t}0) 

ISA_SPECIAL_TESTS = 			\
	rv64mi-p-scall 				\
	rv64si-p-wfi 				\
	rv64ui-p-simple 			\
	rv64ud-p-structural

# single core only
ISA_1CORE_ONLY_LIST = 			\
	rv64mi-p-mcsr 				\
	rv64si-p-dirty 				\
	rv64ua-p-lrsc 				\
	rv64uc-p-rvc 				\
	rv64ui-p-sb 				\
	rv64ui-p-sd 				\
	rv64ui-p-sh 				\
	rv64ui-p-sw 

# single thread
ISA_SINGETHR_LIST = 			\
	rv64ua-p-amoand_d 			\
	rv64ua-p-amoand_w 			\
	rv64ua-p-amoor_d 			\
	rv64ua-p-amoor_w 			\
	rv64ua-p-amoswap_d 			\
	rv64ua-p-amoswap_w 			\
	rv64ua-p-amoxor_d 			\
	rv64ua-p-amoxor_w 			\
	rv64ua-p-amoadd_d 			\
	rv64ua-p-amoadd_w 			\
	rv64ua-p-amomax_d 			\
	rv64ua-p-amomaxu_d 			\
	rv64ua-p-amomaxu_w 			\
	rv64ua-p-amomax_w 			\
	rv64ua-p-amomin_d 			\
	rv64ua-p-amominu_d 			\
	rv64ua-p-amominu_w 			\
	rv64ua-p-amomin_w 			\
	rv64ud-p-ldst 				\

# all cores
ISA_PARALLEL_TEST_LIST = 		\
	rv64uf-p-move 				\
	rv64mi-p-access 			\
	rv64mi-p-breakpoint 		\
	rv64mi-p-csr 				\
	rv64mi-p-illegal 			\
	rv64mi-p-ma_addr 			\
	rv64mi-p-ma_fetch 			\
	rv64mi-p-sbreak 			\
	rv64si-p-csr 				\
	rv64si-p-ma_fetch 			\
	rv64si-p-sbreak 			\
	rv64si-p-scall 				\
	rv64ud-p-fadd 				\
	rv64ud-p-fclass 			\
	rv64ud-p-fcmp 				\
	rv64ud-p-fcvt 				\
	rv64ud-p-fcvt_w 			\
	rv64ud-p-fdiv 				\
	rv64ud-p-fmadd 				\
	rv64ud-p-fmin 				\
	rv64ud-p-move 				\
	rv64ud-p-recoding 			\
	rv64uf-p-fadd 				\
	rv64uf-p-fclass 			\
	rv64uf-p-fcmp 				\
	rv64uf-p-fcvt 				\
	rv64uf-p-fcvt_w 			\
	rv64uf-p-fdiv 				\
	rv64uf-p-fmadd 				\
	rv64uf-p-fmin 				\
	rv64uf-p-ldst 				\
	rv64uf-p-recoding 			\
	rv64ui-p-add 				\
	rv64ui-p-addi 				\
	rv64ui-p-addiw 				\
	rv64ui-p-addw 				\
	rv64ui-p-and 				\
	rv64ui-p-andi 				\
	rv64ui-p-auipc 				\
	rv64ui-p-beq 				\
	rv64ui-p-bge 				\
	rv64ui-p-bgeu 				\
	rv64ui-p-blt 				\
	rv64ui-p-bltu 				\
	rv64ui-p-bne 				\
	rv64ui-p-fence_i 			\
	rv64ui-p-jal 				\
	rv64ui-p-jalr 				\
	rv64ui-p-lb 				\
	rv64ui-p-lbu 				\
	rv64ui-p-ld 				\
	rv64ui-p-lh 				\
	rv64ui-p-lhu 				\
	rv64ui-p-lui 				\
	rv64ui-p-lw 				\
	rv64ui-p-lwu 				\
	rv64ui-p-or 				\
	rv64ui-p-ori 				\
	rv64ui-p-sll 				\
	rv64ui-p-slli 				\
	rv64ui-p-slliw 				\
	rv64ui-p-sllw 				\
	rv64ui-p-slt 				\
	rv64ui-p-slti 				\
	rv64ui-p-sltiu 				\
	rv64ui-p-sltu 				\
	rv64ui-p-sra 				\
	rv64ui-p-srai 				\
	rv64ui-p-sraiw 				\
	rv64ui-p-sraw 				\
	rv64ui-p-srl 				\
	rv64ui-p-srli 				\
	rv64ui-p-srliw 				\
	rv64ui-p-srlw 				\
	rv64ui-p-sub 				\
	rv64ui-p-subw 				\
	rv64ui-p-xor 				\
	rv64ui-p-xori 				\
	rv64um-p-div 				\
	rv64um-p-divu 				\
	rv64um-p-divuw 				\
	rv64um-p-divw 				\
	rv64um-p-mul 				\
	rv64um-p-mulh 				\
	rv64um-p-mulhsu 			\
	rv64um-p-mulhu 				\
	rv64um-p-mulw 				\
	rv64um-p-rem 				\
	rv64um-p-remu 				\
	rv64um-p-remuw 				\
	rv64um-p-remw

# Create a list of all the isa tests
TEST_LIST = 					\
	${ISA_SPECIAL_TESTS}		\
	${ISA_VM_LIST}				\
	${ISA_1CORE_ONLY_LIST} 		\
	${ISA_SINGETHR_LIST} 		\
	${ISA_PARALLEL_TEST_LIST}

# Special Debug Module test (temporarily removed)
#OPENOCD_CHECK := $(filter Debugger, $(shell openocd --version 2>&1 | grep Debugger))
#ifeq "$(OPENOCD_CHECK)" "Debugger"
#	TEST_LIST += dtmTest
#endif

runAll: ${TEST_SUITE_DIR}/.ISACreated
ifeq (${STAND_ALONE},1)
	make cleanAll
	make buildLibs
endif
	@for i in ${ISA_PARALLEL_TEST_LIST}; do																\
		echo "    PEND : ${TEST_SUITE_DIR}/$${i}"  > ${TEST_SUITE_DIR}/$${i}/status;		\
		(cd ${TEST_SUITE_DIR}/$${i}; rm -f *.o*; 											\
		make TEST_NAME=$${i});																\
	done

summary:
	@date > regressionSummary
	@for i in ${TEST_LIST}; do				\
		cat ${TEST_SUITE_DIR}/$${i}/status | tee -a regressionSummary;	\
	done

makeIsaTest: ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump
	@echo "Done"

# Default parameter values, override at commandine ONLY!!!
SINGLE_THREAD 		?= 0 
VIRTUAL_MODE 		?= 0
PASS_WRITETOHOST 	?= 0
MAX_TIMEOUT 		?= 200

${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump : ${RISCV_TEST_DIR}/isa/${TEST_NAME}
	@if test ! -d ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}; then	\
		mkdir  ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}; \
	fi
	@cp -f ${ISA_TEST_TEMPLATE}/Makefile        ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@cp -f ${ISA_TEST_TEMPLATE}/*.h             ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@cp -f ${ISA_TEST_TEMPLATE}/c_module.cc     ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/.
	@rm -f ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc

	@echo "#define MAX_TIMEOUT 200"    						>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
ifeq (${SINGLE_THREAD},1)
	@echo "#define SINGLE_THREAD_ONLY" 						>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifneq (${SINGLE_CORE_ONLY},)
	@echo "#define SINGLE_CORE_ONLY ${SINGLE_CORE_ONLY}" 	>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifeq (${VIRTUAL_MODE},1)
	@echo "#define VIRTUAL_MODE"       						>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
ifeq (${PASS_WRITETOHOST},1)
	@echo "#define PASS_WRITETOHOST"    					>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
endif
	@cat ${ISA_TEST_TEMPLATE}/c_dispatch.cc 				>> ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/c_dispatch.cc
	@cp -f ${RISCV_TEST_DIR}/isa/${TEST_NAME}      ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/riscv_wrapper.elf
	${RISCV_OBJCOPY} -O binary --change-addresses=-0x80000000 ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/riscv_wrapper.elf ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/riscv_wrapper.img
	@cp -f ${RISCV_TEST_DIR}/isa/${TEST_NAME}.dump ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/${TEST_NAME}${SFX}.dump
	@${BIN_DIR}/createPassFail.pl ${RISCV_TEST_DIR}/isa/${TEST_NAME}.dump ${ISA_SUITE_DIR}/${TEST_NAME}${SFX}/PassFail.hex

# Recursively calls make to build the test directories for ALL of the tests in the lists specified above.
# Given differing test requirements, they are called with different arguments.
createISATests: .force 
	@for i in ${ISA_VM_1CORE_ONLY_LIST}; do				\
		echo "== Generating VM 1CORE test directory for $${i}";		\
		make TEST_NAME=$${i} VIRTUAL_MODE=1 SINGLE_CORE_ONLY=1 SFX=0 makeIsaTest; \
		make TEST_NAME=$${i} VIRTUAL_MODE=1 SINGLE_CORE_ONLY=2 SFX=1 makeIsaTest; \
		make TEST_NAME=$${i} VIRTUAL_MODE=1 SINGLE_CORE_ONLY=4 SFX=2 makeIsaTest; \
		make TEST_NAME=$${i} VIRTUAL_MODE=1 SINGLE_CORE_ONLY=8 SFX=3 makeIsaTest; \
	done
	@for i in ${ISA_VM_SINGETHR_LIST}; do				\
		echo "== Generating VM SINGETHR test directory for $${i}";		\
		make TEST_NAME=$${i} VIRTUAL_MODE=1 SINGLE_THREAD=1 makeIsaTest; \
	done
	@for i in ${ISA_1CORE_ONLY_LIST}; do				\
		echo "== Generating 1CORE_ONLY test directory for $${i}";		\
		make TEST_NAME=$${i} SINGLE_CORE_ONLY=1 makeIsaTest; \
	done
	@for i in ${ISA_SINGETHR_LIST}; do				\
		echo "== Generating SINGETHR test directory for $${i}";		\
		make TEST_NAME=$${i} SINGLE_THREAD=1 makeIsaTest; \
	done
	@for i in ${ISA_PARALLEL_TEST_LIST}; do				\
		echo "== Generating PARALLEL test directory for $${i}";		\
		make TEST_NAME=$${i} makeIsaTest; \
	done
	@for i in ${ISA_SPECIAL_TESTS}; do				\
		echo "== Generating SPECIAL TESTs directory for $${i}";		\
		make TEST_NAME=$${i} PASS_WRITETOHOST=1 makeIsaTest; \
	done
	touch ${TEST_SUITE_DIR}/.ISACreated

# Cleans 
removeISATests:
	@rm -rf rv64*
	@rm -f ${TEST_SUITE_DIR}/.ISACreated


${TEST_SUITE_DIR}/.ISACreated:
	@echo "CEP_COSIM: Please run 'make createISATests' to continue"
	@exit 1
