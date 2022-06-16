#!/usr/bin/env bash

#************************************************************************
# Copyright 2022 Massachusets Institute of Technology
# SPDX short identifier: BSD-2-Clause
#
# File Name:      manage-submodules.sh
# Program:        Common Evaluation Platform (CEP)
# Description:    This bash script is used to export and import the
#                 CEP submodules in support of releasing the CEP to
#                 the external github repository
# Notes:          .gitmodules lists the modules and paths, but
#                 does not identify the specific commit of said
#                 submodule.  It is crucial to preserve this information
#                 and use it to check the appropriate version of the
#                 submodule.
#
#************************************************************************

# Ensure we are at the repository's root directory
RDIR=$(git rev-parse --show-toplevel)
cd "$RDIR"

if [[ "$1" == "import" ]]; then
	echo "import"
elif [[ "$1" == "export" ]]; then
	# Extract all the submodules into an array
	git submodule > submoduleExport.txt
else
	scriptname=`basename "$0"`
	echo "Usage: $scriptname <import | export>"
	exit 1
fi
