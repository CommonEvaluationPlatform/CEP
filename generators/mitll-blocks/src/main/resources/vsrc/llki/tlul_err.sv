// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
//************************************************************************
// Copyright 2021 Massachusetts Institute of Technology
// SPDX License Identifier: BSD 2-Clause
//
// File Name:       tlul_err.sv
// Program:         Common Evaluation Platform (CEP)
// Description:     OpenTitan tlul_err.sv customized for the Common 
//                  Evaluation Plafform
// Notes:           Updated to support 8-byte transfers
//************************************************************************



`include "prim_assert.sv"

module tlul_err import tlul_pkg::*; (
  input clk_i,
  input rst_ni,

  input tl_h2d_t tl_i,

  output logic err_o
);

  localparam int IW  = $bits(tl_i.a_source);
  localparam int SZW = $bits(tl_i.a_size);
  localparam int DW  = $bits(tl_i.a_data);
  localparam int MW  = $bits(tl_i.a_mask);
  localparam int SubAW = $clog2(DW/8);

  logic opcode_allowed, a_config_allowed;

  logic op_full, op_partial, op_get;
  assign op_full    = (tl_i.a_opcode == PutFullData);
  assign op_partial = (tl_i.a_opcode == PutPartialData);
  assign op_get     = (tl_i.a_opcode == Get);

  // Anything that doesn't fall into the permitted category, it raises an error
  assign err_o = ~(opcode_allowed & a_config_allowed);

  // opcode check
  assign opcode_allowed = (tl_i.a_opcode == PutFullData)
                        | (tl_i.a_opcode == PutPartialData)
                        | (tl_i.a_opcode == Get);

  // a channel configuration check (assertion indicates condition is GOOD)
  logic addr_sz_chk;    // address and size alignment check
  logic mask_chk;       // inactive lane a_mask check
  logic fulldata_chk;   // PutFullData should have size match to mask

  // For single byte transfers, ensure the address offset corresponds to the
  // the appropriate mask bit (and no other mask bits are asserted)
  logic [MW-1:0] mask;
  assign mask = (1 << tl_i.a_address[SubAW-1:0]);

  always_comb begin
    addr_sz_chk  = 1'b0;
    mask_chk     = 1'b0;
    fulldata_chk = 1'b0; // Only valid when opcode is PutFullData

    if (tl_i.a_valid) begin
      unique case (tl_i.a_size)

        'h0: begin // 1 Byte
          addr_sz_chk  = 1'b1;
          mask_chk     = ~|(tl_i.a_mask & ~mask); // ensure no other mask bits are set
          fulldata_chk = |(tl_i.a_mask & mask);   // ensure the address/mask align
        end

        'h1: begin // 2 Bytes
          addr_sz_chk     = ~tl_i.a_address[0];      // Per TL spec, address must be aligned to size
          if (DW==64) begin
            unique case (tl_i.a_address[2:1])
              'h0     : begin
                mask_chk      = ~|(tl_i.a_mask & 8'b11111100);
                fulldata_chk  = &tl_i.a_mask[1:0];
              end
              'h1     : begin
                mask_chk      = ~|(tl_i.a_mask & 8'b11110011);
                fulldata_chk  = &tl_i.a_mask[3:2];
              end
              'h2     : begin
                mask_chk      = ~|(tl_i.a_mask & 8'b11001111);
                fulldata_chk  = &tl_i.a_mask[5:4];
              end
              'h3     : begin
                mask_chk      = ~|(tl_i.a_mask & 8'b00111111);
                fulldata_chk  = &tl_i.a_mask[7:6];
              end
              default : begin
                mask_chk      = 1'b0;  
                fulldata_chk  = 1'b0;
              end
            endcase
          end else begin
            mask_chk          = (tl_i.a_address[1]) ? ~|(tl_i.a_mask & 4'b0011) : ~|(tl_i.a_mask & 4'b1100);
            fulldata_chk      = (tl_i.a_address[1]) ? &tl_i.a_mask[3:2] : &tl_i.a_mask[1:0];
          end // end if (DW==64)
        end

        'h2: begin // 4 Bytes
          if (DW==64) begin
            addr_sz_chk  = ~|tl_i.a_address[1:0];   // Per TL spec, address must be aligned to size
            mask_chk     = (tl_i.a_address[2]) ? ~|(tl_i.a_mask & 8'b00001111) : ~|(tl_i.a_mask & 8'b11110000);
            fulldata_chk = (tl_i.a_address[2]) ? &tl_i.a_mask[7:4] : &tl_i.a_mask[3:0];
          end else begin
            addr_sz_chk  = ~|tl_i.a_address[1:0];   // Per TL spec, address must be aligned to size
            mask_chk     = 1'b1;                    // Mas alignment not an issue when all mask bits are asserted
            fulldata_chk = &tl_i.a_mask[3:0];       // All mask bits should be asserted
          end // end if (DW==64)
        end

        'h3,          // 8 Bytes
        'h6: begin    // 64 Bytes
          if (DW==64) begin
            addr_sz_chk  = ~|tl_i.a_address[2:0]; // Per TL spec, address must be aligned to size
            mask_chk     = 1'b1;
            fulldata_chk = &tl_i.a_mask[7:0];     // Given 8-byte transfer, all mask bits should be set
          end else begin
            addr_sz_chk  = 1'b0;
            mask_chk     = 1'b0;
            fulldata_chk = 1'b0;
          end // end if (DW==64)
        end

        default: begin // Unsupported/invalid Sizes
          addr_sz_chk  = 1'b0;
          mask_chk     = 1'b0;
          fulldata_chk = 1'b0;
        end
      endcase
    end else begin
      addr_sz_chk  = 1'b0;
      mask_chk     = 1'b0;
      fulldata_chk = 1'b0;
    end
  end

  assign a_config_allowed = addr_sz_chk
                          & mask_chk
                          & (op_get | op_partial | fulldata_chk) ;

  // Only 32/64 bit data width for current tlul_err
  `ASSERT_INIT(dataWidthOnly32_64_A, (DW == 32) || (DW == 64))
endmodule

