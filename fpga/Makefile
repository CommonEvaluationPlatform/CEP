#//************************************************************************
#// Copyright 2024 Massachusetts Institute of Technology
#// SPDX short identifier: BSD-3-Clause
#//
#// File Name:      Makefile
#// Program:        Common Evaluation Platform (CEP)
#// Description:    Chipyard makefile for building FPGA targets
#// Notes:          - SORT_SCRIPT for CEP targets to address compile order
#//
#//************************************************************************

#########################################################################################
# fpga prototype makefile
#########################################################################################

#########################################################################################
# general path variables
#########################################################################################
base_dir=$(abspath ..)
sim_dir=$(abspath .)

# do not generate simulation files
sim_name := none

#########################################################################################
# include shared variables
#########################################################################################

# Verify vivado is available, capture and display the version if it is...
ifeq "$(findstring clean,${MAKECMDGOALS})" ""
ifeq (,$(shell which vivado))
$(error Vivado is not available.  Please install and ensure the environment script is sourced.)
else
VIVADO_VERSION := $(shell vivado -version | head -1 | grep -o -P '(?<=\s).*(?=\s)')
$(info Vivado $(VIVADO_VERSION) detected.)
endif
endif

ifeq ($(SUB_PROJECT),vc707)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= VC707FPGATestHarness
	VLOG_MODEL        ?= VC707FPGATestHarness
	MODEL_PACKAGE     ?= chipyard.fpga.vc707
	CONFIG            ?= RocketVC707Config
	CONFIG_PACKAGE    ?= chipyard.fpga.vc707
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= vc707
	FPGA_BRAND        ?= xilinx
	BOOTROM_TARGETS	  :=
endif

ifeq ($(SUB_PROJECT),vcu118)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= VCU118FPGATestHarness
	VLOG_MODEL        ?= VCU118FPGATestHarness
	MODEL_PACKAGE     ?= chipyard.fpga.vcu118
	CONFIG            ?= RocketVCU118Config
	CONFIG_PACKAGE    ?= chipyard.fpga.vcu118
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= vcu118
	FPGA_BRAND        ?= xilinx
	BOOTROM_TARGETS	  :=
endif

ifeq ($(SUB_PROJECT),nexysvideo)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= NexysVideoHarness
	VLOG_MODEL        ?= NexysVideoHarness
	MODEL_PACKAGE     ?= chipyard.fpga.nexysvideo
	CONFIG            ?= RocketNexysVideoConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.nexysvideo
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= nexys_video
	FPGA_BRAND        ?= xilinx
	BOOTROM_TARGETS	  :=
endif

ifeq ($(SUB_PROJECT),arty35t)
	# TODO: Fix with Arty
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= Arty35THarness
	VLOG_MODEL        ?= Arty35THarness
	MODEL_PACKAGE     ?= chipyard.fpga.arty
	CONFIG            ?= TinyRocketArtyConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.arty
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= arty
	FPGA_BRAND        ?= xilinx
	BOOTROM_TARGETS	  :=
endif

ifeq ($(SUB_PROJECT),arty100t)
	# TODO: Fix with Arty
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= Arty100THarness
	VLOG_MODEL        ?= Arty100THarness
	MODEL_PACKAGE     ?= chipyard.fpga.arty100t
	CONFIG            ?= RocketArty100TConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.arty100t
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= arty_a7_100
	FPGA_BRAND        ?= xilinx
	BOOTROM_TARGETS	  :=
endif

# Bootrom targets are "cleared" for CEP FPGA targets, since
# build is controlled from within the chisel configuration
ifeq ($(SUB_PROJECT),cep_vc707)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= VC707FPGATestHarness
	VLOG_MODEL        ?= VC707FPGATestHarness
	MODEL_PACKAGE     ?= chipyard.fpga.vc707
	CONFIG            ?= RocketVC707CEPConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.vc707
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= vc707
	FPGA_BRAND        ?= xilinx
	SORT_SCRIPT		  := $(base_dir)/scripts/sort-blackbox.py
	SORT_FILE         := $(base_dir)/cep_sort.f
	BOOTROM_TARGETS	  :=
endif

# Bootrom targets are "cleared" for CEP FPGA targets, since
# build is controlled from within the chisel configuration
ifeq ($(SUB_PROJECT),cep_vcu118)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= VCU118FPGATestHarness
	VLOG_MODEL        ?= VCU118FPGATestHarness
	MODEL_PACKAGE     ?= chipyard.fpga.vcu118
	CONFIG            ?= RocketVCU118CEPConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.vcu118
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= vcu118
	FPGA_BRAND        ?= xilinx
	SORT_SCRIPT		  := $(base_dir)/scripts/sort-blackbox.py
	SORT_FILE         := $(base_dir)/cep_sort.f
	BOOTROM_TARGETS	  :=
endif

# Bootrom targets are "cleared" for CEP FPGA targets, since
# build is controlled from within the chisel configuration
ifeq ($(SUB_PROJECT),cep_arty100t)
	SBT_PROJECT       ?= chipyard_fpga
	MODEL             ?= Arty100THarness
	VLOG_MODEL        ?= Arty100THarness
	MODEL_PACKAGE     ?= chipyard.fpga.arty100t
	CONFIG            ?= RocketArty100TCEPConfig
	CONFIG_PACKAGE    ?= chipyard.fpga.arty100t
	GENERATOR_PACKAGE ?= chipyard
	TB                ?= none # unused
	TOP               ?= ChipTop
	BOARD             ?= arty_a7_100
	FPGA_BRAND        ?= xilinx
	SORT_SCRIPT		  := $(base_dir)/scripts/sort-blackbox.py
	SORT_FILE         := $(base_dir)/cep_sort.f
	BOOTROM_TARGETS	  :=
endif

# If SBT_PROJECT is not defined, then none of the SUB_PROJECTS above were selected
ifeq "$(findstring clean,${MAKECMDGOALS})" ""
ifeq ($(SBT_PROJECT),)
$(error Please specify a valid SUB_PROJECT (there is no default))
endif
endif

export USE_CHISEL6=1

include $(base_dir)/variables.mk

# default variables to build the arty example
# setup the board to use

.PHONY: default
default: bitstream

#########################################################################################
# misc. directories
#########################################################################################
fpga_dir := $(base_dir)/fpga/fpga-shells/$(FPGA_BRAND)
fpga_common_script_dir := $(fpga_dir)/common/tcl


#########################################################################################
# setup misc. sim files
#########################################################################################
# copy files but ignore *.h files in *.f (match vcs)
$(sim_files): $(SIM_FILE_REQS) $(ALL_MODS_FILELIST) | $(GEN_COLLATERAL_DIR)
	-cp -f $(SIM_FILE_REQS) $(GEN_COLLATERAL_DIR)
	touch $@
	$(foreach file,\
		$(SIM_FILE_REQS),\
		$(if $(filter %.h,$(file)),\
			,\
			echo "$(addprefix $(GEN_COLLATERAL_DIR)/, $(notdir $(file)))" >> $@;))

#########################################################################################
# import other necessary rules and variables
#########################################################################################
include $(base_dir)/common.mk

#########################################################################################
# copy from other directory
#########################################################################################
all_vsrcs := \
	$(base_dir)/generators/rocket-chip-blocks/vsrc/SRLatch.v

#########################################################################################
# vivado rules
#########################################################################################
# combine all sources into single .f
synth_list_f := $(build_dir)/$(long_name).vsrcs.f
$(synth_list_f): $(sim_common_files) $(all_vsrcs)
	$(foreach file,$(all_vsrcs),echo "$(file)" >> $@;)
	cat $(sim_common_files) >> $@

BIT_FILE := $(build_dir)/obj/$(MODEL).bit
$(BIT_FILE): $(synth_list_f)
	cd $(build_dir); vivado \
		-nojournal -mode batch \
		-source $(fpga_common_script_dir)/vivado.tcl \
		-tclargs \
			-top-module "$(MODEL)" \
			-F "$(synth_list_f)" \
			-board "$(BOARD)" \
			-ip-vivado-tcls "$(shell find '$(build_dir)' -name '*.vivado.tcl')"

.PHONY: bitstream
bitstream: cep_preprocessing $(BIT_FILE)

.PHONY: debug-bitstream
debug-bitstream: cep_preprocessing $(build_dir)/obj/post_synth.dcp
	cd $(build_dir); vivado \
		-nojournal -mode batch \
		-source $(sim_dir)/scripts/run_impl_bitstream.tcl \
		-tclargs \
			$(build_dir)/obj/post_synth.dcp \
			$(BOARD) \
			$(build_dir)/debug_obj \
			$(fpga_common_script_dir)

#########################################################################################
# general cleanup rules
#########################################################################################
.PHONY: clean cleanAll

# Clean ALL the builds
cleanAll: cep_clean
	rm -rf $(gen_dir)
	rm -f *.log
	rm -f *.jou

# Clean just the current subproject
clean: cep_clean
	rm -rf $(build_dir)
	rm -f *.log
	rm -f *.jou
