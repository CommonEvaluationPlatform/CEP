//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      cep_driver.sv
// Program:        Common Evaluation Platform (CEP)
// Description:    Provides the BFM_MODE connections between
//                 the Tilelink masters and DPI mailboxes
//
//                 Also provides some monitoring functions when
//                 the RISCV_TESTS are enabled (in BARE_MODE)
// Notes:          
//
//--------------------------------------------------------------------------------------
`include "suite_config.v"
`include "cep_hierMap.incl"
`include "cep_adrMap.incl"
`include "v2c_cmds.incl"
`include "v2c_top.incl"

module cep_driver
(
  input               clk,
  input               reset,
  input               enableMe
);

  // Overriden at instantiation
  parameter MY_SLOT_ID    = 4'h0;
  parameter MY_CPU_ID     = 4'h0;

  reg [255:0]         dvtFlags = 0;
  reg [255:0]         r_data;
  reg [31:0]          printf_addr;
  reg [1:0]           printf_coreId;
  reg [(128*8)-1:0]   printf_buf;     // 128 bytes
  reg [(128*8)-1:0]   tmp;
  reg                 clear = 0;
  integer             cnt;
  string              str;
  reg                 backdoor_enable = 0;
  
  //--------------------------------------------------------------------------------------
  // Printf support function
  //--------------------------------------------------------------------------------------
  always @(posedge dvtFlags[`DVTF_PRINTF_CMD]) begin

    // Address to be printed
    printf_addr = dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO];

    // Load the printer buffer from main memory (8 bytes at a time) and then clear the memory read
    for (int i = 0; i < 15; i++) begin
      
      // MSWord of printer buffer is in the lowest memory position
      `COSIM_TB_TOP_MODULE.read_mainmem_backdoor  (printf_addr + 8*i, printf_buf[64*(15 - i) +: 64]);
      `COSIM_TB_TOP_MODULE.write_mainmem_backdoor (printf_addr + 8*i, 0);

    end // end for

    // left justify
    clear = 0;
    tmp = 0;

    // move trailing after newline or null
    for (cnt = 0; cnt < 128; cnt = cnt + 1) begin
      if (!clear && (printf_buf[(128*8)-1:(127*8)] != 'h0) &&       // '\0'
                    (printf_buf[(128*8)-1:(127*8)] != 'h0A) &&      // '\n'
                    (printf_buf[(128*8)-1:(127*8)] != 'h0D)) begin  // '\r'     
        tmp         = (tmp << 8) | printf_buf[(128*8)-1:(127*8)];
        printf_buf  = printf_buf << 8;
      end else begin
        clear         = 1;
        tmp           = tmp << 8;
      end // end if
    end // end for
    
    $sformat(str,"C%-d: %-s", printf_addr[1:0], tmp);
    `logI("%s",str);
    
    dvtFlags[`DVTF_PRINTF_CMD] = 0;
  end // end always
  //--------------------------------------------------------------------------------------
   

  //--------------------------------------------------------------------------------------
  // Misc support functions
  //--------------------------------------------------------------------------------------
  // As external memory has been removed the calibration is ALWAYS complete  
  always @(*) dvtFlags[`DVTF_READ_CALIBRATION_DONE] = 1'b1;

  always @(*) dvtFlags[`DVTF_GET_PROGRAM_LOADED]    = `COSIM_TB_TOP_MODULE.program_loaded;

  // Enable backdoor loading of main memory (this will affect all WRITE32/64_64_DPI and READ32/64_64_DPI calls)
  always @(posedge dvtFlags[`DVTF_ENABLE_MEM_BACKDOOR]) begin
    backdoor_enable = dvtFlags[`DVTF_PAT_LO];
    dvtFlags[`DVTF_ENABLE_MEM_BACKDOOR] = 0;
    `logI("Setting backdoor_enable = %d", backdoor_enable);
  end

  always @(posedge dvtFlags[`DVTF_PUT_CORE_IN_RESET]) begin
    if (dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] == MY_CPU_ID) begin
      force_core_in_reset();
    end
    dvtFlags[`DVTF_PUT_CORE_IN_RESET] = 0;  
  end // end always

  always @(posedge dvtFlags[`DVTF_GET_CORE_STATUS]) begin
    if      (dvtFlags[1:0] == 0) dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] = `CEPREGS_PATH.core0_status;
    else if (dvtFlags[1:0] == 1) dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] = `CEPREGS_PATH.core1_status;
    else if (dvtFlags[1:0] == 2) dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] = `CEPREGS_PATH.core2_status;
    else if (dvtFlags[1:0] == 3) dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO] = `CEPREGS_PATH.core3_status;
    dvtFlags[`DVTF_GET_CORE_STATUS]=0;
  end
  //--------------------------------------------------------------------------------------
   


  //--------------------------------------------------------------------------------------
  // Support Tasks
  //--------------------------------------------------------------------------------------

  // READ_STATUS_TASK
  `define SHIPC_READ_STATUS_TASK READ_STATUS_TASK(__shIpc_p0)
  task READ_STATUS_TASK;
    output [31:0] r_data;
    begin

      `ifdef USE_DPI
        inBox.mPar[0] = 0;
      `else     
        r_data = 0;
      `endif     

      @(posedge clk);
    end
  endtask // READ_STATUS_TASK;

  // WRITE_DVT_FLAG_TASK
  `define SHIPC_WRITE_DVT_FLAG_TASK WRITE_DVT_FLAG_TASK(__shIpc_p0,__shIpc_p1,__shIpc_p2)
  task WRITE_DVT_FLAG_TASK;
    input [31:0] msb;
    input [31:0] lsb;
    input [31:0] value; 
    begin
      `ifdef USE_DPI
        for (int s = inBox.mPar[1]; s <= inBox.mPar[0]; s++) begin 
          dvtFlags[s]   = inBox.mPar[2] & 1'b1; 
          inBox.mPar[2] = inBox.mPar[2] >> 1; 
        end      
      `else
        for (int s = lsb; s <= msb; s++) begin 
          dvtFlags[s]   = value[0]; 
          value         = value >> 1; 
        end
      `endif
      
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
    
      `ifdef USE_DPI
        m = inBox.mPar[0];
        l = inBox.mPar[1];
        for (int s = m; s >= l; s--) begin       
          tmp = {tmp[62:0], dvtFlags[s]};
        end
      
        inBox.mPar[0] = tmp;
      `else
        for (int s = msb; s >= lsb; s = s--) begin 
          tmp = {tmp[62:0], dvtFlags[s]};
        end
    
        r_data = tmp;
      `endif   
   
      @(posedge clk);   
    end
  endtask // READ_DVT_FLAG_TASK;

  // READ_ERROR_CNT_TASK
  `define SHIPC_READ_ERROR_CNT_TASK READ_ERROR_CNT_TASK(__shIpc_p0)
  task READ_ERROR_CNT_TASK;
    output [31:0]   r_data;
    begin
      `ifdef USE_DPI      
        $vpp_getErrorCount(inBox.mPar[0]);
      `else      
        $vpp_getErrorCount(r_data);
      `endif      
    end
  endtask // READ_ERROR_CNT_TASK;

  // WRITE64_BURST
  `ifdef USE_DPI
    `define SHIPC_WRITE64_BURST_TASK WRITE64_BURST_DPI()
    task WRITE64_BURST_DPI;
      reg [3:0]   bits_size;
      begin
        bits_size = $clog2(inBox.mAdrHi << 3); // unit of 8 bytes
   
        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: begin
              for (int i=0;i<inBox.mAdrHi;i++) `CORE0_TL_PATH.tl_buf[i] = inBox.mPar[i];
              `CORE0_TL_PATH.tl_a_ul_write_burst(MY_CPU_ID & 'h1, inBox.mAdr,'hFF,bits_size);
            end
            1: begin
              for (int i=0;i<inBox.mAdrHi;i++) `CORE1_TL_PATH.tl_buf[i] = inBox.mPar[i];
              `CORE1_TL_PATH.tl_a_ul_write_burst(MY_CPU_ID & 'h1, inBox.mAdr,'hFF,bits_size);
            end
            2: begin
              for (int i=0;i<inBox.mAdrHi;i++) `CORE2_TL_PATH.tl_buf[i] = inBox.mPar[i];
              `CORE2_TL_PATH.tl_a_ul_write_burst(MY_CPU_ID & 'h1, inBox.mAdr,'hFF,bits_size);
            end
            3: begin
              for (int i=0;i<inBox.mAdrHi;i++) `CORE3_TL_PATH.tl_buf[i] = inBox.mPar[i];
              `CORE3_TL_PATH.tl_a_ul_write_burst(MY_CPU_ID & 'h1, inBox.mAdr,'hFF,bits_size);
            end     
          endcase // case (MY_CPU_ID)
        `endif
      end
    endtask // WRITE64_BURST_TASK
  `endif

  // ATOMIC_RDW64
  `ifdef USE_DPI
    `define SHIPC_ATOMIC_RDW64_TASK ATOMIC_RDW64_DPI()
    task ATOMIC_RDW64_DPI;
      reg [3:0]   bits_size;
      begin
        bits_size = 3;
   
        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_a_ul_logical_data(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mAdrHi,inBox.mPar[0],inBox.mPar[1],bits_size);
            1: `CORE1_TL_PATH.tl_a_ul_logical_data(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mAdrHi,inBox.mPar[0],inBox.mPar[1],bits_size);
            2: `CORE2_TL_PATH.tl_a_ul_logical_data(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mAdrHi,inBox.mPar[0],inBox.mPar[1],bits_size);
            3: `CORE3_TL_PATH.tl_a_ul_logical_data(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mAdrHi,inBox.mPar[0],inBox.mPar[1],bits_size);
          endcase    
        `endif
      end
    endtask // ATOMIC_RDW64_TASK
  `endif

  // WRITE64_64
  `ifdef USE_DPI
    `define SHIPC_WRITE64_64_TASK WRITE64_64_DPI()
    task WRITE64_64_DPI;
      begin
        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.write_mainmem_backdoor(inBox.mAdr,inBox.mPar[0]);
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mPar[0]);
              1: `CORE1_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mPar[0]);
              2: `CORE2_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mPar[0]);
              3: `CORE3_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,inBox.mPar[0]);     
            endcase // case (MY_CPU_ID)
          end // else: !if(backdoor_enable)
        `else
          `COSIM_TB_TOP_MODULE.write_mainmem_backdoor(inBox.mAdr,inBox.mPar[0]);               
        `endif
      end
    endtask // WRITE64_64_TASK
  `endif

  // READ64_BURST
  `ifdef USE_DPI   
    `define SHIPC_READ64_BURST_TASK READ64_BURST_DPI()
    task READ64_BURST_DPI;
      reg [3:0] bits_size;
      begin
        bits_size = $clog2(inBox.mAdrHi << 3); // unit of 8 bytes
  
        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: begin
              `CORE0_TL_PATH.tl_a_ul_read_burst(MY_CPU_ID & 'h1, inBox.mAdr,bits_size);
              for (int i=0;i<inBox.mAdrHi;i++) inBox.mPar[i] = `CORE0_TL_PATH.tl_buf[i];
            end
            1: begin
              `CORE1_TL_PATH.tl_a_ul_read_burst(MY_CPU_ID & 'h1, inBox.mAdr,bits_size);
              for (int i=0;i<inBox.mAdrHi;i++) inBox.mPar[i] = `CORE1_TL_PATH.tl_buf[i];  
            end
            2: begin
              `CORE2_TL_PATH.tl_a_ul_read_burst(MY_CPU_ID & 'h1, inBox.mAdr,bits_size);
              for (int i=0;i<inBox.mAdrHi;i++) inBox.mPar[i] = `CORE2_TL_PATH.tl_buf[i];  
            end
            3: begin
              `CORE3_TL_PATH.tl_a_ul_read_burst(MY_CPU_ID & 'h1, inBox.mAdr,bits_size);
              for (int i=0;i<inBox.mAdrHi;i++) inBox.mPar[i] = `CORE3_TL_PATH.tl_buf[i];  
            end     
          endcase // case (MY_CPU_ID)
        `endif
      end
    endtask // WRITE64_BURST_TASK
  `endif
   
  // READ64_64
  `ifdef USE_DPI   
    `define SHIPC_READ64_64_TASK READ64_64_DPI()
    task READ64_64_DPI;
      begin
        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(inBox.mAdr,inBox.mPar[0]);      
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, inBox.mPar[0]);
              1: `CORE1_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, inBox.mPar[0]);
              2: `CORE2_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, inBox.mPar[0]);
              3: `CORE3_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, inBox.mPar[0]);     
            endcase // case (MY_CPU_ID)
          end
        `else
          `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(inBox.mAdr, inBox.mPar[0]);
        `endif // !`ifdef BFM_MODE
      end
    endtask // READ64_64_TASK
  `endif
   
  //--------------------------------------------------------------------------------------
  // New DPI Interface
  //--------------------------------------------------------------------------------------
  `ifdef USE_DPI

    // WRITE32_64
    `define SHIPC_WRITE32_64_TASK WRITE32_64_DPI()
    task WRITE32_64_DPI;
      reg [63:0] d;
      begin
        d[63:32] = inBox.mPar[0];
        d[31:0]  = inBox.mPar[1];
        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.write_mainmem_backdoor(inBox.mAdr,d);
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,d);
              1: `CORE1_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,d);
              2: `CORE2_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,d);
              3: `CORE3_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, inBox.mAdr,d);     
            endcase // case (MY_CPU_ID)
          end // else: !if(backdoor_enable)
        `else
          `COSIM_TB_TOP_MODULE.write_mainmem_backdoor(inBox.mAdr,d);               
        `endif
      end
    endtask // WRITE32_64_TASK

    // WRITE32_8_DPI
    `define SHIPC_WRITE32_8_TASK WRITE32_8_DPI()
    task WRITE32_8_DPI;
      reg [63:0] d;
      reg [7:0]  mask, byte8;
      begin
        mask = 1 << inBox.mAdr[2:0];
        byte8 = inBox.mPar[0] & 'hff;
   
        d = {8{byte8}};
        
        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,0);
            1: `CORE1_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,0);
            2: `CORE2_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,0);
            3: `CORE3_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,0);     
          endcase // case (MY_CPU_ID)
        `endif
      end
    endtask // WRITE32_8_DPI

    // WRITE32_16_DPI
    `define SHIPC_WRITE32_16_TASK WRITE32_16_DPI()
    task WRITE32_16_DPI;
      reg [63:0] d;
      reg [7:0]  mask;
      reg [15:0] word;
      begin
        mask = 3 << (inBox.mAdr[2:1]*2);
        word = inBox.mPar[0] & 'hffff;
          
        d = {4{word}};

        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,1);
            1: `CORE1_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,1);
            2: `CORE2_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,1);
            3: `CORE3_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,1);     
          endcase // case (MY_CPU_ID)
        `endif
      end
    endtask // WRITE32_16_DPI

    // WRITE32_32_DPI
    `define SHIPC_WRITE32_32_TASK WRITE32_32_DPI()
    task WRITE32_32_DPI;
      reg [63:0] d;
      reg [7:0]  mask;
      begin
        if (inBox.mAdr[2]) 
          mask = 'hF0;
        else 
          mask = 'h0F;

        d[63:32] = inBox.mPar[0];
        d[31:0] = inBox.mPar[0];   
      
        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,2);
            1: `CORE1_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,2);
            2: `CORE2_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,2);
            3: `CORE3_TL_PATH.tl_a_ul_write_generic(MY_CPU_ID & 'h1, inBox.mAdr,d,mask,2);     
          endcase // case (MY_CPU_ID)
        `endif
      end
    endtask // WRITE32_32_DPI
   
  //--------------------------------------------------------------------------------------
  // OLD PLI Interface
  //--------------------------------------------------------------------------------------
  `else   

    // WRITE32_64_TASK
    `define SHIPC_WRITE32_64_TASK WRITE32_64_TASK(__shIpc_address[31:0],{__shIpc_p0[31:0],__shIpc_p1[31:0]})
    task WRITE32_64_TASK;
      input [31:0] a;
      input [63:0] d;
      begin
        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.write_mainmem_backdoor(a,d);      
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, a, d);
              1: `CORE1_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, a, d);
              2: `CORE2_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, a, d);
              3: `CORE3_TL_PATH.tl_x_ul_write(MY_CPU_ID & 'h1, a, d);     
            endcase // case (MY_CPU_ID)
          end // else: !if(backdoor_enable)
        `endif
      end
    endtask // WRITE32_64_TASK
  
  `endif // `ifdef USE_DPI
  //--------------------------------------------------------------------------------------
   

  //--------------------------------------------------------------------------------------
  // New DPI Interface
  //--------------------------------------------------------------------------------------
  `ifdef USE_DPI   
      
    // READ32_64
    `define SHIPC_READ32_64_TASK READ32_64_DPI()
    task READ32_64_DPI;
      reg [63:0] d;
      begin
        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(inBox.mAdr,d);      
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, d);
              1: `CORE1_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, d);
              2: `CORE2_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, d);
              3: `CORE3_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, inBox.mAdr, d);     
            endcase // case (MY_CPU_ID)
          end
        `else
          `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(inBox.mAdr,d);            
        `endif // !`ifdef BFM_MODE
      
        inBox.mPar[0] = d[63:32];
        inBox.mPar[1] = d[31:0];      
      end
    endtask // READ32_64_DPI

    // READ32_8_DPI
    `define SHIPC_READ32_8_TASK READ32_8_DPI()
    task READ32_8_DPI;
      reg [63:0] d;
      reg [7:0]  mask;
      begin
        mask = 1 << inBox.mAdr[2:0];

        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 0, d);
            1: `CORE1_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 0, d);
            2: `CORE2_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 0, d);
            3: `CORE3_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 0, d);     
          endcase // case (MY_CPU_ID)
      
          case (inBox.mAdr[2:0])
            0 : inBox.mPar[0] = d[(8*0)+7:(8*0)];
            1 : inBox.mPar[0] = d[(8*1)+7:(8*1)];
            2 : inBox.mPar[0] = d[(8*2)+7:(8*2)];
            3 : inBox.mPar[0] = d[(8*3)+7:(8*3)];
            4 : inBox.mPar[0] = d[(8*4)+7:(8*4)];
            5 : inBox.mPar[0] = d[(8*5)+7:(8*5)];
            6 : inBox.mPar[0] = d[(8*6)+7:(8*6)];
            7 : inBox.mPar[0] = d[(8*7)+7:(8*7)];
          endcase
        `endif      
      end
    endtask // READ32_8_DPI

    // READ32_16_DPI
    `define SHIPC_READ32_16_TASK READ32_16_DPI()
    task READ32_16_DPI;
      reg [63:0] d;
      reg [7:0]  mask;
      begin
        mask = 3 << (inBox.mAdr[2:1]*2);      

        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 1, d);
            1: `CORE1_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 1, d);
            2: `CORE2_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 1, d);
            3: `CORE3_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 1, d);     
          endcase // case (MY_CPU_ID)
      
          case (inBox.mAdr[2:1])
            0 : inBox.mPar[0] = d[(16*0)+15:(16*0)];
            1 : inBox.mPar[0] = d[(16*1)+15:(16*1)];
            2 : inBox.mPar[0] = d[(16*2)+15:(16*2)];
            3 : inBox.mPar[0] = d[(16*3)+15:(16*3)];
          endcase
        `endif      
      end
    endtask // READ32_16_DPI

    // READ32_32_DPI
    `define SHIPC_READ32_32_TASK READ32_32_DPI()
    task READ32_32_DPI;
      reg [63:0] d;
      reg [7:0]  mask;
      begin
        if 
          (inBox.mAdr[2]) mask = 'hF0;
        else 
          mask = 'h0F;      

        `ifdef BFM_MODE
          case (MY_CPU_ID)
            0: `CORE0_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 2, d);
            1: `CORE1_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 2, d);
            2: `CORE2_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 2, d);
            3: `CORE3_TL_PATH.tl_x_ul_read_generic(MY_CPU_ID & 'h1, inBox.mAdr, mask, 2, d);     
          endcase // case (MY_CPU_ID)
        
          inBox.mPar[0] = inBox.mAdr[2] ? d[63:32] : d[31:0];
        `endif      
      end
    endtask // READ32_32_DPI

  //--------------------------------------------------------------------------------------
  // OLD PLI Interface
  //--------------------------------------------------------------------------------------  
  `else

    `define SHIPC_READ32_64_TASK READ32_64_TASK(__shIpc_address[31:0],{__shIpc_p0[31:0],__shIpc_p1[31:0]})
    task READ32_64_TASK;
      input [31:0] a;
      output [63:0] d;
      begin

        `ifdef BFM_MODE
          if (backdoor_enable) begin
            `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(a,d);      
          end else begin
            case (MY_CPU_ID)
              0: `CORE0_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, a, d);
              1: `CORE1_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, a, d);
              2: `CORE2_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, a, d);
              3: `CORE3_TL_PATH.tl_x_ul_read(MY_CPU_ID & 'h1, a, d);     
            endcase // case (MY_CPU_ID)
          end
        `else
          `COSIM_TB_TOP_MODULE.read_mainmem_backdoor(a,d);            
        `endif
      end
    endtask // READ32_64_TASK
  `endif
  //--------------------------------------------------------------------------------------  



  //--------------------------------------------------------------------------------------
  // SHIPC Support Common Codes
  //--------------------------------------------------------------------------------------
  `define   SHIPC_XACTOR_ID  MY_CPU_ID
  `define   SHIPC_CLK   clk
  `include "driver_common.incl"
  `undef    SHIPC_CLK
  `undef    SHIPC_XACTOR_ID      
  //--------------------------------------------------------------------------------------
 


  //--------------------------------------------------------------------------------------
  // Per core reset control
  //-------------------------------------------------------------------------------------- 
  // Put the core in reset that is not active
  `define FORCE_RESET_IF_NOT_USED
  `ifdef FORCE_RESET_IF_NOT_USED   
    initial begin
      repeat(10) @(posedge clk);
      if (!myIsActive) begin
        force_core_in_reset();  
      end // if (!myIsActive)
    end // initial begin
  `endif //  `ifdef FORCE_RESET_IF_NOT_USED

  // Task to force the current drivers core into reset
  task force_core_in_reset;
    begin
      case (MY_CPU_ID)
        0: begin
          `logI("Forcing CORE#0 in reset...");
          
          `ifdef BARE_MODE
            force `CORE0_PATH.core.reset =1;
          `endif
           
          `ifdef BFM_MODE
            force `CORE0_PATH.reset =1;
          `endif
        end
        1: begin
          `logI("Forcing CORE#1 in reset...");

          `ifdef BARE_MODE
            force `CORE1_PATH.core.reset =1;
          `endif
    
          `ifdef BFM_MODE
            force `CORE1_PATH.reset =1;
          `endif        
        end
        2: begin
          `logI("Forcing CORE#2 in reset...");
    
          `ifdef BARE_MODE
            force `CORE2_PATH.core.reset =1;
          `endif
    
          `ifdef BFM_MODE
            force `CORE2_PATH.reset =1;
          `endif        
        end
        3: begin
          `logI("Forcing CORE#3 in reset...");
   
          `ifdef BARE_MODE
            force `CORE3_PATH.core.reset =1;
          `endif
            
            `ifdef BFM_MODE
              force `CORE3_PATH.reset =1;
            `endif        
        end     
      endcase // case (MY_CPU_ID)
    end
  endtask
  //-------------------------------------------------------------------------------------- 


  //--------------------------------------------------------------------------------------
  // Support functions for the RISC-V ISA Tests (which WILL require BARE_MODE)
  //--------------------------------------------------------------------------------------
  reg         PassStatus=0;
  reg         FailStatus=0;
  `ifdef RISCV_TESTS
   
    wire        pcPass;
    wire        pcFail;
    reg         checkToHost=0;
    reg [63:0]  passFail [0:4] = '{default:0};
    reg         DisableStuckChecker = 0;
    int         stuckCnt=0;
    reg [63:0]  lastPc=0;
    wire [63:0] curPc;
    wire        curValid;
    wire        coreInReset;
    wire        pcValid;
    wire        pcStuck = !DisableStuckChecker && (stuckCnt >= 500);

    // Core 0 Only
    // 0 = pass, 1 = fail, 2 = finish
    initial begin
      $readmemh("PassFail.hex",passFail);
      `logI("PassFail=%x %x %x %x %x",passFail[0],passFail[1],passFail[2],passFail[3],passFail[4]);
    end
   
    // Get core reset status    
    always @(posedge dvtFlags[`DVTF_GET_CORE_RESET_STATUS]) begin
      case (MY_CPU_ID)      
        0: dvtFlags[`DVTF_PAT_LO] = `CORE0_PATH.core.reset;
        1: dvtFlags[`DVTF_PAT_LO] = `CORE1_PATH.core.reset;
        2: dvtFlags[`DVTF_PAT_LO] = `CORE2_PATH.core.reset;
        3: dvtFlags[`DVTF_PAT_LO] = `CORE3_PATH.core.reset;
      endcase
      dvtFlags[`DVTF_GET_CORE_RESET_STATUS] = 0; // self-clear
    end

    // Get Pass / Fail Status
    always @(posedge dvtFlags[`DVTF_GET_PASS_FAIL_STATUS]) begin
      dvtFlags[`DVTF_PAT_HI:`DVTF_PAT_LO]   = {FailStatus,PassStatus};
      dvtFlags[`DVTF_GET_PASS_FAIL_STATUS]  = 0; // self-clear
    end

    // Set Pass / Fail Statu
    always @(posedge dvtFlags[`DVTF_SET_PASS_FAIL_STATUS]) begin
      PassStatus = 0;
      FailStatus = 1;
      dvtFlags[`DVTF_SET_PASS_FAIL_STATUS]  = 0; // self-clear
    end

    // Disable Stuck Checker
    always @(posedge dvtFlags[`DVTF_DISABLE_STUCKCHECKER]) begin
      `logI("DisableStuckChecker = 1");
      DisableStuckChecker = 1;
      dvtFlags[`DVTF_DISABLE_STUCKCHECKER] = 0; // self-clear
    end   
 
    // To detect stuck loop
    assign pcPass = curValid &&
      ((curPc[29:0] === passFail[0][29:0]) ||
      ((curPc[29:0] == passFail[2][29:0]) && (passFail[2][29:0] != 0)) ||    
      ((curPc[29:0] == passFail[3][29:0]) && (passFail[3][29:0] != 0) && checkToHost));
    assign pcFail = (pcStuck ||
      (curValid &&
      (((curPc[29:0] == passFail[4][29:0]) && (passFail[4][29:0] != 0)) ||
      (curPc[29:0] === passFail[1][29:0]))));
   
    always @(posedge pcStuck) begin
      `logE("PC seems to be stuck!!!! Terminating...");
    end
   
    always @(posedge clk) begin
      if (pcValid) begin
        lastPc <= curPc;
        if (curPc == lastPc) stuckCnt <= stuckCnt + 1;
        else stuckCnt <= 0;
      end
    end // end always
   
    // Generate per-CPU items
    generate
      if (MY_CPU_ID == 0) begin
        always @(posedge pcPass or posedge  pcFail) begin
          if (`CORE0_PATH.core.reset == 0) begin
            `logI("C0 Pass/fail Detected!!!.. Put it to sleep");
            PassStatus = pcPass;
            FailStatus = pcFail;
            if (!DisableStuckChecker) begin
              repeat (20) @(posedge clk);
              force `CORE0_PATH.core.reset =1;
            end
          end
        end // end always
   
        assign curPc       = `CORE0_PC;
        assign curValid    = `CORE0_VALID;
        assign coreInReset = `CORE0_PATH.core.reset;
        assign pcValid     = `CORE0_PATH.core.csr_io_trace_0_valid && `CORE0_PATH.core._T_1481;   
   
      end else if (MY_CPU_ID == 1) begin
        always @(posedge pcPass or posedge  pcFail) begin
          if (`CORE1_PATH.core.reset == 0) begin      
            `logI("C1 Pass/fail Detected!!!.. Put it to sleep");
            PassStatus = pcPass;
            FailStatus = pcFail;
            if (!DisableStuckChecker) begin         
              repeat (20) @(posedge clk);        
              force `CORE1_PATH.core.reset =1;
            end
          end
        end // end always
   
        assign curPc       = `CORE1_PC;
        assign curValid    = `CORE1_VALID;
        assign coreInReset = `CORE1_PATH.core.reset;
        assign pcValid     = `CORE1_PATH.core.csr_io_trace_0_valid && `CORE1_PATH.core._T_1481;     
      
      end else if (MY_CPU_ID == 2) begin
        always @(posedge pcPass or posedge  pcFail) begin
          if (`CORE2_PATH.core.reset == 0) begin      
            `logI("C2 Pass/fail Detected!!!.. Put it to sleep");
            PassStatus = pcPass;
            FailStatus = pcFail;
            if (!DisableStuckChecker) begin         
              repeat (20) @(posedge clk);
              force `CORE2_PATH.core.reset =1;
            end
          end
        end // end always
   
        assign curPc       = `CORE2_PC;
        assign curValid    = `CORE2_VALID;
        assign coreInReset = `CORE2_PATH.core.reset;
        assign pcValid     = `CORE2_PATH.core.csr_io_trace_0_valid && `CORE2_PATH.core._T_1481;     
    
      end else if (MY_CPU_ID == 3) begin
        always @(posedge pcPass or posedge  pcFail) begin
          if (`CORE3_PATH.core.reset == 0) begin      
            `logI("C3 Pass/fail Detected!!!.. Put it to sleep");
            PassStatus = pcPass;
            FailStatus = pcFail;
            if (!DisableStuckChecker) begin         
              repeat (20) @(posedge clk);     
              force `CORE3_PATH.core.reset =1;
            end
          end
        end // end always
    
        assign curPc       = `CORE3_PC;
        assign curValid    = `CORE3_VALID;
        assign coreInReset = `CORE3_PATH.core.reset;
        assign pcValid     = `CORE3_PATH.core.csr_io_trace_0_valid && `CORE3_PATH.core._T_1481;     
      end  // end if MY_CPU_ID
    endgenerate
  `endif //  `ifdef RISCV_TESTS
   
endmodule // cep_driver
