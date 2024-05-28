//======================================================================
//
// sha256_final_padding.v
// ----------------------
// Implementation of SHA-256 final padding according to
// NIST FIPS 180-4. By and large a combinational module with some
// muxes and a FSM.
//
// Note that we assume that bits in the final block that
// don't contain the message are zero.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2024,  Asssured AB
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

module sha256_final_padding(
			    input wire            clk,
			    input wire            reset_n,

			    input wire            init_in,
			    input wire            next_in,
			    input wire            final_in,
			    input wire [8 : 0]    final_len,
			    input wire [511 : 0]  block_in,

			    input wire            core_ready,

			    output wire           init_out,
			    output wire           next_out,
			    output wire [511 : 0] block_out
			   );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE   = 1'h0;
  localparam CTRL_FINAL  = 1'h1;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [8 : 0]  final_len_reg;
  reg [8 : 0]  final_len_we;

  reg [63 : 0] bit_ctr_reg;
  reg [63 : 0] bit_ctr_new;
  reg          bit_ctr_rst;
  reg          bit_ctr_block_inc;
  reg          bit_ctr_we;

  reg          sha256_final_padding_ctrl_reg;
  reg          sha256_final_padding_ctrl_new;
  reg          sha256_final_padding_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [1 : 0]   block_out_mux_ctrl;
  reg [511 : 0] tmp_block_out;
  reg           tmp_next_out;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign init_out  = init_in;
  assign next_out  = tmp_next_out;
  assign block_out = tmp_block_out;


  //----------------------------------------------------------------
  // reg_update
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      integer i;

      if (!reset_n) begin
	final_len_reg                 <= 9'h0;
	bit_ctr_reg                   <= 64'h0;
	sha256_final_padding_ctrl_reg <= CTRL_IDLE;
      end

      else begin
	if (final_len_we) begin
	  final_len_reg <= final_len;
	end

	if (bit_ctr_we) begin
	  bit_ctr_reg <= bit_ctr_new;
	end

	if (sha256_final_padding_ctrl_we) begin
	  sha256_final_padding_ctrl_reg <= sha256_final_padding_ctrl_new;
	end
      end // reg_update
    end


  //----------------------------------------------------------------
  // bit_ctr
  //----------------------------------------------------------------
  always @*
    begin : bit_ctr
      bit_ctr_new = 64'h0;
      bit_ctr_we  = 1'h0;

      if (bit_ctr_rst) begin
	bit_ctr_new = 64'h0;
 	bit_ctr_we  = 1'h1;
      end

      if (bit_ctr_block_inc) begin
	bit_ctr_new = bit_ctr_reg + 9'h100;
 	bit_ctr_we  = 1'h1;
      end
    end


  //----------------------------------------------------------------
  // sha256_final_padding_ctrl
  // Yes, mix of data and control path.
  //----------------------------------------------------------------
  always @*
    begin : sha256_final_padding_ctrl
      reg [63 : 0] msg_len;

      bit_ctr_rst                   = 1'h0;
      bit_ctr_block_inc             = 1'h0;
      final_len_we                  = 1'h0;
      tmp_block_out                 = 512'h0;
      tmp_next_out                  = 1'h0;
      msg_len                       = 64'h0;
      sha256_final_padding_ctrl_new = CTRL_IDLE;
      sha256_final_padding_ctrl_we  = 1'h0;

      case (sha256_final_padding_ctrl_reg)
	CTRL_IDLE: begin
	  if (init_in) begin
	    bit_ctr_rst = 1'h1;
	  end

	  if (next_in) begin
	    bit_ctr_block_inc = 1'h1;
	    tmp_block_out     = block_in;
	    tmp_next_out      = 1'h1;
	  end

	  if (final_in) begin
	    msg_len = bit_ctr_reg + final_len;

	    if (final_len < 448) begin
	      // We fit in the final block.
	      tmp_next_out                     = 1'h1;
	      tmp_block_out                    = block_in;
	      tmp_block_out[(511 - final_len)] = 1'h1;
	      tmp_block_out[63 : 0]            = msg_len;
	    end

	    else if (final_len < 512) begin
	      // We fit the one, but not the counter.
	      // We will need another block.
	      final_len_we                      = 1'h1;
	      tmp_next_out                      = 1'h1;
	      tmp_block_out                     = block_in;
	      tmp_block_out[(511 - final_len)]  = 1'h1;
	      sha256_final_padding_ctrl_new     = CTRL_FINAL;
	      sha256_final_padding_ctrl_we      = 1'h1;
	    end

	    else begin
	      // The whole block is filled.
	      // We will need another block.
	      final_len_we                  = 1'h1;
	      tmp_next_out                  = 1'h1;
	      tmp_block_out                 = block_in;
	      sha256_final_padding_ctrl_new = CTRL_FINAL;
	      sha256_final_padding_ctrl_we  = 1'h1;
	    end
	  end
	end


	CTRL_FINAL: begin
	  msg_len                       = bit_ctr_reg + final_len_reg;
	  sha256_final_padding_ctrl_new = CTRL_IDLE;
	  sha256_final_padding_ctrl_we  = 1'h1;

	  if (core_ready) begin
	    if (final_len_reg < 512) begin
	      tmp_block_out[63 : 0] = msg_len;
	    end
	    else begin
	      tmp_block_out[511]    = 1'h1;
	      tmp_block_out[63 : 0] = msg_len;
	    end
	  end
	end

	default:
	  begin
	  end
      endcase // case (sha26_padding_ctrl_reg)
    end

endmodule // sha256_final_padding

//======================================================================
// EOF sha256_final_padding.v
//======================================================================
