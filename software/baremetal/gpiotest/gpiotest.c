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

#include <stdint.h>
#include "encoding.h"
#include "compiler.h"
#include "kprintf.h"
#include "platform.h"
#include "mmio.h"

#define   DEBOUNCE_CNT  10

// A simple routine to debouce the switch inputs
uint32_t get_switches(void) {

  uint32_t  switches_old;
  uint32_t  switches_new;
  int       debounce_counter = 0;

  while (debounce_counter < DEBOUNCE_CNT) {
    switches_old = (reg_read32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_VAL)) >> 8) & 0xFF;
    switches_new = (reg_read32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_VAL)) >> 8) & 0xFF;

    if (switches_new == switches_old) {
      debounce_counter++;
    } else {
      debounce_counter = 0;
    }

  } // end while

  return switches_new;

} // get_switch


int main() {

  int c;

  // Enable UART TX & RX (let's not assume the bootrom did it)
  REG32(uart, UART_REG_TXCTRL) |= UART_TXEN;
  REG32(uart, UART_REG_RXCTRL) |= UART_RXEN;

  kputs("");
  kputs("");
  kputs("------------------");
  kputs(" RISC-V GPIO Test ");
  kputs("------------------");
  kputs("");
  kputs("");
  
  uint32_t switch_old  = 0xFFFFFFFF;
  uint32_t switch_new  = 0;

  // Enable the switch inputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_EN), (uint32_t)(SW0_MASK | SW1_MASK | SW2_MASK | SW3_MASK));

  // Enable the LED outputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_EN), (uint32_t)(LED0_MASK | LED1_MASK | LED2_MASK | LED3_MASK));

  // Infinite loop where you read the switches and write the LEDs
  while (1) {

    // Get the switches state
    switch_new = get_switches();

    // A change of switch state has been detected... post debounce
    if (switch_new != switch_old) {
      kprintf("switches = %x\n", switch_new);
      switch_old = switch_new;
    }

    // A simple tty echo routine where CR and LF are converted to CR+LF
    kgetc(&c);
    if (c == '\r' || c == '\n') {
      kputc('\r');
      kputc('\n');
    } else if (c >= 0) {
      kputc(c);
    }

    reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_VAL), switch_new << 16);
  }

  return 0;
}
