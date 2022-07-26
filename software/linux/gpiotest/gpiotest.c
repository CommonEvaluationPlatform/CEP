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
#include <ncurses.h>

int main(int argc, char **argv)
{

  char *chipname = "gpiochip0";
  struct gpiod_chip *chip;
  struct gpiod_line_bulk input_lines;
  unsigned int input_line_offsets[] = {8, 9, 10, 11};
  struct gpiod_line_request_config input_config[4];
  struct gpiod_line_bulk output_lines;
  unsigned int output_line_offsets[] = {16, 17, 18, 19};
  struct gpiod_line_request_config output_config[4];
  int values[] = {0, 0, 0, 0};
  int i;
  int ret;
  char ch;

  puts("");
  puts("");
  puts("--------------------------");
  puts("  Linux RISC-V GPIO Test  ");
  puts("--------------------------");
  puts("     Press ^D to exit     ");
  puts("");

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
  for (i = 0; i < 4; i++) {
    input_config[i].consumer       = "gpiotest";
    input_config[i].request_type   = GPIOD_LINE_REQUEST_DIRECTION_INPUT;
    input_config[i].flags          = 0;
    output_config[i].consumer      = "gpiotest";
    output_config[i].request_type  = GPIOD_LINE_REQUEST_DIRECTION_OUTPUT;
    output_config[i].flags         = 0;
  }

  // Set the gpio directions
  ret =  gpiod_line_request_bulk(&input_lines, input_config, values);
  ret |= gpiod_line_request_bulk(&output_lines, output_config, values);
  if (ret) {
    perror("gpiod_line_request_bulk\n");
    goto release_lines;
  }
 
  // Setup ncurses
  initscr();
  nodelay(stdscr, true);
  noecho();

  // Simple loop to read the switches and write the LEDs
  do {
    ch = getch();
    ret = gpiod_line_get_value_bulk(&input_lines, values);
    if (ret) {
      perror("Get line value failed\n");
      goto release_lines;
    }
    printf("switches = %0x %0x %0x %0x\n", values[3], values[2], values[1], values[0]);
    sleep(1);
    ret = gpiod_line_set_value_bulk(&output_lines, values);
    if (ret) {
      perror("Set line value failed\n");
      goto release_lines;
    }
  } while (ch != '^D');

release_lines:
  gpiod_line_release_bulk(&input_lines);
  gpiod_line_release_bulk(&output_lines);
close_chip:
  gpiod_chip_close(chip);
  endwin();
end:
  return 0;
}