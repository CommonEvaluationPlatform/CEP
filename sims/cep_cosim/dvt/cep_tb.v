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
`include "v2c_cmds.incl"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_top.incl"
`include "config.v"

// JTAG related DPI imports
import "DPI-C" function int jtag_getSocketPortId();
import "DPI-C" function int jtag_cmd(input int tdo_in, output int encode);   
import "DPI-C" function int jtag_init();
import "DPI-C" function int jtag_quit();   

`timescale 1ps/100fs

module cep_tb;

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   parameter COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
   parameter DM_WIDTH              = 8;
                                     // # of DM (data mask)
   parameter DQ_WIDTH              = 64;
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 8;
   parameter DQS_CNT_WIDTH         = 3;
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter ECC                   = "OFF";
   parameter RANKS                 = 1;
                                     // # of Ranks.
   parameter ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter ROW_WIDTH             = 14;
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 28;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   parameter CA_MIRROR             = "OFF";
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
                                     // Input Clock Period


   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter TCQ                   = 100;
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter RST_ACT_LOW           = 0;
                                     // =1 for active low reset,
                                     // =0 for active high.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0;
                                     // IODELAYCTRL reference clock frequency
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter tCK                   = 1250;
                                     // memory tCK paramter.
                     // # = Clock Period in pS.
   parameter nCK_PER_CLK           = 4;
                                     // # of memory CKs per fabric CLK

   
   //***************************************************************************
   // AXI4 Shim parameters
   //***************************************************************************
   parameter C_S_AXI_ID_WIDTH              = 4;
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 30;
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 64;
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1


   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DRAM_TYPE             = "DDR3";

    

  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//

  localparam real TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam MEMORY_WIDTH            = 8;
  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;
  localparam ECC_TEST         = "OFF" ;
  localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;
  
  parameter   CLKIN_PERIOD          = 5000;
  localparam  RESET_PERIOD          = 200000; // in ps
   

  //--------------------------------------------------------------------------------------
  // Wire Declarations
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
  ChipTop ChipTop_inst ( 
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
   always @(posedge `MIG_PATH.init_calib_complete) begin
      $display("%t Calibration Done",$time);
      calib_done = 1;
   end

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
   //
   reg migRdTrace = 0;
   reg migWrTrace = 0;
   //
   always @(posedge `DVT_FLAG[`DVTF_ENABLE_MIG_MEMRD_LOGGING]) begin
      migRdTrace = 1;            
      `DVT_FLAG[`DVTF_ENABLE_MIG_MEMRD_LOGGING] = 0;
   end
   always @(posedge `DVT_FLAG[`DVTF_ENABLE_MIG_MEMWR_LOGGING]) begin
      migWrTrace = 1;            
      `DVT_FLAG[`DVTF_ENABLE_MIG_MEMWR_LOGGING] = 0;
   end         

   reg program_loaded = 0;
   int save_memory_used = 0;
   task putback_memory_used;
      begin
   `logI("Putback Memory Used=%d from %d",save_memory_used,mem_rnk[0].gen_mem[0].ddr3.memory_used);
   mem_rnk[0].gen_mem[0].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[1].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[2].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[3].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[4].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[5].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[6].ddr3.memory_used = save_memory_used;
   mem_rnk[0].gen_mem[7].ddr3.memory_used = save_memory_used;  
      end
   endtask
   always @(posedge `DVT_FLAG[`DVTF_PROGRAM_LOADED]) begin
      program_loaded = 1;
      save_memory_used = mem_rnk[0].gen_mem[0].ddr3.memory_used;
      //`DVT_FLAG[`DVTF_PROGRAM_LOADED] = 0;
   end
   wire memRdEdge = migRdTrace && `DDR_PATH.auto_buffer_in_a_valid && (`DDR_PATH.auto_buffer_in_a_bits_opcode == 4);
   wire memWrEdge = migWrTrace && `DDR_PATH.auto_buffer_in_a_valid && (`DDR_PATH.auto_buffer_in_a_bits_opcode == 0);   
   
   always @(posedge memRdEdge) begin
      `logI("memRead  @0x%08x",`DDR_PATH.auto_buffer_in_a_bits_address);
   end
   always @(posedge memWrEdge) begin
      `logI("memWrite \t@0x%08x",`DDR_PATH.auto_buffer_in_a_bits_address);
   end   
   //
   // always at the command line
//   `define den1024Mb
   wire [CS_WIDTH*NUM_COMP-1:0] ddr3MemWr;
   reg [CS_WIDTH*NUM_COMP-1:0]  dq_in_valid_del=0;
   //
  genvar r,i;
  generate
    for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
      for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
   defparam ddr3.DEBUG=0;
   defparam ddr3.check_strict_mrbits=0;
   defparam ddr3.check_strict_timing=0;
   defparam ddr3.MEM_BITS= 16; // some how the new RISC (v2.6) has a lot more writes (14->16)    
   defparam ddr3.TWLS = 2; // to remove the WARNING violation which can't be turned off from outside
   defparam ddr3.TWLH = 2; // to remove the WARNING violation   
   // for RHEL7: access beyond 1G ????
   defparam ddr3.STOP_ON_ERROR = 0;
   //
   // Write Monitor
   //
   always @(negedge ddr3.ck) begin   
      dq_in_valid_del[(r*CS_WIDTH)+i] = ddr3.dq_in_valid; // delay version
   end
   assign ddr3MemWr[(r*CS_WIDTH)+i] = enableWrTrace && ddr3.ck && dq_in_valid_del[(r*CS_WIDTH)+i] && ((ddr3.burst_cntr % ddr3.BL_MIN) == 0);
   always @(posedge ddr3MemWr[(r*CS_WIDTH)+i]) begin
      if (ddr3MemWr[(r*CS_WIDTH)+i]) begin
         `logI("MemWr: @0x%x (%x/%x/%x) =0x%x",{ddr3.memory_write.bank, ddr3.memory_write.row, ddr3.memory_write.col}*8,
         ddr3.memory_write.bank,ddr3.memory_write.row,ddr3.memory_write.col,ddr3.memory_write.data);
      end
   end
   //
   //
   //
   always @(posedge `DVT_FLAG[`DVTF_SET_DEFAULTX_BIT]) begin
      #1;
      ddr3.defx = `DVT_FLAG[`DVTF_PAT_LO];
      `logI("== Setting default pattern for unused main memory to %d==",ddr3.defx);
      `DVT_FLAG[`DVTF_SET_DEFAULTX_BIT] = 0;
   end
   //
         ddr3 ddr3
          (
           .rst_n   (ddr3_reset_n),
           .ck      (ddr3_ck_p_sdram[(i*MEMORY_WIDTH)/72]),
           .ck_n    (ddr3_ck_n_sdram[(i*MEMORY_WIDTH)/72]),
           .cke     (ddr3_cke_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
           .cs_n    (ddr3_cs_n_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
           .ras_n   (ddr3_ras_n_sdram),
           .cas_n   (ddr3_cas_n_sdram),
           .we_n    (ddr3_we_n_sdram),
           .dm_tdqs (ddr3_dm_sdram[i]),
           .ba      (ddr3_ba_sdram[r]),
           .addr    (ddr3_addr_sdram[r]),
           .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
           .dqs     (ddr3_dqs_p_sdram[i]),
           .dqs_n   (ddr3_dqs_n_sdram[i]),
           .tdqs_n  (),
//     .enableRdTrace(enableRdTrace && calib_done),
//     .enableWrTrace(enableWrTrace && calib_done),    
           .odt     (ddr3_odt_sdram[((i*MEMORY_WIDTH)/72)+(1*r)])
           );
      end
    end
  endgenerate

   // backdoor load
   // for 1G
   localparam BA_BITS          =       3;
   localparam ROW_BITS         =      14;
   localparam COL_BITS         =      10;
   reg [63:0] cache [7:0] ; // 64 bytes
   
   task   write_ddr3_backdoor;
      input [31:0] a;
      input [63:0] d;
      reg [BA_BITS-1:0] bank;
      reg [ROW_BITS-1:0] row;
      reg [COL_BITS-1:0] col;
      reg [63:0]   mask;
      
      begin
   if (calib_done == 0) @(posedge calib_done); // wait as soon as it is done
   //
   // put in the cache (little endian on 4-bytes (32-bits)
   //
   mask = 'hFF << (a[5:3]*8);
   cache[7] = (cache[7] & ~mask) | (d[63:56] << (a[5:3]*8));
   cache[6] = (cache[6] & ~mask) | (d[55:48] << (a[5:3]*8));
   cache[5] = (cache[5] & ~mask) | (d[47:40] << (a[5:3]*8));
   cache[4] = (cache[4] & ~mask) | (d[39:32] << (a[5:3]*8));
   //
   cache[3] = (cache[3] & ~mask) | (d[31:24] << (a[5:3]*8));
   cache[2] = (cache[2] & ~mask) | (d[23:16] << (a[5:3]*8));
   cache[1] = (cache[1] & ~mask) | (d[15:8]  << (a[5:3]*8));
   cache[0] = (cache[0] & ~mask) | (d[7:0]   << (a[5:3]*8));
   //
   // flush when got the whole cahce   
   //
   if (a[5:3] == 3'h7) begin // end of cache line
      `logI("== Backdooring adr=0x%x data=0x%x",a,d);
      {bank,row,col} = {a[29:6],3'b0}; // cache line
      //
      mem_rnk[0].gen_mem[0].ddr3.memory_write(bank,row,col,cache[0]);   
      mem_rnk[0].gen_mem[1].ddr3.memory_write(bank,row,col,cache[1]);
      mem_rnk[0].gen_mem[2].ddr3.memory_write(bank,row,col,cache[2]);
      mem_rnk[0].gen_mem[3].ddr3.memory_write(bank,row,col,cache[3]);
      mem_rnk[0].gen_mem[4].ddr3.memory_write(bank,row,col,cache[4]);
      mem_rnk[0].gen_mem[5].ddr3.memory_write(bank,row,col,cache[5]);
      mem_rnk[0].gen_mem[6].ddr3.memory_write(bank,row,col,cache[6]);
      mem_rnk[0].gen_mem[7].ddr3.memory_write(bank,row,col,cache[7]);
   end // if (a[5:3] == 3'h7)
      end
   endtask // WRITE32_64_TASK

   task   read_ddr3_backdoor;
      input [31:0] a;
      output [63:0] d;
      reg [BA_BITS-1:0] bank;
      reg [ROW_BITS-1:0] row;
      reg [COL_BITS-1:0] col;
      reg [63:0]   mask;      
      begin
   //
   {bank,row,col} = {a[29:6],3'b0}; // cache line
   //
   mem_rnk[0].gen_mem[0].ddr3.memory_read(bank,row,col,cache[0]);   
   mem_rnk[0].gen_mem[1].ddr3.memory_read(bank,row,col,cache[1]);
   mem_rnk[0].gen_mem[2].ddr3.memory_read(bank,row,col,cache[2]);
   mem_rnk[0].gen_mem[3].ddr3.memory_read(bank,row,col,cache[3]);
   mem_rnk[0].gen_mem[4].ddr3.memory_read(bank,row,col,cache[4]);
   mem_rnk[0].gen_mem[5].ddr3.memory_read(bank,row,col,cache[5]);
   mem_rnk[0].gen_mem[6].ddr3.memory_read(bank,row,col,cache[6]);
   mem_rnk[0].gen_mem[7].ddr3.memory_read(bank,row,col,cache[7]);
   // shift
   d[63:56] = (cache[7] >> (a[5:3]*8));
   d[55:48] = (cache[6] >> (a[5:3]*8));
   d[47:40] = (cache[5] >> (a[5:3]*8));
   d[39:32] = (cache[4] >> (a[5:3]*8));
            
   d[31:24] = (cache[3] >> (a[5:3]*8));
   d[23:16] = (cache[2] >> (a[5:3]*8));
   d[15:8]  = (cache[1] >> (a[5:3]*8));
   d[7:0]   = (cache[0] >> (a[5:3]*8));
   //
   //`logI("== Backdooring adr=0x%x data=0x%x",a,d);
      end
   endtask // for

   task read_ddr3_cache_n_clear;
      input [31:0] a;
      output [(64*8)-1:0] pbuf;
      //
      reg [BA_BITS-1:0] bank;
      reg [ROW_BITS-1:0] row;
      reg [COL_BITS-1:0] col;
      reg [63:0]   d64;
      integer i;
      
      begin
   //
   {bank,row,col} = {a[29:6],3'b0}; // cache line
   //
   mem_rnk[0].gen_mem[0].ddr3.memory_read(bank,row,col,cache[0]);   
   mem_rnk[0].gen_mem[1].ddr3.memory_read(bank,row,col,cache[1]);
   mem_rnk[0].gen_mem[2].ddr3.memory_read(bank,row,col,cache[2]);
   mem_rnk[0].gen_mem[3].ddr3.memory_read(bank,row,col,cache[3]);
   mem_rnk[0].gen_mem[4].ddr3.memory_read(bank,row,col,cache[4]);
   mem_rnk[0].gen_mem[5].ddr3.memory_read(bank,row,col,cache[5]);
   mem_rnk[0].gen_mem[6].ddr3.memory_read(bank,row,col,cache[6]);
   mem_rnk[0].gen_mem[7].ddr3.memory_read(bank,row,col,cache[7]);
   //
   mem_rnk[0].gen_mem[0].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[1].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[2].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[3].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[4].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[5].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[6].ddr3.memory_write(bank,row,col,0);
   mem_rnk[0].gen_mem[7].ddr3.memory_write(bank,row,col,0);  
   // fill the buffer
   for (i=0;i<8;i=i+1) begin
      // shift
      d64[63:56] = (cache[0] >> (i*8));
      d64[55:48] = (cache[1] >> (i*8));
      d64[47:40] = (cache[2] >> (i*8));
      d64[39:32] = (cache[3] >> (i*8));
      //
      d64[31:24] = (cache[4] >> (i*8));
      d64[23:16] = (cache[5] >> (i*8));
      d64[15:8]  = (cache[6] >> (i*8));
      d64[7:0]   = (cache[7] >> (i*8));
      pbuf = (pbuf << 64) | d64;
   end
      end
   endtask // for
   
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
   wire       dpi_jtag_tdo = jtag_jtag_TDO;
   
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
   //
   `include "srot_capture.incl"

   //
   // Virtual mode
   //
`ifdef VIRTUAL_MODE
ptw_monitor ptwC0R0
  (
   .clk         (`CORE0_PATH.ptw.clock        ),
   .trace_valid                         (`CORE0_PATH.core.csr_io_trace_0_valid   ),
   .pc_valid                            (`CORE0_PATH.core.coreMonitorBundle_valid),
   .pc                                  (`CORE0_PATH.core.coreMonitorBundle_pc   ),
   .io_requestor_x_req_ready    (`CORE0_PATH.ptw.io_requestor_0_req_ready ),
   .io_requestor_x_req_valid    (`CORE0_PATH.ptw.io_requestor_0_req_valid   ),
   .io_requestor_x_req_bits_bits_addr (`CORE0_PATH.ptw.io_requestor_0_req_bits_bits_addr  ),
   .io_requestor_x_resp_valid   (`CORE0_PATH.ptw.io_requestor_0_resp_valid    ),
   .io_requestor_x_resp_bits_ae   (`CORE0_PATH.ptw.io_requestor_0_resp_bits_ae  ),
   .io_requestor_x_resp_bits_pte_ppn  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_ppn ),
   .io_requestor_x_resp_bits_pte_d  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_d ),
   .io_requestor_x_resp_bits_pte_a  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_a ),
   .io_requestor_x_resp_bits_pte_g  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_g ),
   .io_requestor_x_resp_bits_pte_u  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_u ),
   .io_requestor_x_resp_bits_pte_x  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_x ),
   .io_requestor_x_resp_bits_pte_w  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_w ),
   .io_requestor_x_resp_bits_pte_r  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_r ),
   .io_requestor_x_resp_bits_pte_v  (`CORE0_PATH.ptw.io_requestor_0_resp_bits_pte_v )
   );
ptw_monitor ptwC0R1
  (
   .clk         (`CORE0_PATH.ptw.clock    ),
   .trace_valid                         (1'b0),
   .pc_valid                            (1'b0),
   .pc                                  (64'h0),
   .io_requestor_x_req_ready    (`CORE0_PATH.ptw.io_requestor_1_req_ready ),
   .io_requestor_x_req_valid    (`CORE0_PATH.ptw.io_requestor_1_req_valid   ),
   .io_requestor_x_req_bits_bits_addr (`CORE0_PATH.ptw.io_requestor_1_req_bits_bits_addr  ),
   .io_requestor_x_resp_valid   (`CORE0_PATH.ptw.io_requestor_1_resp_valid    ),
   .io_requestor_x_resp_bits_ae   (`CORE0_PATH.ptw.io_requestor_1_resp_bits_ae  ),
   .io_requestor_x_resp_bits_pte_ppn  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_ppn ),
   .io_requestor_x_resp_bits_pte_d  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_d ),
   .io_requestor_x_resp_bits_pte_a  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_a ),
   .io_requestor_x_resp_bits_pte_g  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_g ),
   .io_requestor_x_resp_bits_pte_u  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_u ),
   .io_requestor_x_resp_bits_pte_x  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_x ),
   .io_requestor_x_resp_bits_pte_w  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_w ),
   .io_requestor_x_resp_bits_pte_r  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_r ),
   .io_requestor_x_resp_bits_pte_v  (`CORE0_PATH.ptw.io_requestor_1_resp_bits_pte_v )
   );
`endif
   
endmodule
