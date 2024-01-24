#***********************************************************************
# Copyright 2024 Massachusetts Institute of Technology
# SPDX short identifier: BSD-3-Clause
#
# File Name:      gpiotest.mk
# Program:        Common Evaluation Platform (CEP)
# Description:    Buildroot makefile
# Notes:          
#************************************************************************

GPIOTEST_VERSION 			= 1.0.0
GPIOTEST_LICENSE 			= BSD-2-Clause
GPIOTEST_DEPENDENCIES 		= libgpiod
GPIOTEST_SITE 				= $(TOPDIR)/../../../../../../linux/gpiotest
GPIOTEST_SITE_METHOD 		= local
GPIOTEST_INSTALL_STAGING 	= NO
GPIOTEST_INSTALL_TARGET 	= YES

$(eval $(cmake-package))
