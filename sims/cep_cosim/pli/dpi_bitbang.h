//************************************************************************
// Copyright 2024 Massachusetts Institute of Technology
// SPDX License Identifier: BSD-3-Clause
//
// File Name:      dpi_bitbang.h
// Program:        Common Evaluation Platform (CEP)
// Description:    API functions for interfacing with OpenOCD
// Notes:          
//
//************************************************************************

#ifndef DPI_BITBANG_H
#define DPI_BITBANG_H

#include <stdint.h>
#include <sys/types.h>

extern "C" {
    int jtag_init(void) ;
    int jtag_quit(void);
    int jtag_getSocketPortId (void);
    int jtag_cmd(const int tdo_in, int *encode);
}

#endif
