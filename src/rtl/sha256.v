//======================================================================
//
// sha256.v
// --------
// Top level wrapper for the SHA-256 hash function providing
// a simple memory like interface with 32 bit data access.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2013, 201, Secworks Sweden AB
// All rights reserved.
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
              input wire           we,

              // Data ports.
              input wire  [7 : 0]  address,
              input wire  [31 : 0] write_data,
              output wire [31 : 0] read_data,
              output wire          error
             );

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter ADDR_NAME0       = 8'h00;
  parameter ADDR_NAME1       = 8'h01;
  parameter ADDR_VERSION     = 8'h02;

  parameter ADDR_CTRL        = 8'h08;
  parameter CTRL_INIT_BIT    = 0;
  parameter CTRL_NEXT_BIT    = 1;
  parameter CTRL_MODE_BIT    = 2;

  parameter ADDR_STATUS      = 8'h09;
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

  parameter CORE_NAME0     = 32'h73686132; // "sha2"
  parameter CORE_NAME1     = 32'h2d323536; // "-256"
  parameter CORE_VERSION   = 32'h312e3830; // "1.80"

  parameter MODE_SHA_224   = 1'h0;
  parameter MODE_SHA_256   = 1'h1;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg init_reg;
  reg init_new;

  reg next_reg;
  reg next_new;

  reg mode_reg;
  reg mode_new;
  reg mode_we;

  reg ready_reg;

  reg [31 : 0] block_reg [0 : 15];
  reg          block_we;

  reg [255 : 0] digest_reg;

  reg digest_valid_reg;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire           core_ready;
  wire [511 : 0] core_block;
  wire [255 : 0] core_digest;
  wire           core_digest_valid;

  reg [31 : 0]   tmp_read_data;
  reg            tmp_error;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign core_block = {block_reg[00], block_reg[01], block_reg[02], block_reg[03],
                       block_reg[04], block_reg[05], block_reg[06], block_reg[07],
                       block_reg[08], block_reg[09], block_reg[10], block_reg[11],
                       block_reg[12], block_reg[13], block_reg[14], block_reg[15]};

  assign read_data = tmp_read_data;
  assign error     = tmp_error;


  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  sha256_core core(
                   .clk(clk),
                   .reset_n(reset_n),

                   .init(init_reg),
                   .next(next_reg),
                   .mode(mode_reg),

                   .block(core_block),

                   .ready(core_ready),

                   .digest(core_digest),
                   .digest_valid(core_digest_valid)
                  );


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      integer i;

      if (!reset_n)
        begin
          init_reg         <= 0;
          next_reg         <= 0;
          ready_reg        <= 0;
          mode_reg         <= MODE_SHA_256;
          digest_reg       <= 256'h0;
          digest_valid_reg <= 0;

          for (i = 0 ; i < 32 ; i = i + 1)
            block_reg[i] <= 32'h0;
        end
      else
        begin
          ready_reg        <= core_ready;
          digest_valid_reg <= core_digest_valid;
          init_reg         <= init_new;
          next_reg         <= next_new;

          if (mode_we)
            mode_reg <= mode_new;

          if (core_digest_valid)
            digest_reg <= core_digest;

          if (block_we)
            block_reg[address[3 : 0]] <= write_data;
        end
    end // reg_update


  //----------------------------------------------------------------
  // api_logic
  //
  // Implementation of the api logic. If cs is enabled will either
  // try to write to or read from the internal registers.
  //----------------------------------------------------------------
  always @*
    begin : api_logic
      init_new      = 0;
      next_new      = 0;
      mode_new      = 0;
      mode_we       = 0;
      block_we      = 0;
      tmp_read_data = 32'h0;
      tmp_error     = 0;

      if (cs)
        begin
          if (we)
            begin
              if (address == ADDR_CTRL)
                begin
                  init_new = write_data[CTRL_INIT_BIT];
                  next_new = write_data[CTRL_NEXT_BIT];
                  mode_new = write_data[CTRL_MODE_BIT];
                  mode_we  = 1;
                end

              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK15))
                block_we = 1;
            end // if (we)

          else
            begin
              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK15))
                tmp_read_data = block_reg[address[3 : 0]];

              case (address)
                // Read operations.
                ADDR_NAME0:
                  tmp_read_data = CORE_NAME0;

                ADDR_NAME1:
                  tmp_read_data = CORE_NAME1;

                ADDR_VERSION:
                  tmp_read_data = CORE_VERSION;

                ADDR_CTRL:
                  tmp_read_data = {29'h0, mode_reg, next_reg, init_reg};

                ADDR_STATUS:
                  tmp_read_data = {30'h0, digest_valid_reg, ready_reg};

                ADDR_DIGEST0:
                  tmp_read_data = digest_reg[255 : 224];

                ADDR_DIGEST1:
                  tmp_read_data = digest_reg[223 : 192];

                ADDR_DIGEST2:
                  tmp_read_data = digest_reg[191 : 160];

                ADDR_DIGEST3:
                  tmp_read_data = digest_reg[159 : 128];

                ADDR_DIGEST4:
                  tmp_read_data = digest_reg[127 :  96];

                ADDR_DIGEST5:
                  tmp_read_data = digest_reg[95  :  64];

                ADDR_DIGEST6:
                  tmp_read_data = digest_reg[63  :  32];

                ADDR_DIGEST7:
                  tmp_read_data = digest_reg[31  :   0];

                default:
                  begin
                    tmp_error = 1;
                  end
              endcase // case (address)
            end
        end
    end // addr_decoder
endmodule // sha256

//======================================================================
// EOF sha256.v
//======================================================================
