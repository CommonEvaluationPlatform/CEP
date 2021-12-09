//-------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      platform.h
// Program:        Common Evaluation Platform (CEP)
// Description:    
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
  smp_pause(s1, s2)
  li sp, (MEMORY_MEM_ADDR + MEMORY_MEM_SP_OFFSET)
  call main
  smp_resume(s1, s2)
  csrr a0, mhartid // hartid for next level bootloader
  la a1, dtb // dtb address for next level bootloader
  li s1, MEMORY_MEM_ADDR
  jr s1

  .section .dtb
  .align 3
dtb:
