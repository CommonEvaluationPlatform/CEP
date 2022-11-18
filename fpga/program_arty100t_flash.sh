#!/usr/bin/env bash
#//--------------------------------------------------------------------------------------
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX short identifier: BSD-3-Clause
#//
#// File          : program_arty100t_flash.tcl
#// Project       : Common Evaluation Platform (CEP)
#// Description   : Shell script for invoking program_arty100t_flash.tcl
#// Notes         : exit script if any command fails
#//--------------------------------------------------------------------------------------
set -e
set -o pipefail

vivado -mode tcl -source program_arty100t_flash.tcl
