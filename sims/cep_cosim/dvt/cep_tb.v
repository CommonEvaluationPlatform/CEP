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

`timescale 1ns/10ps

`ifndef COSIM_TB_TOP_MODULE
  `define COSIM_TB_TOP_MODULE       cep_tb
`endif

`ifndef CHIPYARD_TOP_MODULE
  `define CHIPYARD_TOP_MODULE       ChipTop
`endif 

`ifndef CHIPYARD_TOP_MODULE_inst
  `define CHIPYARD_TOP_MODULE_inst  `CHIPYARD_TOP_MODULE\_inst
`endif 

`include "suite_config.v"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_cmds.incl"
`include "v2c_top.incl"

`ifndef CLOCK_PERIOD
  `define CLOCK_PERIOD          5000
`endif
`ifndef RESET_DELAY
  `define RESET_DELAY           777.7
`endif

// JTAG related DPI imports
import "DPI-C" function int jtag_getSocketPortId();
import "DPI-C" function int jtag_cmd(input int tdo_in, output int encode);   
import "DPI-C" function int jtag_init();
import "DPI-C" function int jtag_quit();   

module `COSIM_TB_TOP_MODULE;

  //--------------------------------------------------------------------------------------
  // Wire & Reg Declarations
  //--------------------------------------------------------------------------------------
  reg                 sys_rst_n;
  reg                 sys_clk_i;  
    
  wire                jtag_TCK;
  wire                jtag_TMS;
  wire                jtag_TDI;
  wire                jtag_TDO;   

  wire                uart_rxd; pullup (weak1) (uart_rxd);
  wire                uart_txd; 

  wire                sdio_sdio_clk; 
  wire                sdio_sdio_cmd;    
  wire                sdio_sdio_dat_0; pullup (weak1) (sdio_sdio_dat_0);
  wire                sdio_sdio_dat_1; pullup (weak1) (sdio_sdio_dat_1);
  wire                sdio_sdio_dat_2; pullup (weak1) (sdio_sdio_dat_2);   
  wire                sdio_sdio_dat_3; pullup (weak1) (sdio_sdio_dat_3);
  //--------------------------------------------------------------------------------------



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
    sys_clk_i = 1'b0;
  always
    sys_clk_i = #(`CLOCK_PERIOD/2.0) ~sys_clk_i;
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // UART Loopback Driver with noise insertion
  //--------------------------------------------------------------------------------------
  reg  noise = 0;
   
  always @(uart_txd) 
  begin
    for (int i = 0; i < 3; i++) begin
      repeat (2) @(posedge sys_clk_i);
      noise = 1;
      repeat (2) @(posedge sys_clk_i);
      noise = 0;
    end
  end
  assign uart_rxd = uart_txd ^ noise;
  //--------------------------------------------------------------------------------------
  


  //--------------------------------------------------------------------------------------
  // SPI loopback instantiation
  //--------------------------------------------------------------------------------------
  spi_loopback spi_loopback_inst (
    .SCK    (sdio_sdio_clk  ),
    .CS_n   (sdio_sdio_dat_3),
    .MOSI   (sdio_sdio_cmd  ),
    .MISO   (sdio_sdio_dat_0) 
  );
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // C <--> Verilog Deamon and backdoor support are here
  //--------------------------------------------------------------------------------------
  wire [31:0] __simTime;

  always @(posedge `DVT_FLAG[`DVTF_TOGGLE_CHIP_RESET_BIT]) 
  begin
    wait (`PBUS_RESET==0);
    @(negedge `PBUS_CLOCK);
    #2000;
    `logI("Asserting pbus_Reset");
    force `PBUS_RESET = 1;
    repeat (10) @(negedge `PBUS_CLOCK);
    #2000;
    release `PBUS_RESET;      
    `DVT_FLAG[`DVTF_TOGGLE_CHIP_RESET_BIT] = 0;
  end // always @(posedge `DVT_FLAG[`DVTF_TOGGLE_CHIP_RESET_BIT]) 

  always @(posedge `DVT_FLAG[`DVTF_TOGGLE_DMI_RESET_BIT]) 
  begin
    `logI("Forcing topMod_debug_ndreset");
    force `DEBUG_NDRESET = 1;
    repeat (10) @(negedge `PBUS_CLOCK);
    release `DEBUG_NDRESET;
    `DVT_FLAG[`DVTF_TOGGLE_DMI_RESET_BIT] = 0;
  end // always @(posedge `DVT_FLAG[`DVTF_TOGGLE_DMI_RESET_BIT]) 

  always @(posedge `DVT_FLAG[`DVTF_GET_SOCKET_ID_BIT]) 
  begin
    `logI("DVTF_GET_SOCKET_ID_BIT");
    `ifdef OPENOCD_ENABLE
      `DVT_FLAG[`DVTF_PAT_HI:`DVTF_PAT_LO] = jtag_getSocketPortId();
    `endif
    `logI("SocketId=0x%08x",`DVT_FLAG[`DVTF_PAT_HI:`DVTF_PAT_LO]);
    `DVT_FLAG[`DVTF_GET_SOCKET_ID_BIT] = 0;
  end // always @(posedge `DVT_FLAG[`DVTF_GET_SOCKET_ID_BIT])

  v2c_top v2c_inst(.clk(sys_clk_i),.__simTime(__simTime));

  // Force CHIP_ID's when operating in BFM_MODE (otherwise these parameters don't exist)
  `ifdef BFM_MODE
    defparam `CORE0_TL_PATH.CHIP_ID = 0;
    defparam `CORE1_TL_PATH.CHIP_ID = 1;
    defparam `CORE2_TL_PATH.CHIP_ID = 2;
    defparam `CORE3_TL_PATH.CHIP_ID = 3;
  `endif
  //--------------------------------------------------------------------------------------

   

  //--------------------------------------------------------------------------------------
  // Initialize the FIR memories Note: the IIR memories are NOT initialized)
  //--------------------------------------------------------------------------------------
  initial begin
    
    for (int j = 0; j < 32; j = j + 1) begin
      `FIR_PATH.datain_mem[j]   = 0;  
      `FIR_PATH.dataout_mem[j]  = 0;
    end

   end // initial begin
  //--------------------------------------------------------------------------------------



   //
   //===========================================================================   
   // Load the bare_boot.hex into boot rom
   //===========================================================================      
   //
   reg [256*8 - 1:0] path;
   initial begin
      repeat (100) @(posedge sys_clk_i);
      path = "../../../hdl_cores/freedom/builds/vc707-u500devkit/sdboot_fpga_sim.hex";
      //
      `logI("=== Overriding bootROm with file %s ==",path);      
      $readmemh(path, `BOOTROM_PATH.rom);
      // also add 0x600DBABE_12345678 at end of the ROM for testing
      `BOOTROM_PATH.rom[`bootrom_base_test_offs]   = `bootrom_known_pat1; //'h600DBABE; // LSW
      `BOOTROM_PATH.rom[`bootrom_base_test_offs+1] = `bootrom_known_pat0; //'h12345678; // MSW
   end
   
  //===========================================================================
  // Device Under Test
  //
  // I/O manually copied from Chisel generated verilog
  //===========================================================================
  `CHIPYARD_TOP_MODULE `CHIPYARD_TOP_MODULE_inst ( 
    .jtag_TCK           (jtag_TCK),
    .jtag_TMS           (jtag_TMS),
    .jtag_TDI           (jtag_TDI),
    .jtag_TDO           (jtag_TDO),
    .custom_boot        (),
    .gpio_0_0           (),
    .gpio_0_1           (),
    .gpio_0_2           (),
    .gpio_0_3           (),
    .gpio_0_4           (),
    .gpio_0_5           (),
    .gpio_0_6           (),
    .gpio_0_7           (),
    .uart_0_txd         (uart_txd),
    .uart_0_rxd         (uart_rxd),
    .reset_wire_reset   (~sys_rst_n),
    .clock              (sys_clk_i)
  );

  //**************************************************************************//
  // Memory Models instantiations
  //**************************************************************************//
  reg   enableWrTrace   = 0;
  reg   enableRdTrace   = 0;   
  reg   calib_done      = 0;

  always @(posedge `DVT_FLAG[`DVTF_DISABLE_MAIN_MEM_LOGGING]) begin
    enableWrTrace = 0;
    enableRdTrace = 0;      
    `DVT_FLAG[`DVTF_DISABLE_MAIN_MEM_LOGGING] = 0;
  end
  always @(posedge `DVT_FLAG[`DVTF_ENABLE_MAIN_MEM_LOGGING]) begin
    enableWrTrace = 1;
    enableRdTrace = 1;            
    `DVT_FLAG[`DVTF_ENABLE_MAIN_MEM_LOGGING] = 0;
  end
  always @(posedge `DVT_FLAG[`DVTF_ENABLE_MAIN_MEMWR_LOGGING]) begin
    enableWrTrace = 1;
    `DVT_FLAG[`DVTF_ENABLE_MAIN_MEMWR_LOGGING] = 0;
  end
  always @(posedge `DVT_FLAG[`DVTF_ENABLE_MAIN_MEMRD_LOGGING]) begin
    enableRdTrace = 1;            
    `DVT_FLAG[`DVTF_ENABLE_MAIN_MEMRD_LOGGING] = 0;
  end
  
  reg migRdTrace = 0;
  reg migWrTrace = 0;

  always @(posedge `DVT_FLAG[`DVTF_ENABLE_MIG_MEMRD_LOGGING]) begin
    migRdTrace = 1;            
    `DVT_FLAG[`DVTF_ENABLE_MIG_MEMRD_LOGGING] = 0;
  end
  always @(posedge `DVT_FLAG[`DVTF_ENABLE_MIG_MEMWR_LOGGING]) begin
    migWrTrace = 1;            
    `DVT_FLAG[`DVTF_ENABLE_MIG_MEMWR_LOGGING] = 0;
  end         

   
  //***************************************************************************
  // Reporting the test case status
  // Status reporting logic exists both in simulation test bench (sim_tb_top)
  // and sim.do file for ModelSim. Any update in simulation run time or time out
  // in this file need to be updated in sim.do file as well.
  //***************************************************************************


   //
   // The driver
   //
   //
   reg [3:0] enableMask = 0;
   wire [3:0] passMask;
   initial begin
      #1 enableMask = 'hF; // or contrtol from C side
   end
   genvar c;
   always @(passMask) begin
      `logI("**** passMask=0x%x *****\n",passMask);
   end
   generate
      for (c=0;c<4;c=c+1) begin : driverX  
   cep_driver #(.MY_SLOT_ID(0),.MY_LOCAL_ID(c))
   driver(
    .clk    (sys_clk_i), // clk100),   
    .reset          (~sys_rst_n),
    .enableMe       (enableMask[c]),
    .__simTime  ()
    );
   assign passMask[c] = driver.PassStatus;
      end
   endgenerate

   //
   // =============================
   // OpenOCD interface to drive JTAG via DPI
   // =============================   
   //
   reg        enable_jtag=0;
   reg        quit_jtag=0;  
   reg        enableDel = 0;
   int        junk;
   int        jtag_encode;
   wire       dpi_jtag_tdo = jtag_TDO;
   
   always @(posedge `DVT_FLAG[`DVTF_ENABLE_REMOTE_BITBANG_BIT]) begin
      enable_jtag=1;
      @(negedge `DVT_FLAG[`DVTF_ENABLE_REMOTE_BITBANG_BIT]);
      quit_jtag=1;
   end
`ifdef OPENOCD_ENABLE
   always @(posedge passMask[3]) begin
      repeat (40000) @(posedge sys_clk_i);
      `logI("Initialting QUIT to close socket...");
      junk = jtag_quit();
   end
   //
   reg [15:0]   clkCnt;
   initial begin
      junk = jtag_init();
      jtag_TRSTn = 0;
      repeat (20) @(posedge sys_clk_i);
      jtag_TRSTn = 1;
      repeat (20) @(posedge sys_clk_i);
      jtag_TRSTn = 0;
   end

   always @(posedge sys_clk_i) begin
      if (sys_rst) begin
   enableDel <= 0;
   clkCnt <= 5;
      end else begin
   enableDel <= enable_jtag;
         if (enableDel) begin
            clkCnt <= clkCnt - 1;
      if (clkCnt == 0) begin
         clkCnt <= 5;
               if (!quit_jtag) begin
      junk = jtag_cmd(dpi_jtag_tdo, // see bug
          jtag_encode);
      {jtag_TRSTn,jtag_TCK,jtag_TMS,jtag_TDI} = jtag_encode ^ 'h8; // flip the TRSN
               end
      end // if (clkCnt == 0)
         end // if (enable && init_done_sticky)
      end // else: !if(reset || r_reset)
   end // always @ (posedge clock)
`endif   
   
   //
   //
   //
   initial begin
      // no secure mode
      @(posedge `MODEXP_RESET_N);
      @(posedge `MODEXP_CLK);
      `MODEXP_EXP_MODE_REG = 1;
   end
   //
   //
   //
   reg [`DVTF_FIR_CAPTURE_EN_BIT:`DVTF_AES_CAPTURE_EN_BIT] c2c_capture_enable=0;
   reg                 srot_start_capture = 0;
   reg                 srot_stop_capture = 0;
   reg                 srot_capture_done = 0;   
   
   //
   `include "aes_capture.incl"
   `include "sha256_capture.incl"
   `include "md5_capture.incl"
   `include "rsa_capture.incl"
   `include "des3_capture.incl"
   `include "gps_capture.incl"
   `include "dft_capture.incl"
   `include "idft_capture.incl"
   `include "iir_capture.incl"
   `include "fir_capture.incl"                     
   `include "srot_capture.incl"


   // When operating in Virtual mode, instantiate the page table walker monitor modules
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
      .io_requestor_x_resp_bits_pte_v     (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_v       )
    );
  `endif
   
endmodule  // `COSIM_TB_TOP_MODULE
