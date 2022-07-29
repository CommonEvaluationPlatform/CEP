//************************************************************************
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      gpiotest.c
// Program:        Common Evaluation Platform
// Description:    Linux program that uses gpiod to read the switches
//                 and set the LEDs accordingly
// Notes:          
//
//************************************************************************

#include <gpiod.h>
#include <error.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define   GPIO_WIDTH    4
#define   DEBOUNCE_CNT  10

// Defines the support board targets
enum board {vc707, arty100t};
typedef enum board	Board;

// Compare arrays function
int compare_arrays(int left[], int right[], int num_elements) {
  for (int i = 0; i < num_elements; i++) {
    if (left[i] != right[i]) {
      return 0;
    }
  }

  return 1;
}

// A simple routine to debouce gpio reads
int get_switches_debounced(struct gpiod_line_bulk *bulk, int values_old[GPIO_WIDTH]) {

  int values_new[GPIO_WIDTH]  = {0, 0, 0, 0};
  int debounce_counter        = 0;
  int i;
  int ret;

  while (debounce_counter < DEBOUNCE_CNT) {
    
    ret = gpiod_line_get_value_bulk(bulk, values_new);
    if (ret)
      return ret;

    if (compare_arrays(values_new, values_old, GPIO_WIDTH))
      debounce_counter++;
    else
      debounce_counter = 0;

    for (i = 0; i < GPIO_WIDTH; i++) {
      values_old[i] = values_new[i];
    }

  } // end while

  return 0;

} // get_switch

int main(int argc, char **argv)
{

  char *chipname = "gpiochip0";
  struct gpiod_chip *chip;
  struct gpiod_line_bulk input_lines;
  unsigned int input_line_offsets[GPIO_WIDTH] = {8, 9, 10, 11};       // Offsets to switches
  struct gpiod_line_request_config input_config[GPIO_WIDTH];
  struct gpiod_line_bulk output_lines;
  unsigned int output_line_offsets[GPIO_WIDTH] = {16, 17, 18, 19};    // Offsets to LEDs
  struct gpiod_line_request_config output_config[GPIO_WIDTH];
  int values_old[GPIO_WIDTH] = {2, 2, 2, 2};	// guarentees at least one printout
  int values_new[GPIO_WIDTH] = {0, 0, 0, 0};
  int i;
  int j;
  int ret;

  printf("\n");
  printf("\n");
  printf("--------------------------\n");
  printf("  Linux RISC-V GPIO Test  \n");
  printf("--------------------------\n");
  printf("\n");

  // Enable access to the GPIO Device
  chip = gpiod_chip_open_by_name(chipname);
  if (!chip) {
    perror("Open chip failed\n");
    goto end;
  }

  // Get the gpio lines
  ret  = gpiod_chip_get_lines(chip, input_line_offsets , 4, &input_lines);
  ret |= gpiod_chip_get_lines(chip, output_line_offsets, 4, &output_lines);
  if (ret) {
    perror("Get line failed\n");
    goto release_lines;
  }

  // Setup the configs
  for (i = 0; i < GPIO_WIDTH; i++) {
    input_config[i].consumer       = "gpiotest";
    input_config[i].request_type   = GPIOD_LINE_REQUEST_DIRECTION_INPUT;
    input_config[i].flags          = 0;
    output_config[i].consumer      = "gpiotest";
    output_config[i].request_type  = GPIOD_LINE_REQUEST_DIRECTION_OUTPUT;
    output_config[i].flags         = 0;
  }

  // Set the gpio directions
  ret =  gpiod_line_request_bulk(&input_lines, input_config, values_old);
  ret |= gpiod_line_request_bulk(&output_lines, output_config, values_old);
  if (ret) {
    perror("gpiod_line_request_bulk\n");
    goto release_lines;
  }
 
  // Simple loop to read the switches and write the LEDs
  do {

    ret = get_switches_debounced(&input_lines, values_new);
    if (ret) {
      perror("Get line value failed\n");
      goto release_lines;
    }

    // Print the switches value if there is a change in state
    for (i = 0; i < GPIO_WIDTH; i++) {
      if (!compare_arrays(values_new, values_old, GPIO_WIDTH)) {
        printf("switches = ");
        for (j = 0; j < GPIO_WIDTH; j++) {
          printf("%0x", values_new[GPIO_WIDTH - j - 1]);
          values_old[j] = values_new[j];
        }
        printf("\n");
        break;
      }
    }

    // LEDs are always set to new, regardless if there has been a change or not
    ret = gpiod_line_set_value_bulk(&output_lines, values_new);
    if (ret) {
      perror("Set line value failed\n");
      goto release_lines;
    }
  } while (1);

release_lines:
  gpiod_line_release_bulk(&input_lines);
  gpiod_line_release_bulk(&output_lines);
close_chip:
  gpiod_chip_close(chip);
end:
  return 0;
}