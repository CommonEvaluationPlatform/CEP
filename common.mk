#########################################################################################
# set default shell for make
#########################################################################################
SHELL=/bin/bash

# Without the following, RHEL7 does not execute the build process properly
.NOTPARALLEL:

ifndef RISCV
$(error RISCV is unset. You must set RISCV yourself, or through the Chipyard auto-generated env file)
else
$(info Running with RISCV=$(RISCV))
endif

#########################################################################################
# specify user-interface variables
#########################################################################################
HELP_COMPILATION_VARIABLES += \
"   EXTRA_GENERATOR_REQS   = additional make requirements needed for the main generator" \
"   EXTRA_SIM_CXXFLAGS     = additional CXXFLAGS for building simulators" \
"   EXTRA_SIM_LDFLAGS      = additional LDFLAGS for building simulators" \
"   EXTRA_SIM_SOURCES      = additional simulation sources needed for simulator" \
"   EXTRA_SIM_REQS         = additional make requirements to build the simulator" \
"   ENABLE_SBT_THIN_CLIENT = if set, use sbt's experimental thin client (works best when overridding SBT_BIN with the mainline sbt script)" \
"   EXTRA_CHISEL_OPTIONS   = additional options to pass to the Chisel compiler" \
"   EXTRA_FIRRTL_OPTIONS   = additional options to pass to the FIRRTL compiler"

EXTRA_GENERATOR_REQS 	?= $(BOOTROM_TARGETS) $(CHIPYARD_BUILD_INFO)
EXTRA_SIM_CXXFLAGS   	?=
EXTRA_SIM_LDFLAGS    	?=
EXTRA_SIM_SOURCES    	?=
EXTRA_SIM_REQS       	?=

#----------------------------------------------------------------------------
HELP_SIMULATION_VARIABLES += \
"   EXTRA_SIM_FLAGS        = additional runtime simulation flags (passed within +permissive)" \
"   NUMACTL                = set to '1' to wrap simulator in the appropriate numactl command" \
"   BREAK_SIM_PREREQ       = when running a binary, doesn't rebuild RTL on source changes"

EXTRA_SIM_FLAGS ?=
NUMACTL         ?= 0

NUMA_PREFIX = $(if $(filter $(NUMACTL),0),,$(shell $(base_dir)/scripts/numa_prefix))

#----------------------------------------------------------------------------
HELP_COMMANDS += \
"   run-binary                  = run [./$(shell basename $(sim))] and log instructions to file" \
"   run-binary-fast             = run [./$(shell basename $(sim))] and don't log instructions" \
"   run-binary-debug            = run [./$(shell basename $(sim_debug))] and log instructions and waveform to files" \
"   verilog                     = generate intermediate verilog files from chisel elaboration and firrtl passes" \
"   firrtl                      = generate intermediate firrtl files from chisel elaboration" \
"   run-tests                   = run all assembly and benchmark tests" \
"   launch-sbt                  = start sbt terminal" \
"   {shutdown,start}-sbt-server = shutdown or start sbt server if using ENABLE_SBT_THIN_CLIENT" \

#########################################################################################
# include additional subproject make fragments
# see HELP_COMPILATION_VARIABLES
#########################################################################################
include $(base_dir)/generators/cva6/cva6.mk
include $(base_dir)/generators/tracegen/tracegen.mk
include $(base_dir)/generators/nvdla/nvdla.mk
include $(base_dir)/tools/dromajo/dromajo.mk
include $(base_dir)/tools/torture.mk

#########################################################################################
# Prerequisite lists
#########################################################################################
# Returns a list of files in directory $1 with file extension $2.
# If available, use 'fd' to find the list of files, which is faster than 'find'.
ifeq ($(shell which fd 2> /dev/null),)
	lookup_srcs = $(shell find -L $(1)/ -name target -prune -o -iname "*.$(2)" -print 2> /dev/null)
else
	lookup_srcs = $(shell fd -L ".*\.$(2)" $(1))
endif

SOURCE_DIRS = $(addprefix $(base_dir)/,generators sims/firesim/sim tools/barstools/iocell fpga/fpga-shells fpga/src)
SCALA_SOURCES = $(call lookup_srcs,$(SOURCE_DIRS),scala)
VLOG_SOURCES = $(call lookup_srcs,$(SOURCE_DIRS),sv) $(call lookup_srcs,$(SOURCE_DIRS),v)
# This assumes no SBT meta-build sources
SBT_SOURCE_DIRS = $(addprefix $(base_dir)/,generators sims/firesim/sim tools)
SBT_SOURCES = $(call lookup_srcs,$(SBT_SOURCE_DIRS),sbt) $(base_dir)/build.sbt $(base_dir)/project/plugins.sbt $(base_dir)/project/build.properties

#########################################################################################
# SBT Server Setup (start server / rebuild proj. defs. if SBT_SOURCES change)
#########################################################################################
$(SBT_THIN_CLIENT_TIMESTAMP): $(SBT_SOURCES)
ifneq (,$(wildcard $(SBT_THIN_CLIENT_TIMESTAMP)))
	cd $(base_dir) && $(SBT) "reload"
	touch $@
else
	cd $(base_dir) && $(SBT) "exit"
endif

#########################################################################################
# CEP: The following targets perform custom steps for the CEP build
#########################################################################################
# These steps are only relevant when building CEP-related targets
$(CHIPYARD_BUILD_INFO):
	@# Save the name of some of the files needed by the CEP Cosimulation enviornment
	@rm -f $@
	@echo "CHIPYARD_BLD_DIR = $(build_dir)"  >> $@
	@echo "CHIPYARD_LONG_NAME = $(long_name).top" >> $@
	@echo "CHIPYARD_TOP_FILE = $(TOP_FILE)" >> $@
	@echo "CHIPYARD_HARNESS_FILE = $(HARNESS_FILE)" >> $@
	@echo "CHIPYARD_TOP_SMEMS_FILE = $(TOP_SMEMS_FILE)" >> $@
	@echo "CHIPYARD_HARNESS_SMEMS_FILE = $(HARNESS_SMEMS_FILE)" >> $@
	@echo "CHIPYARD_SIM_HARNESS_BLACKBOXES = ${sim_harness_blackboxes}" >> $@
	@echo "CHIPYARD_SIM_TOP_BLACKBOXES = ${sim_top_blackboxes}" >> $@
	@echo "CHIPYARD_SIM_FILES = ${sim_files}" >> $@
	@echo "CHIPYARD_TOP_MODULE = ${TOP}" >> $@
	@echo "CHIPYARD_SUB_PROJECT = ${SUB_PROJECT}" >> $@

$(build_dir): cep_preprocessing
	mkdir -p $@

$(BOOTROM_SOURCES):
	(cd ${BOOTROM_SRC_DIR}; make PBUS_CLK=${PBUS_CLK})

$(BOOTROM_TARGETS): $(BOOTROM_SOURCES) | $(build_dir)
	cp -f $(BOOTROM_SOURCES) $(build_dir)

# The following make target will peform some scala file shuffling if we are building
# the CEP ASIC target.  Otherwise, the chipyard will be "left alone" allowing a non-ASIC
# build to proceed *without* the CEP_Chipyard_ASIC submodule
PHONY: cep_preprocessing
cep_preprocessing: 
	@echo ""
	@echo "CEP: ----------------------------------------------------------------------"
	@echo "CEP:  Performing CEP Preprocessing step...."
	@echo "CEP: ----------------------------------------------------------------------"
ifeq "$(findstring cep_cosim_asic,${SUB_PROJECT})" "cep_cosim_asic"
	@echo "CEP:  Staging an ASIC build..."
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/build.sbt.asic ${base_dir}/build.sbt
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/DigitalTop.scala $(base_dir)/generators/chipyard/src/main/scala
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/System.scala $(base_dir)/generators/chipyard/src/main/scala
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/IOBinders.scala $(base_dir)/generators/chipyard/src/main/scala
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/config/AbstractCEPASICConfig.scala $(base_dir)/generators/chipyard/src/main/scala/config
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/config/CEPASICConfig.scala $(base_dir)/generators/chipyard/src/main/scala/config
	-cp $(base_dir)/CEP_Chipyard_ASIC/chipyard_tobecopied/generators/chipyard/src/main/scala/config/fragments/CEPASICConfigFragments.scala $(base_dir)/generators/chipyard/src/main/scala/config/fragments
else
	@echo "CEP:  Staging a non-ASIC build..."
	-cp $(base_dir)/build.sbt.nonasic ${base_dir}/build.sbt
	-cp $(base_dir)/generators/chipyard/src/main/scala/DigitalTop.scala.nonasic $(base_dir)/generators/chipyard/src/main/scala/DigitalTop.scala
	-cp $(base_dir)/generators/chipyard/src/main/scala/System.scala.nonasic $(base_dir)/generators/chipyard/src/main/scala/System.scala
	-cp $(base_dir)/generators/chipyard/src/main/scala/IOBinders.scala.nonasic $(base_dir)/generators/chipyard/src/main/scala/IOBinders.scala
endif
	@echo "CEP: ----------------------------------------------------------------------"
	@echo ""

PHONY: cep_clean
cep_clean:
	-rm -f $(CHIPYARD_BUILD_INFO)
	-rm -f $(base_dir)/build.sbt
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/DigitalTop.scala
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/System.scala
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/IOBinders.scala
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/config/AbstractCEPASICConfig.scala
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/config/CEPASICConfig.scala
	-rm -f $(base_dir)/generators/chipyard/src/main/scala/config/fragments/CEPASICConfigFragments.scala
#########################################################################################



#########################################################################################
# create firrtl file rule and variables
#########################################################################################
.INTERMEDIATE: generator_temp
$(FIRRTL_FILE) $(ANNO_FILE): generator_temp
	@echo "" > /dev/null

# AG: must re-elaborate if cva6 sources have changed... otherwise just run firrtl compile
generator_temp: $(SCALA_SOURCES) $(sim_files) $(SCALA_BUILDTOOL_DEPS) $(EXTRA_GENERATOR_REQS) | $(build_dir)
	$(call run_scala_main,$(SBT_PROJECT),$(GENERATOR_PACKAGE).Generator,\
		--target-dir $(build_dir) \
		--name $(long_name) \
		--top-module $(MODEL_PACKAGE).$(MODEL) \
		--legacy-configs $(CONFIG_PACKAGE):$(CONFIG) \
		$(EXTRA_CHISEL_OPTIONS))

.PHONY: firrtl
firrtl: $(FIRRTL_FILE)

#########################################################################################
# create verilog files rules and variables
#########################################################################################
REPL_SEQ_MEM = --infer-rw --repl-seq-mem -c:$(MODEL):-o:$(TOP_SMEMS_CONF)
HARNESS_CONF_FLAGS = -thconf $(HARNESS_SMEMS_CONF)

TOP_TARGETS = $(TOP_FILE) $(TOP_SMEMS_CONF) $(TOP_ANNO) $(TOP_FIR) $(sim_top_blackboxes)
HARNESS_TARGETS = $(HARNESS_FILE) $(HARNESS_SMEMS_CONF) $(HARNESS_ANNO) $(HARNESS_FIR) $(sim_harness_blackboxes)

# DOC include start: FirrtlCompiler
# NOTE: These *_temp intermediate targets will get removed in favor of make 4.3 grouped targets (&: operator)
.INTERMEDIATE: firrtl_temp
$(TOP_TARGETS) $(HARNESS_TARGETS): firrtl_temp
	@echo "" > /dev/null

firrtl_temp: $(FIRRTL_FILE) $(ANNO_FILE) $(VLOG_SOURCES)
	$(call run_scala_main,tapeout,barstools.tapeout.transforms.GenerateTopAndHarness,\
		--output-file $(TOP_FILE) \
		--harness-o $(HARNESS_FILE) \
		--input-file $(FIRRTL_FILE) \
		--syn-top $(TOP) \
		--harness-top $(VLOG_MODEL) \
		--annotation-file $(ANNO_FILE) \
		--top-anno-out $(TOP_ANNO) \
		--top-dotf-out $(sim_top_blackboxes) \
		--top-fir $(TOP_FIR) \
		--harness-anno-out $(HARNESS_ANNO) \
		--harness-dotf-out $(sim_harness_blackboxes) \
		--harness-fir $(HARNESS_FIR) \
		$(REPL_SEQ_MEM) \
		$(HARNESS_CONF_FLAGS) \
		--target-dir $(build_dir) \
		--log-level $(FIRRTL_LOGLEVEL) \
		$(EXTRA_FIRRTL_OPTIONS))
# Blackbox sorting script
ifeq "$(findstring cep,${SUB_PROJECT})" "cep"
	@${SORT_SCRIPT} ${sim_top_blackboxes} $(SORT_FILE)
endif
	touch $(sim_top_blackboxes) $(sim_harness_blackboxes)
# DOC include end: FirrtlCompiler

# This file is for simulation only. VLSI flows should replace this file with one containing hard SRAMs
MACROCOMPILER_MODE ?= --mode synflops
.INTERMEDIATE: top_macro_temp
$(TOP_SMEMS_FILE) $(TOP_SMEMS_FIR): top_macro_temp
	@echo "" > /dev/null

top_macro_temp: $(TOP_SMEMS_CONF)
	$(call run_scala_main,barstoolsMacros,barstools.macros.MacroCompiler,-n $(TOP_SMEMS_CONF) -v $(TOP_SMEMS_FILE) -f $(TOP_SMEMS_FIR) $(MACROCOMPILER_MODE))

HARNESS_MACROCOMPILER_MODE = --mode synflops
.INTERMEDIATE: harness_macro_temp
$(HARNESS_SMEMS_FILE) $(HARNESS_SMEMS_FIR): harness_macro_temp
	@echo "" > /dev/null

harness_macro_temp: $(HARNESS_SMEMS_CONF) | top_macro_temp
	$(call run_scala_main,barstoolsMacros,barstools.macros.MacroCompiler, -n $(HARNESS_SMEMS_CONF) -v $(HARNESS_SMEMS_FILE) -f $(HARNESS_SMEMS_FIR) $(HARNESS_MACROCOMPILER_MODE))

########################################################################################
# remove duplicate files and headers in list of simulation file inputs
########################################################################################
$(sim_common_files): $(sim_files) $(sim_top_blackboxes) $(sim_harness_blackboxes)
	sort -u $^ | grep -v '.*\.\(svh\|h\)$$' > $@

#########################################################################################
# helper rule to just make verilog files
#########################################################################################
.PHONY: verilog
verilog: $(sim_vsrcs)

#########################################################################################
# helper rules to run simulations
#########################################################################################
.PHONY: run-binary run-binary-fast run-binary-debug run-fast

check-binary:
ifeq (,$(BINARY))
	$(error BINARY variable is not set. Set it to the simulation binary)
endif

# allow you to override sim prereq
ifeq (,$(BREAK_SIM_PREREQ))
SIM_PREREQ = $(sim)
SIM_DEBUG_PREREQ = $(sim_debug)
endif

# run normal binary with hardware-logged insn dissassembly
run-binary: $(output_dir) $(SIM_PREREQ) check-binary
	(set -o pipefail && $(NUMA_PREFIX) $(sim) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(VERBOSE_FLAGS) $(PERMISSIVE_OFF) $(BINARY) </dev/null 2> >(spike-dasm > $(sim_out_name).out) | tee $(sim_out_name).log)

# run simulator as fast as possible (no insn disassembly)
run-binary-fast: $(output_dir) $(SIM_PREREQ) check-binary
	(set -o pipefail && $(NUMA_PREFIX) $(sim) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(PERMISSIVE_OFF) $(BINARY) </dev/null | tee $(sim_out_name).log)

# run simulator with as much debug info as possible
run-binary-debug: $(output_dir) $(SIM_DEBUG_PREREQ) check-binary
	(set -o pipefail && $(NUMA_PREFIX) $(sim_debug) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(VERBOSE_FLAGS) $(WAVEFORM_FLAG) $(PERMISSIVE_OFF) $(BINARY) </dev/null 2> >(spike-dasm > $(sim_out_name).out) | tee $(sim_out_name).log)

run-fast: run-asm-tests-fast run-bmark-tests-fast

#########################################################################################
# helper rules to run simulator with fast loadmem via hex files
#########################################################################################
$(binary_hex): $(output_dir) $(BINARY)
	$(base_dir)/scripts/smartelf2hex.sh $(BINARY) > $(binary_hex)

run-binary-hex: check-binary
run-binary-hex: $(output_dir) $(SIM_PREREQ) $(binary_hex)
run-binary-hex: run-binary
run-binary-hex: override LOADMEM_ADDR = 80000000
run-binary-hex: override LOADMEM = $(binary_hex)
run-binary-hex: override SIM_FLAGS += +loadmem=$(LOADMEM) +loadmem_addr=$(LOADMEM_ADDR)
run-binary-debug-hex: check-binary
run-binary-debug-hex: $(output_dir) $(SIM_DEBUG_REREQ) $(binary_hex)
run-binary-debug-hex: run-binary-debug
run-binary-debug-hex: override LOADMEM_ADDR = 80000000
run-binary-debug-hex: override LOADMEM = $(binary_hex)
run-binary-debug-hex: override SIM_FLAGS += +loadmem=$(LOADMEM) +loadmem_addr=$(LOADMEM_ADDR)
run-binary-fast-hex: check-binary
run-binary-fast-hex: $(output_dir) $(SIM_PREREQ) $(binary_hex)
run-binary-fast-hex: run-binary-fast
run-binary-fast-hex: override LOADMEM_ADDR = 80000000
run-binary-fast-hex: override LOADMEM = $(binary_hex)
run-binary-fast-hex: override SIM_FLAGS += +loadmem=$(LOADMEM) +loadmem_addr=$(LOADMEM_ADDR)

#########################################################################################
# run assembly/benchmarks rules
#########################################################################################
$(output_dir):
	mkdir -p $@

$(output_dir)/%: $(RISCV)/riscv64-unknown-elf/share/riscv-tests/isa/% $(output_dir)
	ln -sf $< $@

$(output_dir)/%.run: $(output_dir)/% $(SIM_PREREQ)
	(set -o pipefail && $(NUMA_PREFIX) $(sim) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(PERMISSIVE_OFF) $< </dev/null | tee $<.log) && touch $@

$(output_dir)/%.out: $(output_dir)/% $(SIM_PREREQ)
	(set -o pipefail && $(NUMA_PREFIX) $(sim) $(PERMISSIVE_ON) $(SIM_FLAGS) $(EXTRA_SIM_FLAGS) $(SEED_FLAG) $(VERBOSE_FLAGS) $(PERMISSIVE_OFF) $< </dev/null 2> >(spike-dasm > $@) | tee $<.log)

#########################################################################################
# include build/project specific makefrags made from the generator
#########################################################################################
ifneq ($(filter run% %.run %.out %.vpd %.vcd %.fsdb,$(MAKECMDGOALS)),)
-include $(build_dir)/$(long_name).d
endif

#######################################
# Rules for building DRAMSim2 library
#######################################

dramsim_dir = $(base_dir)/tools/DRAMSim2
dramsim_lib = $(dramsim_dir)/libdramsim.a

$(dramsim_lib):
	$(MAKE) -C $(dramsim_dir) $(notdir $@)

################################################
# Helper to run SBT or manage the SBT server
################################################

SBT_COMMAND ?= shell
.PHONY: launch-sbt
launch-sbt:
	cd $(base_dir) && $(SBT_NON_THIN) "$(SBT_COMMAND)"

.PHONY: check-thin-client
check-thin-client:
ifeq (,$(ENABLE_SBT_THIN_CLIENT))
	$(error ENABLE_SBT_THIN_CLIENT not set.)
endif

.PHONY: shutdown-sbt-server
shutdown-sbt-server: check-thin-client
	cd $(base_dir) && $(SBT) "shutdown"

.PHONY: start-sbt-server
start-sbt-server: check-thin-client
	cd $(base_dir) && $(SBT) "exit"

#########################################################################################
# print help text
#########################################################################################
.PHONY: help
help:
	@for line in $(HELP_LINES); do echo "$$line"; done

#########################################################################################
# Implicit rule handling
#########################################################################################
# Disable all suffix rules to improve Make performance on systems running older
# versions of Make
.SUFFIXES:
