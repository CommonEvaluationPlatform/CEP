#//************************************************************************
#// Copyright 2021 Massachusetts Institute of Technology
#//
#// File Name:      
#// Program:        Common Evaluation Platform (CEP)
#// Description:    
#// Notes:          
#//
#//************************************************************************
#
# override anything here before calling the top 
#
# must have this one for auto-dependentcy detection

override DUT_SIM_MODE	 = BARE
override DUT_ELF_MODE    = LOCAL
override DUT_XILINX_TOP_MODULE = cep_tb
override DUT_IN_VIRTUAL  = 1
#
include ${DUT_TOP_DIR}/${COSIM_NAME}/common.make
