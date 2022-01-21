//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      cep_tb.v
// Program:        Common Evaluation Platform (CEP)
// Description:    CEP Co-Simulation Top Level Testbench 
// Notes:          
//
//--------------------------------------------------------------------------------------

`ifndef COSIM_TB_TOP_MODULE
  `define COSIM_TB_TOP_MODULE       cep_tb
`endif

`ifndef CHIPYARD_TOP_MODULE
  `define CHIPYARD_TOP_MODULE       ChipTop
`endif 

`include "suite_config.v"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_cmds.incl"
`include "v2c_top.incl"

`ifndef CLOCK_PERIOD
  `define CLOCK_PERIOD          10
`endif
`ifndef RESET_DELAY
  `define RESET_DELAY           100
`endif

// JTAG related DPI imports
import "DPI-C" function int jtag_getSocketPortId();
import "DPI-C" function int jtag_cmd(input int tdo_in, output int encode);   
import "DPI-C" function int jtag_init();
import "DPI-C" function int jtag_quit();   

// Top Level Testbench Module
module `COSIM_TB_TOP_MODULE;

  //--------------------------------------------------------------------------------------
  // Wire & Reg Declarations
  //--------------------------------------------------------------------------------------
  reg                 sys_rst_n;
  reg                 sys_clk;
  wire                sys_clk_pad;
    
  wire                jtag_TCK; pullup (weak1) (jtag_TCK);
  wire                jtag_TMS; pullup (weak1) (jtag_TMS);
  wire                jtag_TDI; pullup (weak1) (jtag_TDI);
  wire                jtag_TDO;   

  wire                uart_rxd; pullup (weak1) (uart_rxd);
  wire                uart_txd; 

  wire                gpio_0_0; pullup (weak1) (gpio_0_0);
  wire                gpio_0_1; pullup (weak1) (gpio_0_1);
  wire                gpio_0_2; pullup (weak1) (gpio_0_2);
  wire                gpio_0_3; pullup (weak1) (gpio_0_3);
  wire                gpio_0_4; pullup (weak1) (gpio_0_4);
  wire                gpio_0_5; pullup (weak1) (gpio_0_5);
  wire                gpio_0_6; pullup (weak1) (gpio_0_6);
  wire                gpio_0_7; pullup (weak1) (gpio_0_7);

  wire                spi_0_sck; 
  wire                spi_0_cs_0;    
  wire                spi_0_dq_0; pullup (weak1) (spi_0_dq_0);
  wire                spi_0_dq_1; pullup (weak1) (spi_0_dq_1);
  wire                spi_0_dq_2; pullup (weak1) (spi_0_dq_2);
  wire                spi_0_dq_3; pullup (weak1) (spi_0_dq_3);

  reg                 pll_bypass;
  wire                pll_bypass_pad;
  wire                pll_observe;
  //-------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Reset Generation
  //--------------------------------------------------------------------------------------
  initial begin
    sys_rst_n = 1'b0;

    #`RESET_DELAY

    sys_rst_n = 1'b1;
  end
  //--------------------------------------------------------------------------------------

  

  //--------------------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------------------
  initial
    sys_clk = 1'b0;
  always
    sys_clk = #(`CLOCK_PERIOD/2.0) ~sys_clk;
  assign sys_clk_pad = sys_clk;
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // UART Loopback Driver with noise insertion
  //--------------------------------------------------------------------------------------
  reg  noise = 0;
   
  always @(uart_txd) 
  begin
    for (int i = 0; i < 3; i++) begin
      repeat (2) @(posedge sys_clk);
      noise = 1;
      repeat (2) @(posedge sys_clk);
      noise = 0;
    end
  end
  assign uart_rxd = uart_txd ^ noise;
  //--------------------------------------------------------------------------------------
  
  
  
  //--------------------------------------------------------------------------------------
  // SPI loopback instantiation
  //--------------------------------------------------------------------------------------
  spi_loopback spi_loopback_inst (
    .SCK    (spi_0_sck   ),
    .CS_n   (spi_0_dq_3  ),
    .MOSI   (spi_0_cs_0  ),
    .MISO   (spi_0_dq_0  ) 
  );
  //--------------------------------------------------------------------------------------

   
 
  //--------------------------------------------------------------------------------------
  // Device Under Test
  //
  // I/O manually copied from Chisel generated verilog
  //--------------------------------------------------------------------------------------

  // Force CHIP_ID's when operating in BFM_MODE (otherwise these parameters don't exist)
  `ifdef BFM_MODE
    defparam `TILE0_TL_PATH.CHIP_ID = 0;
    defparam `TILE1_TL_PATH.CHIP_ID = 1;
    defparam `TILE2_TL_PATH.CHIP_ID = 2;
    defparam `TILE3_TL_PATH.CHIP_ID = 3;
  `endif

  initial begin
  `ifdef BYPASS_PLL
    `logI("PLL is set to bypass mode");
    pll_bypass = 1'b1;
  `else
    `logI("PLL is set to normal mode");
    pll_bypass = 1'b0;
  `endif
  end
  assign  pll_bypass_pad  = pll_bypass;

  `CHIPYARD_TOP_MODULE `DUT_INST ( 
    .jtag_TCK           (jtag_TCK),
    .jtag_TMS           (jtag_TMS),
    .jtag_TDI           (jtag_TDI),
    .jtag_TDO           (jtag_TDO),
    .spi_0_sck          (spi_0_sck),
    .spi_0_cs_0         (spi_0_cs_0),
    .spi_0_dq_0         (spi_0_dq_0),
    .spi_0_dq_1         (spi_0_dq_1),
    .spi_0_dq_2         (spi_0_dq_2),
    .spi_0_dq_3         (spi_0_dq_3),
    .test_mode_0        (),
    .test_mode_1        (),
    .test_mode_2        (),
    .test_mode_3        (),
    .test_io_0          (),
    .test_io_1          (),
    .test_io_2          (),
    .test_io_3          (),
    .test_io_4          (),
    .test_io_5          (),
    .test_io_6          (),
    .test_io_7          (),
    .test_io_8          (),
    .test_io_9          (),
    .test_io_10         (),
    .test_io_11         (),
    .test_io_12         (),
    .test_io_13         (),
    .test_io_14         (),
    .test_io_15         (),
    .gpio_0_0           (gpio_0_0),
    .gpio_0_1           (gpio_0_1),
    .gpio_0_2           (gpio_0_2),
    .gpio_0_3           (gpio_0_3),
    .gpio_0_4           (gpio_0_4),
    .gpio_0_5           (gpio_0_5),
    .gpio_0_6           (gpio_0_6),
    .gpio_0_7           (gpio_0_7),
    .uart_0_txd         (uart_txd),
    .uart_0_rxd         (uart_rxd),
    .reset              (~sys_rst_n),
    .clock              (sys_clk_pad),
    .pll_bypass         (pll_bypass_pad),
    .pll_observe        (pll_observe)
  );
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Instantiation of the System and CPU Drivers
  //--------------------------------------------------------------------------------------
  reg [3:0]   enableMask = 0;
  wire [3:0]  passMask;

  // Enable all the CPU Drivers
  initial begin
    #1 enableMask = 'hF;
  end
  
 genvar c;
  generate
    for (c = 0; c < `MAX_CORES; c++) begin : cpuId
      cpu_driver #(
        .MY_SLOT_ID   (0),
        .MY_CPU_ID    (c)
      ) driver (
        .clk          (sys_clk        ),  
        .enableMe     (enableMask[c]  )
      );

      assign passMask[c] = driver.PassStatus;
    end // end for
  endgenerate

  // Instantiate the "System" driver (which is ALWAYS enabled)
  system_driver #(
        .MY_SLOT_ID   (`SYSTEM_SLOT_ID),
        .MY_CPU_ID    (`SYSTEM_CPU_ID)
  ) system_driver (
    .clk        (sys_clk),
    .enableMe   (1'b1)
  );
  //--------------------------------------------------------------------------------------
  


  //--------------------------------------------------------------------------------------
  // OpenOCD interface to drive JTAG via DPI
  //--------------------------------------------------------------------------------------
  reg         enable_jtag     = 0;
  reg         quit_jtag       = 0;  
  reg         enableDel       = 0;
  reg [15:0]  clkCnt;
  int         junk;
  int         jtag_encode;
  wire        dpi_jtag_tdo    = jtag_TDO;
   
  always @(posedge `DVT_FLAG[`DVTF_ENABLE_REMOTE_BITBANG_BIT]) begin
    enable_jtag = 1;
    @(negedge `DVT_FLAG[`DVTF_ENABLE_REMOTE_BITBANG_BIT]);
    quit_jtag = 1;
  end

  `ifdef OPENOCD_ENABLE
    always @(posedge passMask[3]) begin
      repeat (40000) @(posedge sys_clk);
      `logI("Initialting QUIT to close socket...");
      junk = jtag_quit();
    end

    initial begin
      junk = jtag_init();
      jtag_TRSTn = 0;
      repeat (20) @(posedge sys_clk);
      jtag_TRSTn = 1;
      repeat (20) @(posedge sys_clk);
      jtag_TRSTn = 0;
    end

    always @(posedge sys_clk) begin
      if (sys_rst) begin
        enableDel   <= 0;
        clkCnt      <= 5;
      end else begin
        enableDel   <= enable_jtag;
        if (enableDel) begin
          clkCnt    <= clkCnt - 1;
        
          if (clkCnt == 0) begin
            clkCnt    <= 5;
        
            if (!quit_jtag) begin
              junk                                    = jtag_cmd(dpi_jtag_tdo, jtag_encode);
              {jtag_TRSTn,jtag_TCK,jtag_TMS,jtag_TDI} = jtag_encode ^ 'h8; // flip the TRSN
            end  // if (!quit_jtag)
          end // if (clkCnt == 0)
        end // if (enable && init_done_sticky)
      end // else: !if(reset || r_reset)
    end // always @ (posedge clock)
  `endif   
  //--------------------------------------------------------------------------------------
  


  //--------------------------------------------------------------------------------------
  // When operating in Virtual mode, instantiate the page table walker monitor modules
  //--------------------------------------------------------------------------------------
  `ifdef VIRTUAL_MODE
    ptw_monitor ptwC0R0 (
      .clk                                  (`CORE0_PATH.ptw.clock                              ),
      .trace_valid                          (`CORE0_PATH.core.csr_io_trace_0_valid              ),
      .pc_valid                             (`CORE0_PATH.core.coreMonitorBundle_valid           ),
      .pc                                   (`CORE0_PATH.core.coreMonitorBundle_pc              ),
      .io_requestor_x_req_ready             (`CORE0_PATH.ptw.io_requestor_0_req_ready           ),
      .io_requestor_x_req_valid             (`CORE0_PATH.ptw.io_requestor_0_req_valid           ),
      .io_requestor_x_req_bits_bits_addr    (`CORE0_PATH.ptw.io_requestor_0_req_bits_bits_addr  ),
      .io_requestor_x_resp_valid            (`CORE0_PATH.ptw.io_requestor_0_resp_valid          ),
      .io_requestor_x_resp_bits_ae          (`CORE0_PATH.ptw.io_requestor_0_resp_bits_ae        ),
      .io_requestor_x_resp_bits_pte_ppn     (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_ppn   ),
      .io_requestor_x_resp_bits_pte_d       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_d     ),
      .io_requestor_x_resp_bits_pte_a       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_a     ),
      .io_requestor_x_resp_bits_pte_g       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_g     ),
      .io_requestor_x_resp_bits_pte_u       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_u     ),
      .io_requestor_x_resp_bits_pte_x       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_x     ),
      .io_requestor_x_resp_bits_pte_w       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_w     ),
      .io_requestor_x_resp_bits_pte_r       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_r     ),
      .io_requestor_x_resp_bits_pte_v       (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_v     )
    );

    ptw_monitor ptwC0R1 (
      .clk                                  (`CORE0_PATH.ptw.clock                              ),
      .trace_valid                          (1'b0                                               ),
      .pc_valid                             (1'b0                                               ),
      .pc                                   (64'h0                                              ),
      .io_requestor_x_req_ready             (`CORE0_PATH.ptw.io_requestor_1_req_ready           ),
      .io_requestor_x_req_valid             (`CORE0_PATH.ptw.io_requestor_1_req_valid           ),
      .io_requestor_x_req_bits_bits_addr    (`CORE0_PATH.ptw.io_requestor_1_req_bits_bits_addr  ),
      .io_requestor_x_resp_valid            (`CORE0_PATH.ptw.io_requestor_1_resp_valid          ),
      .io_requestor_x_resp_bits_ae          (`CORE0_PATH.ptw.io_requestor_1_resp_bits_ae        ),
      .io_requestor_x_resp_bits_pte_ppn     (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_ppn   ),
      .io_requestor_x_resp_bits_pte_d       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_d     ),
      .io_requestor_x_resp_bits_pte_a       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_a     ),
      .io_requestor_x_resp_bits_pte_g       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_g     ),
      .io_requestor_x_resp_bits_pte_u       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_u     ),
      .io_requestor_x_resp_bits_pte_x       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_x     ),
      .io_requestor_x_resp_bits_pte_w       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_w     ),
      .io_requestor_x_resp_bits_pte_r       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_r     ),
      .io_requestor_x_resp_bits_pte_v       (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_v     )
    );
  `endif
  //--------------------------------------------------------------------------------------
   
endmodule  // `COSIM_TB_TOP_MODULE
