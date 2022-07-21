//************************************************************************
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      hello_world.c
// Program:        Common Evaluation Platform
// Description:    A basic bare-metal hello world program to run on the
//                 RISC-V
// Notes:          
//
//************************************************************************

#include <stdio.h>
#include <stdint.h>
#include "encoding.h"
#include "compiler.h"
#include "kprintf.h"

int main() {

  puts("");
  puts("");
  puts("------------------");
  puts("RISC-V Hello World");
  puts("------------------");
  puts("");
  puts("");
  
  return 0;
}
