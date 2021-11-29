//************************************************************************
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      v2c_top.v
// Program:        Common Evaluation Platform (CEP)
// Description:    
// Notes:          
//
//************************************************************************

`include "suite_config.v"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_cmds.incl"
`include "v2c_top.incl"
`include "sys_common.incl"
`include "dump_control.incl"      

module v2c_top (
  input        clk
);

  // shIpc stuffs
  //
  parameter MY_SLOT_ID  = `SYSTEM_SLOT_ID;
  parameter MY_CPU_ID   = `SYSTEM_CPU_ID;


  `define SHIPC_CLK clk
  initial begin
    __shIpc_EnableMode = 0;
    #1;
    __shIpc_EnableMode = 1;      
  end
  `undef   SHIPC_CLK

  // As external memory has been removed the calibration is ALWAYS complete  
  always @(*) dvtFlags[`DVTF_READ_CALIBRATION_DONE] = 1'b1;

  always @(posedge dvtFlags[`DVTF_SET_IPC_DELAY]) begin
    ipcDelay = dvtFlags[`DVTF_PAT_LO];
    dvtFlags[`DVTF_SET_IPC_DELAY] = 0;
  end

  // This is to handle single threading core: one core active at a time
  `ifdef RISCV_TESTS
    initial begin
      `logI("==== ISA RISCV_TESTS is active ===");      
    end
   
    int virtualMode = 0;
   
    always @(posedge dvtFlags[`DVTF_SET_VIRTUAL_MODE]) begin
//      virtualMode = 1;
//      `logI("==== Enable Virtual Mode");
      dvtFlags[`DVTF_SET_VIRTUAL_MODE] = 0;
    end
   
    int         curCore         = 0;
    reg         singleThread    = 0;
    reg [3:0]   coreActiveMask  = 0;

    // Utility to force a single threaded ( on core) operation
    always @(posedge dvtFlags[`DVTF_FORCE_SINGLE_THREAD]) begin
      coreActiveMask = dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] ;
      singleThread = 1;
      `logI("==== Force-ing Single Thread coreMask=0x%x===",coreActiveMask);
      dvtFlags[`DVTF_FORCE_SINGLE_THREAD] = 0;
    end
   
    always @(posedge dvtFlags[`DVTF_PASS_IS_TO_HOST]) begin
      `CORE0_DRIVER.checkToHost = 1;
      `CORE1_DRIVER.checkToHost = 1;
      `CORE2_DRIVER.checkToHost = 1;
      `CORE3_DRIVER.checkToHost = 1;
      dvtFlags[`DVTF_PASS_IS_TO_HOST] = 0; // self-clear
    end   
   
    // Force all cores into reset
    task ResetAllCores;
      begin
        force `CORE0_PATH.reset = 1;
        force `CORE1_PATH.reset = 1;
        force `CORE2_PATH.reset = 1;
        force `CORE3_PATH.reset = 1;
   
        repeat (2) @(posedge clk);
   
        release `CORE0_PATH.reset;  
        release `CORE1_PATH.reset;  
        release `CORE2_PATH.reset;  
        release `CORE3_PATH.reset;  
      end
    endtask // ResetAllCores
   
    // Force single-threaded operation
    always @(posedge singleThread) begin
   
      // Put all the cores into reset
      force `CORE0_PATH.reset =1; 
      force `CORE1_PATH.reset =1;
      force `CORE2_PATH.reset =1;
      force `CORE3_PATH.reset =1;

      // Ensure the program is loaded
      @(posedge `COSIM_TB_TOP_MODULE.program_loaded);
      
      // Allow caches to get out of reset but not the core!!!
      release `CORE0_PATH.reset; 
      release `CORE1_PATH.reset;
      release `CORE2_PATH.reset;
      release `CORE3_PATH.reset;
      force `CORE0_PATH.core.reset = 1; 
      force `CORE1_PATH.core.reset = 1;
      force `CORE2_PATH.core.reset = 1;
      force `CORE3_PATH.core.reset = 1;      
      
      // Cycle through all the cores
      for (int c = 0; c < 4; c = c + 1) 
      begin
   
        if (coreActiveMask[c]) begin
          case (c)

          // Core 0 is active
          0: begin
            `logI("Releasing CORE0 Reset....");
            if (virtualMode) begin
              ResetAllCores();
            end
            release `CORE0_PATH.core.reset; 
            @(posedge (`CORE0_DRIVER.PassStatus || `CORE0_DRIVER.FailStatus));
          end // Core 0 is active

          // Core 1 is active
          1: begin
            `logI("Releasing CORE1 Reset....");  
            if (virtualMode) begin
              ResetAllCores();
            end     
            release `CORE1_PATH.core.reset;
            @(posedge (`CORE1_DRIVER.PassStatus || `CORE1_DRIVER.FailStatus));
          end  // Core 1 is active

          // Core 2 is active
          2: begin
            `logI("Releasing CORE2 Reset....");  
            if (virtualMode) begin
              ResetAllCores();              
            end     
            release `CORE2_PATH.core.reset;
            @(posedge (`CORE2_DRIVER.PassStatus || `CORE2_DRIVER.FailStatus));
          end // Core 2 is active
        
          // Core 3 is active
          3: begin
            `logI("Releasing CORE3 Reset....");  
            if (virtualMode) begin
              ResetAllCores();
            end     
            release `CORE3_PATH.core.reset;
            @(posedge (`CORE3_DRIVER.PassStatus || `CORE3_DRIVER.FailStatus));
          end // Core 3 is active      
      
          endcase
        end // end if (coreActiveMask[c])
      end // for (int c=0;c<4;c=c+1)
    end // always @(posedge singleThread)
  `endif // endif `ifdef RISCV_TESTS
   
endmodule // v2c_top
