#!/usr/bin/env bash
#//--------------------------------------------------------------------------------------
#// Copyright 2022 Massachusets Institute of Technology
#// SPDX short identifier: BSD-3-Clause
#//
#// File          : program_vc707_jtag.sh
#// Project       : Common Evaluation Platform (CEP)
#// Description   : Shell script for invoking program_vc707_jtag.tcl
#// Notes         : exit script if any command fails
#//--------------------------------------------------------------------------------------
set -e
set -o pipefail

vivado -mode tcl -source program_vc707_jtag.tcl
