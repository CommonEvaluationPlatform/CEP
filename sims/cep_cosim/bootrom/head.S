//-------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      head.S
// Program:        Common Evaluation Platform (CEP)
// Description:    Bootrom entry code
// Notes:          
//
//--------------------------------------------------------------------------------------
// See LICENSE.Sifive for license details.
#include <platform.h>
#include <smp.h>

  .section .text.init
  .option norvc
  .globl _prog_start
_prog_start:

  // Initialize the stack pointer
  li sp, (scratchpad_base_addr + scratchpad_sp_offset)

  // Disable UART and SD initialization when in simulation mode
#ifndef _SIM_ONLY
  smp_pause(s1, s2)
  call main
  smp_resume(s1, s2)
#endif

  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // dtb address for next level bootloader
  
  // Jump to main memory
  li s1, scratchpad_base_addr
  jr s1

  .section .dtb
  .align 3
dtb: