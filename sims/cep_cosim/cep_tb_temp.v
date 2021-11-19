//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      cep_tb_temp.v
// Program:        Common Evaluation Platform (CEP)
// Description:    CEP Co-Simulation Top Level Testbench 
// Notes:          
//
//--------------------------------------------------------------------------------------

`timescale 1ps/100fs

module cep_tb;

 
  parameter   CLKIN_PERIOD          = 5000;
  localparam  RESET_PERIOD          = 200000; // in ps
   

  //--------------------------------------------------------------------------------------
  // Wire Declarations
  //--------------------------------------------------------------------------------------
  reg                 sys_rst_n;
  reg                 sys_clk_i;  
    
  wire                gpio_0_0; pullup (weak1) (gpio_0_0);
  wire                gpio_0_1; pullup (weak1) (gpio_0_1);
  wire                gpio_0_2; pullup (weak1) (gpio_0_2);
  wire                gpio_0_3; pullup (weak1) (gpio_0_3);
  wire                gpio_0_4; pullup (weak1) (gpio_0_4);
  wire                gpio_0_5; pullup (weak1) (gpio_0_5);
  wire                gpio_0_6; pullup (weak1) (gpio_0_6);
  wire                gpio_0_7; pullup (weak1) (gpio_0_7);
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Reset Generation
  //--------------------------------------------------------------------------------------
  initial begin
    sys_rst_n = 1'b0;

    #RESET_PERIOD

    sys_rst_n = 1'b1;
  end
  //--------------------------------------------------------------------------------------

  

  //--------------------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------------------
  initial
    sys_clk_i = 1'b0;
  always
    sys_clk_i = #(CLKIN_PERIOD/2.0) ~sys_clk_i;
  //--------------------------------------------------------------------------------------
   


  //--------------------------------------------------------------------------------------
  // Device Under Test
  //--------------------------------------------------------------------------------------
  ChipTop ChipTop_inst ( 
    .jtag_TCK           (1'b0),
    .jtag_TMS           (1'b0),
    .jtag_TDI           (1'b0),
    .jtag_TDO           (),
    .custom_boot        (1'b0),
    .gpio_0_0           (gpio_0_0),
    .gpio_0_1           (gpio_0_1),
    .gpio_0_2           (gpio_0_2),
    .gpio_0_3           (gpio_0_3),
    .gpio_0_4           (gpio_0_4),
    .gpio_0_5           (gpio_0_5),
    .gpio_0_6           (gpio_0_6),
    .gpio_0_7           (gpio_0_7),
    .uart_0_txd         (),
    .uart_0_rxd         (1'b0),
    .reset_wire_reset   (~sys_rst_n),
    .clock              (sys_clk_i)
  );
  //--------------------------------------------------------------------------------------
   
endmodule
