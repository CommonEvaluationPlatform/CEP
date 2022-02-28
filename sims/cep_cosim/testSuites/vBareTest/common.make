#--------------------------------------------------------------------------------------
# Copyright 2022 Massachusets Institute of Technology
#
# File Name:      common.make
# Program:        Common Evaluation Platform (CEP)
# Description:    common.make for Virtual Bare Metal test suite
# Notes:          
#
#--------------------------------------------------------------------------------------

# override anything here before calling the top 
override DUT_SIM_MODE			= BARE
override ELF_MODE   			= LOCAL
override VIRTUAL_MODE 			= 1

# Call root cosimulation common.make
include ${COSIM_TOP_DIR}/common.make
