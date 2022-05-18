#!/usr/bin/env bash
# exit script if any command fails
set -e
set -o pipefail

vivado -mode tcl -source program_arty100t.tcl
