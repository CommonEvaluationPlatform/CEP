//************************************************************************
// Copyright 2024 Massachusetts Institute of Technology
// SPDX short identifier: BSD-3-Clause
//
// File Name:       scratchpad_wrapper.sv
// Program:         Common Evaluation Platform (CEP)
// Description:     This file provides a Verilog <-> SystemVerilog adapter
//                  allowing connection of TL-UL interface to the Chisel
//                  blackbox.  
// Notes:           The underlying TL-UL package is from the OpenTitan
//                  project.
//
//
//************************************************************************
`timescale 1ns/1ns

`include "prim_assert.sv"

module scratchpad_wrapper import tlul_pkg::*; import llki_pkg::*; #(
  parameter int ADDRESS     = 32'h00000000,  // In terms of bytes
  parameter int DEPTH       = 32'h00000100,  // In terms of bytes
  parameter SLAVE_TL_SZW    = top_pkg::TL_SZW,
  parameter SLAVE_TL_AIW    = top_pkg::TL_AIW,
  parameter SLAVE_TL_AW     = top_pkg::TL_AW,
  parameter SLAVE_TL_DBW    = top_pkg::TL_DBW,
  parameter SLAVE_TL_DW     = top_pkg::TL_DW,
  parameter SLAVE_TL_DIW    = top_pkg::TL_DIW
) (

  // Clock and reset
  input                           clk,
  input                           rst,

  // Slave interface A channel
  input [2:0]                     slave_a_opcode,
  input [2:0]                     slave_a_param,
  input [SLAVE_TL_SZW-1:0]        slave_a_size,
  input [SLAVE_TL_AIW-1:0]        slave_a_source,
  input [SLAVE_TL_AW-1:0]         slave_a_address,
  input [SLAVE_TL_DBW-1:0]        slave_a_mask,
  input [SLAVE_TL_DW-1:0]         slave_a_data,
  input                           slave_a_corrupt,
  input                           slave_a_valid,
  output                          slave_a_ready,

  // Slave interface D channel
  output [2:0]                    slave_d_opcode,
  output [2:0]                    slave_d_param,
  output reg [SLAVE_TL_SZW-1:0]   slave_d_size,
  output reg [SLAVE_TL_AIW-1:0]   slave_d_source,
  output reg [SLAVE_TL_DIW-1:0]   slave_d_sink,
  output                          slave_d_denied,
  output [SLAVE_TL_DW-1:0]        slave_d_data,
  output                          slave_d_corrupt,
  output                          slave_d_valid,
  input                           slave_d_ready

);
  
  localparam int RegBw          = top_pkg::TL_DW/8;

  // Create the structures for communicating with OpenTitan-based Tilelink
  tl_h2d_t                      slave_tl_h2d_i;
  tl_h2d_t                      slave_tl_h2d_o;
  tl_d2h_t                      slave_tl_d2h_i;
  tl_d2h_t                      slave_tl_d2h_o;
  logic                         tl_err;
  logic                         addr_err;

  // In the OpenTitan world, TL buses are encapsulated with the structures instantitated above
  // and as defined in top_pkg.sv.  This includes field widths.
  //
  // In the RocketChip world, some field widths will vary based on the other system components
  // (e.g., source and sink widths).  In order to provide maximum flexibility, without breaking
  // OpenTitan, top_pkg.sv is going to be defined with field maximum expected widths within
  // the CEP ecosystem.
  //
  // The following assignments, coupled with the parameters passed to this component will 
  // provide for a flexible assignment, when necessary.  Assertions will be used to capture
  // a mismatch when the widths in the OpenTitan world are not large enough to encapsulate
  // what is being passed from RocketChip.
  //
  // DW/DBW (Data bus width) must be equal in both worlds
  `ASSERT_INIT(scratchpad_slaveTlSzw, top_pkg::TL_SZW >= SLAVE_TL_SZW)
  `ASSERT_INIT(scratchpad_slaveTlAiw, top_pkg::TL_AIW >= SLAVE_TL_AIW)
  `ASSERT_INIT(scratchpad_slaveTlAw, top_pkg::TL_AW >= SLAVE_TL_AW)
  `ASSERT_INIT(scratchpad_slaveTlDbw, top_pkg::TL_DBW == SLAVE_TL_DBW)
  `ASSERT_INIT(scratchpad_slaveTlDw, top_pkg::TL_DW == SLAVE_TL_DW)
  
  // Make Slave A channel connections
  always @*
  begin
    slave_tl_h2d_i.a_size                       = '0;
    slave_tl_h2d_i.a_size[SLAVE_TL_SZW-1:0]     = slave_a_size;
    slave_tl_h2d_i.a_source                     = '0;
    slave_tl_h2d_i.a_source[SLAVE_TL_AIW-1:0]   = slave_a_source;
    slave_tl_h2d_i.a_address                    = '0;
    slave_tl_h2d_i.a_address[SLAVE_TL_AW-1:0]   = slave_a_address;
    
    slave_d_size                                = slave_tl_d2h_o.d_size[SLAVE_TL_SZW-1:0];
    slave_d_source                              = slave_tl_d2h_o.d_source[SLAVE_TL_AIW-1:0];
    slave_d_sink                                = slave_tl_d2h_o.d_sink[SLAVE_TL_DIW-1:0];
  
    slave_tl_h2d_i.a_valid                      = slave_a_valid;
    slave_tl_h2d_i.a_opcode                     = ( slave_a_opcode == 3'h0) ? PutFullData : 
                                                  ((slave_a_opcode == 3'h1) ? PutPartialData : 
                                                  ((slave_a_opcode == 3'h4) ? Get : 
                                                    Get));                                   
    slave_tl_h2d_i.a_param                      = slave_a_param;
    slave_tl_h2d_i.a_mask                       = slave_a_mask;
    slave_tl_h2d_i.a_data                       = slave_a_data;
    slave_tl_h2d_i.a_user                       = tl_a_user_t'('0);  // User field is unused by Rocket Chip
    slave_tl_h2d_i.d_ready                      = slave_d_ready;
  end

  
  // Make Slave D channel connections
  // Converting from the OpenTitan enumerated type to specific bit mappings
  assign slave_d_opcode         = ( slave_tl_d2h_o.d_opcode == AccessAck)     ? 3'h0 :
                                  ((slave_tl_d2h_o.d_opcode == AccessAckData) ? 3'h1 :
                                    3'h0);
  assign slave_d_param          = slave_tl_d2h_o.d_param;
  assign slave_d_denied         = slave_tl_d2h_o.d_error;
  assign slave_d_data           = slave_tl_d2h_o.d_data;
  assign slave_d_corrupt        = slave_tl_d2h_o.d_error;
  assign slave_d_valid          = slave_tl_d2h_o.d_valid;
  assign slave_a_ready          = slave_tl_d2h_o.a_ready;

  //------------------------------------------------------------------------
  // The TL-UL FIFO is used to queue burst transfers
  //
  // The almost_full description can be found in the slave_tl_d2h_i.a_ready
  // assignment below
  //------------------------------------------------------------------------
  localparam        RSP_FIFO_DEPTH        = 10;
  localparam        RSP_FIFO_ALMOST_FULL  = RSP_FIFO_DEPTH - 2;
  localparam int    DepthW                = prim_util_pkg::vbits(RSP_FIFO_DEPTH + 1);
  wire [DepthW-1:0] rsp_depth_o;
  wire              rsp_almost_full;
  assign            rsp_almost_full       = (rsp_depth_o >= RSP_FIFO_ALMOST_FULL) ? 1'b1 : 1'b0;

  tlul_fifo_sync #(
    .ReqPass      (1),                // The request FIFO will be a fall-through
    .RspPass      (1),                // The response FIFO will be also be fall-through
    .ReqDepth     (0),                // Complete passthrough mode
    .RspDepth     (RSP_FIFO_DEPTH),   // The maximum number of words we can expect
    .SpareReqW    (1),                // Unused (A value of zero results in an incorrect FIFO width)
    .SpareRspW    (1)                 // Unused
  ) tlul_fifo_sync_inst (
    .clk_i        (clk),
    .rst_ni       (~rst),
    .tl_h_i       (slave_tl_h2d_i),
    .tl_h_o       (slave_tl_d2h_o),
    .tl_d_i       (slave_tl_d2h_i),
    .tl_d_o       (slave_tl_h2d_o),
    .spare_req_i  ('0),
    .spare_req_o  (),
    .spare_rsp_i  ('0),
    .spare_rsp_o  (),
    .req_depth_o  (),
    .rsp_depth_o  (rsp_depth_o)

  );
  //------------------------------------------------------------------------


  //------------------------------------------------------------------------
  // TL-UL Error Checker Component (Channel A)
  //------------------------------------------------------------------------
  // tl_err : separate checker
  tlul_err tlul_err_inst (
    .clk_i  (clk),
    .rst_ni (~rst),
    .tl_i   (slave_tl_h2d_o),
    .err_o  (tl_err)
  );
  //------------------------------------------------------------------------


  //------------------------------------------------------------------------
  // Scratchpad RAM instantiated as individual bytes to allow for byte
  // addressing (effectively masking)
  //------------------------------------------------------------------------
  reg                       scratchpad_write_i;
  reg [top_pkg::TL_AW-1:0]  scratchpad_addr_i;
  reg [top_pkg::TL_DW-1:0]  scratchpad_wdata_i;
  reg [top_pkg::TL_DW-1:0]  scratchpad_mask_i;
  wire [top_pkg::TL_DW-1:0] scratchpad_rdata_o;

  // Generate the mask (in bits) based on the A Channel mask field
  always @*
  begin
    for (int i = 0; i < RegBw; i = i + 1)
      for (int j = 0; j < 8; j = j + 1)
        scratchpad_mask_i[i*8 + j] = slave_tl_h2d_o.a_mask[i];
  end // end always

  // Generate the scratchpad address (which needs to be in terms of 64-bit words)
  assign scratchpad_addr_i        = (slave_tl_h2d_o.a_address - ADDRESS) >> 3;

  // Writes will occur for only PutFullData and PutPartialData opcodes (we cannot process the request if not ready)
  assign scratchpad_write_i       = slave_tl_h2d_o.a_valid & slave_tl_d2h_i.a_ready & ((slave_tl_h2d_o.a_opcode == PutFullData) | (slave_tl_h2d_o.a_opcode == PutPartialData));
  assign scratchpad_wdata_i       = slave_tl_h2d_o.a_data;

  // See if an out of bound address was provided
  always @*
  begin
    if ((slave_tl_h2d_o.a_valid == 1) && (scratchpad_addr_i >= (DEPTH / 8)))
      addr_err                  = 1'b1;
    else
      addr_err                  = 1'b0;
  end

  always @*
  begin
    // D Channel read data is immediately mapped to the FIFO given theat registered RAM reads.  All other d_channel 
    // signals will need be registered to ensure it is aligned with the data
    slave_tl_d2h_i.d_data    = scratchpad_rdata_o;

    // The issue with directly connecting d_ready to a_ready, is that it does NOT allow for proper absorption of a request that was just read from
    // the request FIFO (Channel A).  Given the registered RAM output (and associated registering of other signals destined for the D Channel), 
    // there could be a reequest in-flight when d_channel becomes NOT ready, thus the need for using almost full.
    slave_tl_d2h_i.a_ready   = !rsp_almost_full;
  end

  // Perform the remaining tilelink connections
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      slave_tl_d2h_i.d_opcode   = AccessAck;
      slave_tl_d2h_i.d_param    = '0;
      slave_tl_d2h_i.d_size     = '0;
      slave_tl_d2h_i.d_source   = '0;
      slave_tl_d2h_i.d_sink     = '0;
      slave_tl_d2h_i.d_user     = '0;
      slave_tl_d2h_i.d_error    = '0;
      slave_tl_d2h_i.d_valid    = '0;
    end else begin
      //  The following assingment methodology is borrowed from the tlul_adapter_reg component
      if ((slave_tl_h2d_o.a_opcode == PutFullData) | (slave_tl_h2d_o.a_opcode == PutPartialData))
        slave_tl_d2h_i.d_opcode   = AccessAck;
      else
        slave_tl_d2h_i.d_opcode   = AccessAckData;

      slave_tl_d2h_i.d_param    = '0;
      slave_tl_d2h_i.d_size     = slave_tl_h2d_o.a_size;
      slave_tl_d2h_i.d_source   = slave_tl_h2d_o.a_source;
      slave_tl_d2h_i.d_sink     = '0;
      slave_tl_d2h_i.d_user     = '0;
      slave_tl_d2h_i.d_error    = tl_err || addr_err;
      // We cannot process the response if not ready
      slave_tl_d2h_i.d_valid    = slave_tl_h2d_o.a_valid & slave_tl_d2h_i.a_ready;
    end // end if (!rst_ni)
  end // always_ff @(posedge clk_i or negedge rst_ni)


  //------------------------------------------------------------------------
  // Instantiate a generic single port RAM
  //------------------------------------------------------------------------
  prim_generic_ram_1p #(
    .Width              (top_pkg::TL_DW),
    .Depth              (DEPTH / 8),
    .InitToZero         (1)               // Only applicable to simulation
  ) scratchpad_ram_inst (
    .clk_i              (clk),
    .req_i              (1'b1),           // Always selected
    .write_i            (scratchpad_write_i),
    .addr_i             (scratchpad_addr_i[$clog2(DEPTH/8) - 1:0]),
    .wdata_i            (scratchpad_wdata_i),
    .wmask_i            (scratchpad_mask_i),
    .rdata_o            (scratchpad_rdata_o)
  );
  //------------------------------------------------------------------------

endmodule   // endmodule scratchpad_wrapper
