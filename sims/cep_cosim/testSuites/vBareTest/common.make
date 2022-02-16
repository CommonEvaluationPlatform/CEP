#//************************************************************************
#// Copyright 2022 Massachusets Institute of Technology
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

override DUT_SIM_MODE	 		= BARE
override ELF_MODE    		= LOCAL
override DUT_XILINX_TOP_MODULE 	= cep_tb
override VIRTUAL_MODE	  		= 1
#
include ${REPO_TOP_DIR}/${COSIM_DIR_NAME}/common.make
