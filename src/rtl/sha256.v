//======================================================================
//
// sha256.v
// --------
// Top level wrapper for the SHA-256 hash function providing
// a simple memory like interface with 32 bit data access.
//
//
// Copyright (c) 2013  Secworks Sweden AB
// 
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the following 
// conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright 
//    notice, this list of conditions and the following disclaimer. 
// 
// 2. Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the 
//    distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module sha256(
              // Clock and reset.
              input wire           clk,
              input wire           reset_n,
              
              // Control.
              input wire           cs,
              input wire           write_read,
              
              // Data ports.
              input wire  [7 : 0]  address,
              input wire  [31 : 0] data_in,
              output wire [31 : 0] data_out
             );

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter ADDR_CTRL        = 8'h00;
  parameter CTRL_INIT_BIT    = 0;
  parameter CTRL_NEXT_BIT    = 1;

  parameter ADDR_STATUS      = 8'h01;
  parameter STATUS_READY_BIT = 0;
  parameter STATUS_VALID_BIT = 1;
                             
  parameter ADDR_BLOCK0    = 8'h10;
  parameter ADDR_BLOCK1    = 8'h11;
  parameter ADDR_BLOCK2    = 8'h12;
  parameter ADDR_BLOCK3    = 8'h13;
  parameter ADDR_BLOCK4    = 8'h14;
  parameter ADDR_BLOCK5    = 8'h15;
  parameter ADDR_BLOCK6    = 8'h16;
  parameter ADDR_BLOCK7    = 8'h17;
  parameter ADDR_BLOCK8    = 8'h18;
  parameter ADDR_BLOCK9    = 8'h19;
  parameter ADDR_BLOCK10   = 8'h1a;
  parameter ADDR_BLOCK11   = 8'h1b;
  parameter ADDR_BLOCK12   = 8'h1c;
  parameter ADDR_BLOCK13   = 8'h1d;
  parameter ADDR_BLOCK14   = 8'h1e;
  parameter ADDR_BLOCK15   = 8'h1f;
                             
  parameter ADDR_DIGEST0   = 8'h20;
  parameter ADDR_DIGEST1   = 8'h21;
  parameter ADDR_DIGEST2   = 8'h22;
  parameter ADDR_DIGEST3   = 8'h23;
  parameter ADDR_DIGEST4   = 8'h24;
  parameter ADDR_DIGEST5   = 8'h25;
  parameter ADDR_DIGEST6   = 8'h26;
  parameter ADDR_DIGEST7   = 8'h27;

  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg init_reg;
  reg init_new;
  reg init_we;
  
  reg next_reg;
  reg next_new;
  reg next_we;
  
  reg ready_reg;

  reg [31 : 0] block0_reg;
  reg [31 : 0] block0_new;
  reg          block0_we;
  reg [31 : 0] block1_reg;
  reg [31 : 0] block1_new;
  reg          block1_we;
  reg [31 : 0] block2_reg;
  reg [31 : 0] block2_new;
  reg          block2_we;
  reg [31 : 0] block3_reg;
  reg [31 : 0] block3_new;
  reg          block3_we;
  reg [31 : 0] block4_reg;
  reg [31 : 0] block4_new;
  reg          block4_we;
  reg [31 : 0] block5_reg;
  reg [31 : 0] block5_new;
  reg          block5_we;
  reg [31 : 0] block6_reg;
  reg [31 : 0] block6_new;
  reg          block6_we;
  reg [31 : 0] block7_reg;
  reg [31 : 0] block7_new;
  reg          block7_we;
  reg [31 : 0] block8_reg;
  reg [31 : 0] block8_new;
  reg          block8_we;
  reg [31 : 0] block9_reg;
  reg [31 : 0] block9_new;
  reg          block9_we;
  reg [31 : 0] block10_reg;
  reg [31 : 0] block10_new;
  reg          block10_we;
  reg [31 : 0] block11_reg;
  reg [31 : 0] block11_new;
  reg          block11_we;
  reg [31 : 0] block12_reg;
  reg [31 : 0] block12_new;
  reg          block12_we;
  reg [31 : 0] block13_reg;
  reg [31 : 0] block13_new;
  reg          block13_we;
  reg [31 : 0] block14_reg;
  reg [31 : 0] block14_new;
  reg          block14_we;
  reg [31 : 0] block15_reg;
  reg [31 : 0] block15_new;
  reg          block15_we;

  reg [255 : 0] digest_reg;
  reg [255 : 0] digest_new;
  reg           digest_we;

  reg digest_valid_reg;

  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire           core_init;
  wire           core_next;
  wire           core_ready;
  wire [511 : 0] core_block;
  wire [255 : 0] core_digest;
  wire           core_digest_valid;

  reg [31 : 0]   tmp_data_out;
  
  
  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign core_init = init_reg;

  assign core_next = next_reg;

  assign core_block = {block0_reg, block1_reg, block2_reg, block3_reg,
                       block4_reg, block5_reg, block6_reg, block7_reg,
                       block8_reg, block9_reg, block10_reg, block11_reg,
                       block12_reg, block13_reg, block14_reg, block15_reg};

  assign data_out = tmp_data_out;

             
  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  sha256_core core(
                   .clk(clk),
                   .reset_n(reset_n),
                   
                   .init(core_init),
                   .next(core_next),
                  
                   .block(core_block),
                   
                   .ready(core_ready),
                   
                   .digest(core_digest),
                   .digest_valid(core_digest_valid)
                  );
  
  
  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (!reset_n)
        begin
          init_reg         <= 0;
          next_reg         <= 0;
          ready_reg        <= 0;
          digest_reg       <= 256'h0000000000000000000000000000000000000000000000000000000000000000;
          digest_valid_reg <= 0;
          block0_reg       <= 32'h00000000;
          block1_reg       <= 32'h00000000;
          block2_reg       <= 32'h00000000;
          block3_reg       <= 32'h00000000;
          block4_reg       <= 32'h00000000;
          block5_reg       <= 32'h00000000;
          block6_reg       <= 32'h00000000;
          block7_reg       <= 32'h00000000;
          block8_reg       <= 32'h00000000;
          block9_reg       <= 32'h00000000;
          block10_reg      <= 32'h00000000;
          block11_reg      <= 32'h00000000;
          block12_reg      <= 32'h00000000;
          block13_reg      <= 32'h00000000;
          block14_reg      <= 32'h00000000;
          block15_reg      <= 32'h00000000;
        end
      else
        begin
          ready_reg        <= core_ready;
          digest_valid_reg <= core_digest_valid;

          if (init_we)
            begin
              init_reg <= init_new;
            end

          if (next_we)
            begin
              next_reg <= next_new;
            end
          
          if (core_digest_valid)
            begin
              digest_reg <= core_digest;
            end

          if (block0_we)
            begin
              block0_reg <= block0_new;
            end

          if (block1_we)
            begin
              block1_reg <= block1_new;
            end

          if (block2_we)
            begin
              block2_reg <= block2_new;
            end

          if (block3_we)
            begin
              block3_reg <= block3_new;
            end

          if (block4_we)
            begin
              block4_reg <= block4_new;
            end

          if (block5_we)
            begin
              block5_reg <= block5_new;
            end

          if (block6_we)
            begin
              block6_reg <= block6_new;
            end

          if (block7_we)
            begin
              block7_reg <= block7_new;
            end

          if (block8_we)
            begin
              block8_reg <= block8_new;
            end

          if (block9_we)
            begin
              block9_reg <= block9_new;
            end

          if (block10_we)
            begin
              block10_reg <= block10_new;
            end

          if (block11_we)
            begin
              block11_reg <= block11_new;
            end

          if (block12_we)
            begin
              block12_reg <= block12_new;
            end

          if (block13_we)
            begin
              block13_reg <= block13_new;
            end

          if (block14_we)
            begin
              block14_reg <= block14_new;
            end

          if (block15_we)
            begin
              block15_reg <= block15_new;
            end
          
        end
    end // reg_update


  //----------------------------------------------------------------
  // Address decoder logic.
  //----------------------------------------------------------------
  always @*
    begin : addr_decoder
      init_new    = 0;
      init_we     = 0;
      next_new    = 0;
      next_we     = 0;
      block0_new  = 32'h00000000;
      block0_we   = 0;
      block1_new  = 32'h00000000;
      block1_we   = 0;
      block2_new  = 32'h00000000;
      block2_we   = 0;
      block3_new  = 32'h00000000;
      block3_we   = 0;
      block4_new  = 32'h00000000;
      block4_we   = 0;
      block5_new  = 32'h00000000;
      block5_we   = 0;
      block6_new  = 32'h00000000;
      block6_we   = 0;
      block7_new  = 32'h00000000;
      block7_we   = 0;
      block8_new  = 32'h00000000;
      block8_we   = 0;
      block9_new  = 32'h00000000;
      block9_we   = 0;
      block10_new = 32'h00000000;
      block10_we  = 0;
      block11_new = 32'h00000000;
      block11_we  = 0;
      block12_new = 32'h00000000;
      block12_we  = 0;
      block13_new = 32'h00000000;
      block13_we  = 0;
      block14_new = 32'h00000000;
      block14_we  = 0;
      block15_new = 32'h00000000;
      block15_we  = 0;
      
      
      if (cs)
        begin
          if (write_read)
            begin
              case (address)
                
                default:
                  begin
                    // Empty since default assignemnts are handled
                    // outside of the if-mux construct.
                  end
              endcase // case (address)
            end // if (write_read)

          else
            begin
              case (address)
                
                default:
                  begin
                    // Empty since default assignemnts are handled
                    // outside of the if-mux construct.                  
                  end
              endcase // case (address)
            end
        end
    end // addr_decoder
endmodule // sha256

//======================================================================
// EOF sha256.v
//======================================================================


