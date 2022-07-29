//************************************************************************
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      hello_world.c
// Program:        Common Evaluation Platform
// Description:    A basic linux hello world program to run on the
//                 RISC-V
// Notes:          
//
//************************************************************************

#include <stdio.h>

#define MAX_LINE_LENGTH 80

int main() {

  char line[MAX_LINE_LENGTH] = {0};

  puts("");
  puts("");
  puts("--------------------------");
  puts(" Linux RISC-V Hello World ");
  puts("--------------------------");
  
  FILE *soc_compatible = fopen("/sys/firmware/devicetree/base/soc/compatible", "r");
  fgets(line, MAX_LINE_LENGTH, soc_compatible);
  fclose(soc_compatible);
  puts(line);
  puts("");
  puts("");
  
  return 0;
}
