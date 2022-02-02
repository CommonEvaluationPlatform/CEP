//--------------------------------------------------------------------------------------
// Copyright 2021 Massachusetts Institute of Technology
// SPDX short identifier: BSD-2-Clause
//
// File Name:      spi_loopback.v
// Program:        Common Evaluation Platform (CEP)
// Description:   
// Notes:          
//
//--------------------------------------------------------------------------------------

module spi_loopback
  (
   // SPI Interface
   input      SCK,
   output reg MISO,
   input      MOSI,
   input      CS_n
   );

   initial MISO = 1'b1;
   always @(posedge  SCK) begin
      if (!CS_n) MISO <= MOSI;
   end
   
endmodule // spi_loopback