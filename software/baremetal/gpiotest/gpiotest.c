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
#include <stdio.h>
#include "encoding.h"
#include "compiler.h"
#include "kprintf.h"
#include "platform.h"
#include "mmio.h"

#define   DEBOUNCE_CNT  10

// A simple routine to debouce the switch inputs
uint32_t get_gpio(void) {

  uint32_t  gpio_old;
  uint32_t  gpio_new;
  int       debounce_counter = 0;

  while (debounce_counter < DEBOUNCE_CNT) {
    gpio_old = reg_read32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_VAL));
    gpio_new = reg_read32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_VAL));

    if (gpio_new == gpio_old) {
      debounce_counter++;
    } else {
      debounce_counter = 0;
    }

  } // end while

  return gpio_new;

} // get_switch


int main() {

  int c;

  // Enable UART TX & RX (let's not assume the bootrom did it)
  REG32(uart, UART_REG_TXCTRL) |= UART_TXEN;
  REG32(uart, UART_REG_RXCTRL) |= UART_RXEN;

  puts("");
  puts("");
  puts("------------------");
  puts(" RISC-V GPIO Test ");
  puts("------------------");
  puts("");
  puts("");
  
  uint32_t gpio_old  = 0xFFFFFFFF;
  uint32_t gpio_new  = 0;

  // Enable the switch inputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_INPUT_EN), (uint32_t)(SW0_MASK | SW1_MASK | SW2_MASK | SW3_MASK));

  // Enable the LED outputs
  reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_EN), (uint32_t)(LED0_MASK | LED1_MASK | LED2_MASK | LED3_MASK));

  // Infinite loop where you read the switches and write the LEDs
  while (1) {

    // Get the switches state
    gpio_new = get_gpio();

    // A change of switch state has been detected... post debounce
    if (gpio_new != gpio_old) {
      printf("gpio = %08x\n", gpio_new);
      gpio_old = gpio_new;
    }

    // A simple tty echo routine where CR and LF are converted to CR+LF
    c = getchar();
    if (c == '\r' || c == '\n') {
      putchar('\r');
      putchar('\n');
    } else if (c >= 0) {
      putchar(c);
    }

    // Write the 
    reg_write32((uintptr_t)(GPIO_CTRL_ADDR + GPIO_OUTPUT_VAL), (gpio_new & 0x00000FF00) << 8);
  }

  return 0;
}
