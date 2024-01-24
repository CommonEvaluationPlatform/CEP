#************************************************************************
# Copyright 2024 Massachusetts Institute of Technology
# SPDX short identifier: BSD-3-Clause
#
# File Name:      helloworld.mk
# Program:        Common Evaluation Platform (CEP)
# Description:    Buildroot makefile
# Notes:          
#************************************************************************

HELLOWORLD_VERSION 			= 1.0.0
HELLOWORLD_LICENSE 			= BSD-2-Clause
HELLOWORLD_DEPENDENCIES 	= 
HELLOWORLD_SITE 			= $(TOPDIR)/../../../../../../linux/helloworld
HELLOWORLD_SITE_METHOD 		= local
HELLOWORLD_INSTALL_STAGING 	= NO
HELLOWORLD_INSTALL_TARGET 	= YES

$(eval $(cmake-package))
