//--------------------------------------------------------------------------------------
// Copyright 2022 Massachusets Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      system_driver.sv
// Program:        Common Evaluation Platform (CEP)
// Description:    System Level testbench driver
// Notes:          
//
//--------------------------------------------------------------------------------------

`include "suite_config.v"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_cmds.incl"
`include "v2c_top.incl"

module system_driver (
  input               clk,
  input               enableMe
);

  parameter MY_SLOT_ID                = 4'h0;
  parameter MY_CPU_ID                 = 4'h0;

  reg [255:0]         dvtFlags        = 0;
  reg [255:0]         r_data;
  reg [31:0]          printf_addr;
  reg [1:0]           printf_coreId;
  reg [(128*8)-1:0]   printf_buf;
  reg [(128*8)-1:0]   tmp;
  reg                 clear           = 0;
  integer             cnt;
  string              str;
  reg                 program_loaded  = 0;

  //--------------------------------------------------------------------------------------
  // Define system driver supported DPI tasks prior to the inclusion of sys/driver_common.incl
  //--------------------------------------------------------------------------------------    
  // WRITE32_64
  `define SHIPC_WRITE32_64_TASK WRITE32_64_DPI()
  task WRITE32_64_DPI;
    reg [63:0] d;
    begin
      d[63:32] = inBox.mPar[0];
      d[31:0]  = inBox.mPar[1];

      write_mainmem_backdoor(inBox.mAdr, d);
    end
  endtask // WRITE32_64_DPI

  // READ32_64
  `define SHIPC_READ32_64_TASK READ32_64_DPI()
  task READ32_64_DPI;
    reg [63:0] d;
    begin
      read_mainmem_backdoor(inBox.mAdr, d);      
      
      inBox.mPar[0] = d[63:32];
      inBox.mPar[1] = d[31:0];      
    end
  endtask // READ32_64_DPI
  
  // WRITE_DVT_FLAG_TASK
  `define SHIPC_WRITE_DVT_FLAG_TASK WRITE_DVT_FLAG_TASK(__shIpc_p0,__shIpc_p1,__shIpc_p2)
  task WRITE_DVT_FLAG_TASK;
    input [31:0] msb;
    input [31:0] lsb;
    input [31:0] value; 
    begin
      for (int s = inBox.mPar[1]; s <= inBox.mPar[0]; s++) begin 
        dvtFlags[s]   = inBox.mPar[2] & 1'b1; 
        inBox.mPar[2] = inBox.mPar[2] >> 1; 
      end      
      
      @(posedge clk);  
    end
  endtask // WRITE_DVT_FLAG_TASK;

  // READ_DVT_FLAG_TASK
  `define SHIPC_READ_DVT_FLAG_TASK READ_DVT_FLAG_TASK(__shIpc_p0,__shIpc_p1,{__shIpc_p0[31:0],__shIpc_p1[31:0]})
  task READ_DVT_FLAG_TASK;
    input [31:0]    msb;
    input [31:0]    lsb;
    output [63:0]   r_data;
    integer         m;
    integer         l;
    reg [63:0]      tmp;
    begin
      tmp = 0;
    
      m = inBox.mPar[0];
      l = inBox.mPar[1];

      for (int s = m; s >= l; s--) begin       
        tmp = {tmp[62:0], dvtFlags[s]};
      end
      
      inBox.mPar[0] = tmp;
   
      @(posedge clk);   
    end
  endtask // READ_DVT_FLAG_TASK;
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // SHIPC Support Common Codes
  //
  // These includes must remain within the verilog module and
  // is dependent on the SHIPC_CLK macro.
  //--------------------------------------------------------------------------------------
  `define     SHIPC_XACTOR_ID     MY_CPU_ID
  `define     SHIPC_CLK           clk
  `include    "dpi_common.incl"
  `include    "dump_control.incl"      
  `undef      SHIPC_CLK
  `undef      SHIPC_XACTOR_ID      
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // DVT Flag Processing
  //--------------------------------------------------------------------------------------
  always @(posedge `DVT_FLAG[`DVTF_SET_PROGRAM_LOADED]) begin
    `logI("Program is now loaded");
    program_loaded = `DVT_FLAG[`DVTF_PAT_LO];
    `DVT_FLAG[`DVTF_SET_PROGRAM_LOADED] = 0;
  end // always @(posedge `DVT_FLAG[`DVTF_SET_PROGRAM_LOADED])

  always @(posedge `DVT_FLAG[`DVTF_TOGGLE_CHIP_RESET_BIT]) 
  begin
    wait (`PBUS_RESET == 0);
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
    `logI("SocketId = 0x%08x",`DVT_FLAG[`DVTF_PAT_HI:`DVTF_PAT_LO]);
    `DVT_FLAG[`DVTF_GET_SOCKET_ID_BIT] = 0;
  end // always @(posedge `DVT_FLAG[`DVTF_GET_SOCKET_ID_BIT])

  reg enableWrTrace   = 0;
  reg enableRdTrace   = 0;   
  
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
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // Tasks support "backdoor" read/write access from/to Main Memory
  //
  // They should only be accessed from the system thread given that they assert
  // signals on the memory components vs internal methods (as was the case in the DDR
  // memory).  Otherwise, you could potentially get multiple threads driving the same
  // signals concurrently, which will have an unpredictable behavior.
  //--------------------------------------------------------------------------------------  
  // Writes data directly to the Scratchpad (Main) Memory
  task write_mainmem_backdoor;
    input [31:0] addr;
    input [63:0] data;

    begin
    
      // If the memory is in reset, wait for it to be released
      if (`SCRATCHPAD_WRAPPER_PATH.rst == 1) @(negedge `SCRATCHPAD_WRAPPER_PATH.rst);

      @(posedge `SCRATCHPAD_WRAPPER_PATH.clk);

      #1;

      // All backdoor memory access is 64-bit
      force `SCRATCHPAD_WRAPPER_PATH.scratchpad_mask_i        = '1;
      force `SCRATCHPAD_WRAPPER_PATH.scratchpad_write_i       = 1;
      force `SCRATCHPAD_WRAPPER_PATH.slave_tl_h2d_o.a_address = addr;
      force `SCRATCHPAD_WRAPPER_PATH.scratchpad_wdata_i       = data;

      @(posedge `SCRATCHPAD_WRAPPER_PATH.clk);

      #1;
      
      release `SCRATCHPAD_WRAPPER_PATH.scratchpad_mask_i;
      release `SCRATCHPAD_WRAPPER_PATH.scratchpad_write_i;
      release `SCRATCHPAD_WRAPPER_PATH.slave_tl_h2d_o.a_address;
      release `SCRATCHPAD_WRAPPER_PATH.scratchpad_wdata_i;

    end
  endtask // write_mainmem_backdoor

  // Reads data directly from the Scratcpad (Main) Memory
  task read_mainmem_backdoor;
    input   [31:0] addr;
    output  [63:0] data;

    begin
    
      // If the memory is in reset, wait for it to be released
      if (`SCRATCHPAD_WRAPPER_PATH.rst == 1) @(negedge `SCRATCHPAD_WRAPPER_PATH.rst);

      // Reads are registered, need to be synchronized to the clock
      force `SCRATCHPAD_WRAPPER_PATH.slave_tl_h2d_o.a_address   = addr;
      @(posedge `SCRATCHPAD_WRAPPER_PATH.clk);
      @(negedge `SCRATCHPAD_WRAPPER_PATH.clk);

      #1;

      data = `SCRATCHPAD_WRAPPER_PATH.scratchpad_rdata_o;
      release `SCRATCHPAD_WRAPPER_PATH.slave_tl_h2d_o.a_address;

    end
  endtask // read_mainmem_backdoor
  //--------------------------------------------------------------------------------------



  //--------------------------------------------------------------------------------------
  // System Driver support tasks when running the RISCV_TESTS
  //--------------------------------------------------------------------------------------
  // This is to handle single threading core: one core active at a time
  `ifdef RISCV_TESTS
    reg [63:0]  passFail [0:4]      = '{default:0};
    reg         passFailValid       = 0;
    int         file;
    initial begin
      `logI("==== ISA RISCV_TESTS is active ===");      

      // Perform a simple file I/O test to ensure file is there
      file = $fopen("PassFail.hex", "r");
      if (file) begin
        $fclose(file);
        passFailValid = 1;
        $readmemh("PassFail.hex", passFail);
        `logI("Reading from PassFail.hex: pass = 0x%0x, fail = 0x%0x, finish = 0x%0x, write_tohost = 0x%0x, hangme = 0x%0x",
          passFail[0], passFail[1], passFail[2], passFail[3], passFail[4]);
      end

    end

    int         curCore         = 0;
    reg         singleThread    = 0;
    reg [3:0]   coreActiveMask  = 0;

    // Utility to force a single threaded (one core) operation
    always @(posedge dvtFlags[`DVTF_FORCE_SINGLE_THREAD]) begin
      coreActiveMask = dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] ;
      singleThread = 1;
      `logI("==== Force-ing Single Thread coreMask=0x%x===",coreActiveMask);
      dvtFlags[`DVTF_FORCE_SINGLE_THREAD] = 0;
    end
   
    always @(posedge dvtFlags[`DVTF_PASS_WRITETOHOST]) begin
      `CPU0_DRIVER.passWriteToHost = 1;
      `CPU1_DRIVER.passWriteToHost = 1;
      `CPU2_DRIVER.passWriteToHost = 1;
      `CPU3_DRIVER.passWriteToHost = 1;
      dvtFlags[`DVTF_PASS_WRITETOHOST] = 0; // self-clear
    end   
   
    // Force all cores into reset
    task ResetAllCores;
      begin
        force `TILE0_PATH.reset = 1;
        force `TILE1_PATH.reset = 1;
        force `TILE2_PATH.reset = 1;
        force `TILE3_PATH.reset = 1;
   
        repeat (2) @(posedge clk);
   
        release `TILE0_PATH.reset;  
        release `TILE1_PATH.reset;  
        release `TILE2_PATH.reset;  
        release `TILE3_PATH.reset;  
      end
    endtask // ResetAllCores
   
    // Force single-threaded operation
    always @(posedge singleThread) begin
   
      // Put all the cores into reset
      force `TILE0_PATH.reset =1; 
      force `TILE1_PATH.reset =1;
      force `TILE2_PATH.reset =1;
      force `TILE3_PATH.reset =1;

      // Ensure the program is loaded
      @(posedge `PROGRAM_LOADED);
      
      // Allow caches to get out of reset but not the core!!!
      release `TILE0_PATH.reset; 
      release `TILE1_PATH.reset;
      release `TILE2_PATH.reset;
      release `TILE3_PATH.reset;
      force `TILE0_PATH.core.reset = 1; 
      force `TILE1_PATH.core.reset = 1;
      force `TILE2_PATH.core.reset = 1;
      force `TILE3_PATH.core.reset = 1;      
      
      // Cycle through all the cores
      for (int c = 0; c < 4; c = c + 1) 
      begin
   
        if (coreActiveMask[c]) begin
          case (c)

          // Core 0 is active
          0: begin
            `logI("Releasing CPU0 Reset....");
            `ifdef VIRTUAL_MODE begin
              ResetAllCores();
            `endif
            release `TILE0_PATH.core.reset; 
            @(posedge (`CPU0_DRIVER.PassStatus || `CPU0_DRIVER.FailStatus));
          end // Core 0 is active

          // Core 1 is active
          1: begin
            `logI("Releasing CPU1 Reset....");  
            `ifdef VIRTUAL_MODE begin
              ResetAllCores();
            `endif
            release `TILE1_PATH.core.reset;
            @(posedge (`CPU1_DRIVER.PassStatus || `CPU1_DRIVER.FailStatus));
          end  // Core 1 is active

          // Core 2 is active
          2: begin
            `logI("Releasing CPU2 Reset....");  
            `ifdef VIRTUAL_MODE begin
              ResetAllCores();
            `endif
            release `TILE2_PATH.core.reset;
            @(posedge (`CPU2_DRIVER.PassStatus || `CPU2_DRIVER.FailStatus));
          end // Core 2 is active
        
          // Core 3 is active
          3: begin
            `logI("Releasing CPU3 Reset....");  
            `ifdef VIRTUAL_MODE begin
              ResetAllCores();
            `endif
            release `TILE3_PATH.core.reset;
            @(posedge (`CPU3_DRIVER.PassStatus || `CPU3_DRIVER.FailStatus));
          end // Core 3 is active      
      
          endcase
        end // end if (coreActiveMask[c])
      end // for (int c=0;c<4;c=c+1)
    end // always @(posedge singleThread)
  `endif // endif `ifdef RISCV_TESTS
  //--------------------------------------------------------------------------------------

   
endmodule // v2c_top
