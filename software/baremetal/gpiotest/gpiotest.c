//************************************************************************
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      gpiotest.c
// Program:        Common Evaluation Platform
// Description:    A program that sets up the GPIO to read the
//                 Arty100T switches and set the User LEDs accordingly
// Notes:          
//
//************************************************************************

#include <stdio.h>
#include <stdint.h>
#include "encoding.h"
#include "compiler.h"
#include "kprintf.h"
#include "platform.h"
#include "mmio.h"

int main() {

  kputs("");
  kputs("");
  kputs("------------------");
  kputs(" RISC-V GPIO Test ");
  kputs("------------------");
  kputs("");
  kputs("");
  
  uint32_t data = 0;

  // Enable the switch inputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_EN), (uint32_t)(SW0_MASK | SW1_MASK | SW2_MASK | SW3_MASK));

  // Enable the LED outputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_EN), (uint32_t)(LED0_MASK | LED1_MASK | LED2_MASK | LED3_MASK));

  // Infinite loop where you read the switches and write the LEDs
  while (1) {
  	data = reg_read32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_VAL));
  	for (uint32_t i = 0; i < 5000000; i++) {}
  	kprintf("switches = %x\n\r", (data >> 8) & 0xF);
  	reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_VAL), data << 8);
  }

  return 0;
}
