//======================================================================
//
// sha256_core.v
// -------------
// Verilog 2001 implementation of the SHA-256 hash function.
// This is the internal core with wide interfaces.
//
//
// Copyright (c) 2013 Secworks Sweden AB
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

module sha256_core(
                   input wire            clk,
                   input wire            reset_n,
                 
                   input wire            init,
                   input wire            next,

                   input wire [511 : 0]  block,
                   
                   output wire           ready,
                    
                   output wire [255 : 0] digest_out,
                   output wire           digest_valid
                  );

  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter H0 = 32'h6a09e667;
  parameter H1 = 32'hbb67ae85;
  parameter H2 = 32'h3c6ef372;
  parameter H3 = 32'ha54ff53a;
  parameter H4 = 32'h510e527f;
  parameter H5 = 32'h9b05688c;
  parameter H6 = 32'h1f83d9ab;
  parameter H7 = 32'h5be0cd19;

  parameter CTRL_IDLE   = 0;
  parameter CTRL_INIT   = 1;
  parameter CTRL_NEXT   = 2;
  parameter CTRL_ROUNDS = 3;
  parameter CTRL_DONE   = 4;
  
  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [2 : 0] sha256_ctrl_reg;
  reg [2 : 0] sha256_ctrl_new;
  reg sha256_ctrl_we;
   
  reg [6 : 0] t_ctr_reg;
  reg [6 : 0] t_ctr_new;
  reg t_ctr_we;
  reg t_ctr_inc;
  reg t_ctr_rst;

  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [5 : 0]   K_addr;
  wire [31 : 0] K;

  reg ready_flag;
  

  //----------------------------------------------------------------
  // Module instantiantions.
  //----------------------------------------------------------------
  sha256_k_constants k_constants(
                                 .addr(K_addr),
                                 .K(K)
                                 );

  
  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready = ready_flag;
  
  
  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with synchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk)
    begin : reg_update
      if (!reset_n)
        begin

          t_ctr_reg       = 7'b0000000;
          sha256_ctrl_reg = CTRL_IDLE;
        end
      else
        begin
          
          if (t_ctr_we)
            begin
              t_ctr_reg <= t_ctr_new;
            end
          
          if (sha256_ctrl_we)
            begin
              sha256_ctrl_reg <= sha256_ctrl_new;
            end
        end
    end // reg_update

  
  //----------------------------------------------------------------
  // t_ctr
  // Update logic for the round counter, a monotonically 
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : t_ctr
      t_ctr_new = 0;
      t_ctr_we  = 0;
      
      if (t_ctr_rst)
        begin
          t_ctr_new = 0;
          t_ctr_we  = 1;
        end

      if (t_ctr_inc)
        begin
          t_ctr_new = t_ctr_reg + 1;
          t_ctr_we  = 1;
        end
    end // t_ctr

  
  //----------------------------------------------------------------
  // sha256_ctrl_fsm
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @*
    begin : sha256_ctrl_fsm
      ready_flag = 0;

      t_ctr_inc = 0;
      t_ctr_rst = 0;
      
      sha256_ctrl_new = CTRL_IDLE;
      sha256_ctrl_we  = 0;
      
      case (sha256_ctrl_reg)
        CTRL_IDLE:
          begin
          end

        CTRL_INIT:
          begin
          end
        
        CTRL_NEXT:
          begin
          end
        
        CTRL_ROUNDS:
          begin
          end

        CTRL_DONE:
          begin
          end
      endcase // case (sha256_ctrl_reg)
    end // sha256_ctrl_fsm
    
endmodule // sha256_core

//======================================================================
// EOF sha256_core.v
//======================================================================
