//======================================================================
//
// sha256_w_mem.v
// --------------
// The W memory. This includes functionality to expand the block
// into 64 words.
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

module sha256_w_mem(
                    input wire [511 : 0] block,
                    input wire           init,
                    input wire  [5 : 0]  addr,
                    output wire          ready,
                    output wire [31 : 0] w
                   );

  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter H0_0 = 32'h6a09e667;
  parameter H0_1 = 32'hbb67ae85;
  parameter H0_2 = 32'h3c6ef372;
  parameter H0_3 = 32'ha54ff53a;
  parameter H0_4 = 32'h510e527f;
  parameter H0_5 = 32'h9b05688c;
  parameter H0_6 = 32'h1f83d9ab;
  parameter H0_7 = 32'h5be0cd19;

  parameter CTRL_IDLE   = 0;
  parameter CTRL_UPDATE = 1;
  
  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] w0_reg;
  reg [31 : 0] w1_reg;
  reg [31 : 0] w2_reg;
  reg [31 : 0] w3_reg;
  reg [31 : 0] w4_reg;
  reg [31 : 0] w5_reg;
  reg [31 : 0] w6_reg;
  reg [31 : 0] w7_reg;
  reg [31 : 0] w8_reg;
  reg [31 : 0] w9_reg;
  reg [31 : 0] w10_reg;
  reg [31 : 0] w11_reg;
  reg [31 : 0] w12_reg;
  reg [31 : 0] w13_reg;
  reg [31 : 0] w14_reg;
  reg [31 : 0] w15_reg;
  reg          w0_15_we;
  
  reg [31 : 0] w16_reg;
  reg [31 : 0] w16_new;
  reg          w16_we;

  reg [5 : 0] w_ctr_reg;
  reg [5 : 0] w_ctr_new;
  reg         w_ctr_we;
  reg         w_ctr_inc;
  reg         w_ctr_set;
  
  reg [1 : 0]  sha256_w_mem_fsm_reg;
  reg [1 : 0]  sha256_w_mem_fsm_reg;
  reg          sha256_w_mem_fsm_we;
  
  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] w_tmp;
  

  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign w = w_tmp;
  
  
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
          w0_reg          <= 32'h00000000;
          w1_reg          <= 32'h00000000;
          w2_reg          <= 32'h00000000;
          w3_reg          <= 32'h00000000;
          w4_reg          <= 32'h00000000;
          w5_reg          <= 32'h00000000;
          w6_reg          <= 32'h00000000;
          w7_reg          <= 32'h00000000;
          w8_reg          <= 32'h00000000;
          w9_reg          <= 32'h00000000;
          w10_reg         <= 32'h00000000;
          w11_reg         <= 32'h00000000;
          w12_reg         <= 32'h00000000;
          w13_reg         <= 32'h00000000;
          w14_reg         <= 32'h00000000;
          w15_reg         <= 32'h00000000;
          sha256_ctrl_reg <= CTRL_IDLE;
        end
      else
        begin

          if (w0_15_we)
            begin
              w0 <= block[511 : 480];
              w0 <= block[479 : 448];
              w0 <= block[447 : 416];
              w0 <= block[415 : 384];
              w0 <= block[383 : 352];
              w0 <= block[351 : 320];
              w0 <= block[319 : 288];
              w0 <= block[287 : 256];
              w0 <= block[255 : 224];
              w0 <= block[223 : 192];
              w0 <= block[191 : 160];
              w0 <= block[159 : 128];
              w0 <= block[127 :  96];
              w0 <= block[95  :  64];
              w0 <= block[63  :  32];
              w0 <= block[31  :   0];
            end
          
          if (w_ctr_we)
            begin
              w_ctr_reg <= w_ctr_new;
            end
          
          if (sha256_w_mem_we)
            begin
              sha256_w_mem_reg <= sha256_w_mem_new;
            end
        end
    end // reg_update

  
  //----------------------------------------------------------------
  // addr_mux
  //
  // Mux for the external read operation.
  //----------------------------------------------------------------
  always @*
    begin : addr_mux
      case (addr)
        0:
          begin
            w_tmp = w0_reg;
          end
    end
  
  
  //----------------------------------------------------------------
  // w_schedule
  //----------------------------------------------------------------
  always @*
    begin : w_schedule
      w0_15_we = 0;

      if (w_init)
        begin
          w0_15_we = 1;
        end

      if (w_update)
        begin

        end
    end // w_schedule
  
  
  //----------------------------------------------------------------
  // w_ctr
  // W schedule adress counter. Counts from 0x10 to 0x3f and
  // is used to expand the block into words.
  //----------------------------------------------------------------
  always @*
    begin : w_ctr
      w_ctr_new = 0;
      w_ctr_we  = 0;
      
      if (w_ctr_set)
        begin
          w_ctr_new = 6'h10;
          w_ctr_we  = 1;
        end

      if (w_ctr_inc)
        begin
          w_ctr_new = w_ctr_reg + 1;
          w_ctr_we  = 1;
        end
    end // w_ctr

  
  //----------------------------------------------------------------
  // sha256_w_mem_fsm
  // Logic for the w shedule FSM.
  //----------------------------------------------------------------
  always @*
    begin : sha256_w_mem_fsm
      w_ctr_set       = 1;
      
      sha256_w_mem_fsm_new = CTRL_IDLE;
      sha256_w_mem_fsm_we  = 0;
      
      case (sha256_w_mem_fsm_reg)
        CTRL_IDLE:
          begin
            ready_flag = 1;
            
            if (init)
              begin
                w_init  = 1;
                w_ctr_set       = 1;
                
                sha256_w_mem_fsm = CTRL_UPDATE;
                sha256_w_mem_we  = 1;
              end

        CTRL_UPDATE:
          begin
            w_update  = 1;
            w_ctr_inc = 1;

            if (w_ctr_reg = 6'h3f)
              sha256_w_mem_fsm = CTRL_IDLE;
          end
      endcase // case (sha256_ctrl_reg)
    end // sha256_ctrl_fsm

endmodule // sha256_w_mem

//======================================================================
// sha256_w_mem.v
//======================================================================
