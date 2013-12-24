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
  reg          w16_we;
  reg [31 : 0] w17_reg;
  reg          w17_we;
  reg [31 : 0] w18_reg;
  reg          w18_we;
  reg [31 : 0] w19_reg;
  reg          w19_we;
  
  reg [31 : 0] w20_reg;
  reg          w20_we;
  reg [31 : 0] w21_reg;
  reg          w21_we;
  reg [31 : 0] w22_reg;
  reg          w22_we;
  reg [31 : 0] w23_reg;
  reg          w23_we;
  reg [31 : 0] w24_reg;
  reg          w24_we;
  reg [31 : 0] w25_reg;
  reg          w25_we;
  reg [31 : 0] w26_reg;
  reg          w26_we;
  reg [31 : 0] w27_reg;
  reg          w27_we;
  reg [31 : 0] w28_reg;
  reg          w28_we;
  reg [31 : 0] w29_reg;
  reg          w29_we;
  
  reg [31 : 0] w30_reg;
  reg          w30_we;
  reg [31 : 0] w31_reg;
  reg          w31_we;
  reg [31 : 0] w32_reg;
  reg          w32_we;
  reg [31 : 0] w33_reg;
  reg          w33_we;
  reg [31 : 0] w34_reg;
  reg          w34_we;
  reg [31 : 0] w35_reg;
  reg          w35_we;
  reg [31 : 0] w36_reg;
  reg          w36_we;
  reg [31 : 0] w37_reg;
  reg          w37_we;
  reg [31 : 0] w38_reg;
  reg          w38_we;
  reg [31 : 0] w39_reg;
  reg          w39_we;
  
  reg [31 : 0] w40_reg;
  reg          w40_we;
  reg [31 : 0] w41_reg;
  reg          w41_we;
  reg [31 : 0] w42_reg;
  reg          w42_we;
  reg [31 : 0] w43_reg;
  reg          w43_we;
  reg [31 : 0] w44_reg;
  reg          w44_we;
  reg [31 : 0] w45_reg;
  reg          w45_we;
  reg [31 : 0] w46_reg;
  reg          w46_we;
  reg [31 : 0] w47_reg;
  reg          w47_we;
  reg [31 : 0] w48_reg;
  reg          w48_we;
  reg [31 : 0] w49_reg;
  reg          w49_we;
  
  reg [31 : 0] w50_reg;
  reg          w50_we;
  reg [31 : 0] w51_reg;
  reg          w51_we;
  reg [31 : 0] w52_reg;
  reg          w52_we;
  reg [31 : 0] w53_reg;
  reg          w53_we;
  reg [31 : 0] w54_reg;
  reg          w54_we;
  reg [31 : 0] w55_reg;
  reg          w55_we;
  reg [31 : 0] w56_reg;
  reg          w56_we;
  reg [31 : 0] w57_reg;
  reg          w57_we;
  reg [31 : 0] w58_reg;
  reg          w58_we;
  reg [31 : 0] w59_reg;
  reg          w59_we;
  
  reg [31 : 0] w60_reg;
  reg          w60_we;
  reg [31 : 0] w61_reg;
  reg          w61_we;
  reg [31 : 0] w62_reg;
  reg          w62_we;
  reg [31 : 0] w63_reg;
  reg          w63_we;
  
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
  reg [31 : 0] w_new;

  reg [31 : 0] d1;
  reg [31 : 0] d0;
  reg [31 : 0] w_7;
  reg [31 : 0] w_16;
  
  
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
          w16_reg         <= 32'h00000000;
          w17_reg         <= 32'h00000000;
          w18_reg         <= 32'h00000000;
          w19_reg         <= 32'h00000000;

          w20_reg         <= 32'h00000000;
          w21_reg         <= 32'h00000000;
          w22_reg         <= 32'h00000000;
          w23_reg         <= 32'h00000000;
          w24_reg         <= 32'h00000000;
          w25_reg         <= 32'h00000000;
          w26_reg         <= 32'h00000000;
          w27_reg         <= 32'h00000000;
          w28_reg         <= 32'h00000000;
          w29_reg         <= 32'h00000000;

          w30_reg         <= 32'h00000000;
          w31_reg         <= 32'h00000000;
          w32_reg         <= 32'h00000000;
          w33_reg         <= 32'h00000000;
          w34_reg         <= 32'h00000000;
          w35_reg         <= 32'h00000000;
          w36_reg         <= 32'h00000000;
          w37_reg         <= 32'h00000000;
          w38_reg         <= 32'h00000000;
          w39_reg         <= 32'h00000000;

          w40_reg         <= 32'h00000000;
          w41_reg         <= 32'h00000000;
          w42_reg         <= 32'h00000000;
          w43_reg         <= 32'h00000000;
          w44_reg         <= 32'h00000000;
          w45_reg         <= 32'h00000000;
          w46_reg         <= 32'h00000000;
          w47_reg         <= 32'h00000000;
          w48_reg         <= 32'h00000000;
          w49_reg         <= 32'h00000000;

          w50_reg         <= 32'h00000000;
          w51_reg         <= 32'h00000000;
          w52_reg         <= 32'h00000000;
          w53_reg         <= 32'h00000000;
          w54_reg         <= 32'h00000000;
          w55_reg         <= 32'h00000000;
          w56_reg         <= 32'h00000000;
          w57_reg         <= 32'h00000000;
          w58_reg         <= 32'h00000000;
          w59_reg         <= 32'h00000000;

          w60_reg         <= 32'h00000000;
          w61_reg         <= 32'h00000000;
          w62_reg         <= 32'h00000000;
          w63_reg         <= 32'h00000000;

          w_ctr_reg       <= 6'h00;

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
          
          if (w16_we)
            begin
              w16_reg <= w_new;
            end
          
          if (w17_we)
            begin
              w17_reg <= w_new;
            end
          
          if (w18_we)
            begin
              w18_reg <= w_new;
            end
          
          if (w19_we)
            begin
              w19_reg <= w_new;
            end
          
          if (w20_we)
            begin
              w20_reg <= w_new;
            end
          
          if (w21_we)
            begin
              w21_reg <= w_new;
            end
          
          if (w22_we)
            begin
              w22_reg <= w_new;
            end
          
          if (w23_we)
            begin
              w23_reg <= w_new;
            end
          
          if (w24_we)
            begin
              w24_reg <= w_new;
            end
          
          if (w25_we)
            begin
              w25_reg <= w_new;
            end
          
          if (w26_we)
            begin
              w26_reg <= w_new;
            end
          
          if (w27_we)
            begin
              w27_reg <= w_new;
            end
          
          if (w28_we)
            begin
              w28_reg <= w_new;
            end
          
          if (w29_we)
            begin
              w29_reg <= w_new;
            end
          
          if (w30_we)
            begin
              w30_reg <= w_new;
            end
          
          if (w31_we)
            begin
              w31_reg <= w_new;
            end
          
          if (w32_we)
            begin
              w32_reg <= w_new;
            end
          
          if (w33_we)
            begin
              w33_reg <= w_new;
            end
          
          if (w34_we)
            begin
              w34_reg <= w_new;
            end
          
          if (w35_we)
            begin
              w35_reg <= w_new;
            end
          
          if (w36_we)
            begin
              w36_reg <= w_new;
            end
          
          if (w37_we)
            begin
              w37_reg <= w_new;
            end
          
          if (w38_we)
            begin
              w38_reg <= w_new;
            end
          
          if (w39_we)
            begin
              w39_reg <= w_new;
            end
          
          if (w40_we)
            begin
              w40_reg <= w_new;
            end
          
          if (w41_we)
            begin
              w41_reg <= w_new;
            end
          
          if (w42_we)
            begin
              w42_reg <= w_new;
            end
          
          if (w43_we)
            begin
              w43_reg <= w_new;
            end
          
          if (w44_we)
            begin
              w44_reg <= w_new;
            end
          
          if (w45_we)
            begin
              w45_reg <= w_new;
            end
          
          if (w46_we)
            begin
              w46_reg <= w_new;
            end
          
          if (w47_we)
            begin
              w47_reg <= w_new;
            end
          
          if (w48_we)
            begin
              w48_reg <= w_new;
            end
          
          if (w49_we)
            begin
              w49_reg <= w_new;
            end
          
          if (w50_we)
            begin
              w50_reg <= w_new;
            end
          
          if (w51_we)
            begin
              w51_reg <= w_new;
            end
          
          if (w52_we)
            begin
              w52_reg <= w_new;
            end
          
          if (w53_we)
            begin
              w53_reg <= w_new;
            end
          
          if (w54_we)
            begin
              w54_reg <= w_new;
            end
          
          if (w55_we)
            begin
              w55_reg <= w_new;
            end
          
          if (w56_we)
            begin
              w56_reg <= w_new;
            end
          
          if (w57_we)
            begin
              w57_reg <= w_new;
            end
          
          if (w58_we)
            begin
              w58_reg <= w_new;
            end
          
          if (w59_we)
            begin
              w59_reg <= w_new;
            end
          
          if (w60_we)
            begin
              w60_reg <= w_new;
            end
          
          if (w61_we)
            begin
              w61_reg <= w_new;
            end
          
          if (w62_we)
            begin
              w62_reg <= w_new;
            end
          
          if (w63_we)
            begin
              w63_reg <= w_new;
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
  // external_addr_mux
  //
  // Mux for the external read operation. This is where we exract
  // the W variable.
  //----------------------------------------------------------------
  always @*
    begin : external_addr_mux
      case (addr)
        0:
          begin
            w_tmp = w0_reg;
          end
        1:
          begin
            w_tmp = w1_reg;
          end
        2:
          begin
            w_tmp = w2_reg;
          end
        3:
          begin
            w_tmp = w3_reg;
          end
        4:
          begin
            w_tmp = w4_reg;
          end
        5:
          begin
            w_tmp = w5_reg;
          end
        6:
          begin
            w_tmp = w6_reg;
          end
        7:
          begin
            w_tmp = w7_reg;
          end
        8:
          begin
            w_tmp = w8_reg;
          end
        9:
          begin
            w_tmp = w9_reg;
          end

        10:
          begin
            w_tmp = w10_reg;
          end
        11:
          begin
            w_tmp = w11_reg;
          end
        12:
          begin
            w_tmp = w12_reg;
          end
        13:
          begin
            w_tmp = w13_reg;
          end
        14:
          begin
            w_tmp = w14_reg;
          end
        15:
          begin
            w_tmp = w15_reg;
          end
        16:
          begin
            w_tmp = w16_reg;
          end
        17:
          begin
            w_tmp = w17_reg;
          end
        18:
          begin
            w_tmp = w18_reg;
          end
        19:
          begin
            w_tmp = w19_reg;
          end

        20:
          begin
            w_tmp = w20_reg;
          end
        21:
          begin
            w_tmp = w21_reg;
          end
        22:
          begin
            w_tmp = w22_reg;
          end
        23:
          begin
            w_tmp = w23_reg;
          end
        24:
          begin
            w_tmp = w24_reg;
          end
        25:
          begin
            w_tmp = w25_reg;
          end
        26:
          begin
            w_tmp = w26_reg;
          end
        27:
          begin
            w_tmp = w27_reg;
          end
        28:
          begin
            w_tmp = w28_reg;
          end
        29:
          begin
            w_tmp = w29_reg;
          end

        30:
          begin
            w_tmp = w30_reg;
          end
        31:
          begin
            w_tmp = w31_reg;
          end
        32:
          begin
            w_tmp = w32_reg;
          end
        33:
          begin
            w_tmp = w33_reg;
          end
        34:
          begin
            w_tmp = w34_reg;
          end
        35:
          begin
            w_tmp = w35_reg;
          end
        36:
          begin
            w_tmp = w36_reg;
          end
        37:
          begin
            w_tmp = w37_reg;
          end
        38:
          begin
            w_tmp = w38_reg;
          end
        39:
          begin
            w_tmp = w39_reg;
          end

        40:
          begin
            w_tmp = w40_reg;
          end
        41:
          begin
            w_tmp = w41_reg;
          end
        42:
          begin
            w_tmp = w42_reg;
          end
        43:
          begin
            w_tmp = w43_reg;
          end
        44:
          begin
            w_tmp = w44_reg;
          end
        45:
          begin
            w_tmp = w45_reg;
          end
        46:
          begin
            w_tmp = w46_reg;
          end
        47:
          begin
            w_tmp = w47_reg;
          end
        48:
          begin
            w_tmp = w48_reg;
          end
        49:
          begin
            w_tmp = w49_reg;
          end

        50:
          begin
            w_tmp = w50_reg;
          end
        51:
          begin
            w_tmp = w51_reg;
          end
        52:
          begin
            w_tmp = w52_reg;
          end
        53:
          begin
            w_tmp = w53_reg;
          end
        54:
          begin
            w_tmp = w54_reg;
          end
        55:
          begin
            w_tmp = w55_reg;
          end
        56:
          begin
            w_tmp = w56_reg;
          end
        57:
          begin
            w_tmp = w57_reg;
          end
        58:
          begin
            w_tmp = w58_reg;
          end
        59:
          begin
            w_tmp = w59_reg;
          end

        60:
          begin
            w_tmp = w60_reg;
          end
        61:
          begin
            w_tmp = w61_reg;
          end
        62:
          begin
            w_tmp = w62_reg;
          end
        63:
          begin
            w_tmp = w63_reg;
          end
      endcase // case (addr)
    end // external_addr_mux


  //----------------------------------------------------------------
  // w_16_logic
  //----------------------------------------------------------------
  always @*
    begin : w_16_logic
      reg [5 : 0] w_16_addr;

      w_16_1ddr = w_ctr_reg - 16;

      case (w_16_addr)
        0:
          begin
            w_16 = w0_reg;
          end
        1:
          begin
            w_16 = w1_reg;
          end
        2:
          begin
            w_16 = w2_reg;
          end
        3:
          begin
            w_16 = w3_reg;
          end
        4:
          begin
            w_16 = w4_reg;
          end
        5:
          begin
            w_16 = w5_reg;
          end
        6:
          begin
            w_16 = w6_reg;
          end
        7:
          begin
            w_16 = w7_reg;
          end
        8:
          begin
            w_16 = w8_reg;
          end
        9:
          begin
            w_16 = w9_reg;
          end

        10:
          begin
            w_16 = w10_reg;
          end
        11:
          begin
            w_16 = w11_reg;
          end
        12:
          begin
            w_16 = w12_reg;
          end
        13:
          begin
            w_16 = w13_reg;
          end
        14:
          begin
            w_16 = w14_reg;
          end
        15:
          begin
            w_16 = w15_reg;
          end
        16:
          begin
            w_16 = w16_reg;
          end
        17:
          begin
            w_16 = w17_reg;
          end
        18:
          begin
            w_16 = w18_reg;
          end
        19:
          begin
            w_16 = w19_reg;
          end

        20:
          begin
            w_16 = w20_reg;
          end
        21:
          begin
            w_16 = w21_reg;
          end
        22:
          begin
            w_16 = w22_reg;
          end
        23:
          begin
            w_16 = w23_reg;
          end
        24:
          begin
            w_16 = w24_reg;
          end
        25:
          begin
            w_16 = w25_reg;
          end
        26:
          begin
            w_16 = w26_reg;
          end
        27:
          begin
            w_16 = w27_reg;
          end
        28:
          begin
            w_16 = w28_reg;
          end
        29:
          begin
            w_16 = w29_reg;
          end

        30:
          begin
            w_16 = w30_reg;
          end
        31:
          begin
            w_16 = w31_reg;
          end
        32:
          begin
            w_16 = w32_reg;
          end
        33:
          begin
            w_16 = w33_reg;
          end
        34:
          begin
            w_16 = w34_reg;
          end
        35:
          begin
            w_16 = w35_reg;
          end
        36:
          begin
            w_16 = w36_reg;
          end
        37:
          begin
            w_16 = w37_reg;
          end
        38:
          begin
            w_16 = w38_reg;
          end
        39:
          begin
            w_16 = w39_reg;
          end

        40:
          begin
            w_16 = w40_reg;
          end
        41:
          begin
            w_16 = w41_reg;
          end
        42:
          begin
            w_16 = w42_reg;
          end
        43:
          begin
            w_16 = w43_reg;
          end
        44:
          begin
            w_16 = w44_reg;
          end
        45:
          begin
            w_16 = w45_reg;
          end
        46:
          begin
            w_16 = w46_reg;
          end
        47:
          begin
            w_16 = w47_reg;
          end
      endcase // case (w_16_addr)
    end // w_16_logic


  //----------------------------------------------------------------
  // d0_logic
  //----------------------------------------------------------------
  always @*
    begin : d0_logic
      reg [31 : 0] w_15;
      reg [5 : 0]  w_15_addr;

      w_15_1ddr = w_ctr_reg - 15;

      case (w_15_addr)
        1:
          begin
            w_15 = w1_reg;
          end
        2:
          begin
            w_15 = w2_reg;
          end
        3:
          begin
            w_15 = w3_reg;
          end
        4:
          begin
            w_15 = w4_reg;
          end
        5:
          begin
            w_15 = w5_reg;
          end
        6:
          begin
            w_15 = w6_reg;
          end
        7:
          begin
            w_15 = w7_reg;
          end
        8:
          begin
            w_15 = w8_reg;
          end
        9:
          begin
            w_15 = w9_reg;
          end

        10:
          begin
            w_15 = w10_reg;
          end
        11:
          begin
            w_15 = w11_reg;
          end
        12:
          begin
            w_15 = w12_reg;
          end
        13:
          begin
            w_15 = w13_reg;
          end
        14:
          begin
            w_15 = w14_reg;
          end
        15:
          begin
            w_15 = w15_reg;
          end
        16:
          begin
            w_15 = w16_reg;
          end
        17:
          begin
            w_15 = w17_reg;
          end
        18:
          begin
            w_15 = w18_reg;
          end
        19:
          begin
            w_15 = w19_reg;
          end

        20:
          begin
            w_15 = w20_reg;
          end
        21:
          begin
            w_15 = w21_reg;
          end
        22:
          begin
            w_15 = w22_reg;
          end
        23:
          begin
            w_15 = w23_reg;
          end
        24:
          begin
            w_15 = w24_reg;
          end
        25:
          begin
            w_15 = w25_reg;
          end
        26:
          begin
            w_15 = w26_reg;
          end
        27:
          begin
            w_15 = w27_reg;
          end
        28:
          begin
            w_15 = w28_reg;
          end
        29:
          begin
            w_15 = w29_reg;
          end

        30:
          begin
            w_15 = w30_reg;
          end
        31:
          begin
            w_15 = w31_reg;
          end
        32:
          begin
            w_15 = w32_reg;
          end
        33:
          begin
            w_15 = w33_reg;
          end
        34:
          begin
            w_15 = w34_reg;
          end
        35:
          begin
            w_15 = w35_reg;
          end
        36:
          begin
            w_15 = w36_reg;
          end
        37:
          begin
            w_15 = w37_reg;
          end
        38:
          begin
            w_15 = w38_reg;
          end
        39:
          begin
            w_15 = w39_reg;
          end

        40:
          begin
            w_15 = w40_reg;
          end
        41:
          begin
            w_15 = w41_reg;
          end
        42:
          begin
            w_15 = w42_reg;
          end
        43:
          begin
            w_15 = w43_reg;
          end
        44:
          begin
            w_15 = w44_reg;
          end
        45:
          begin
            w_15 = w45_reg;
          end
        46:
          begin
            w_15 = w46_reg;
          end
        47:
          begin
            w_15 = w47_reg;
          end
        48:
          begin
            w_15 = w48_reg;
          end
      endcase // case (w_15_addr)

      d0 = {w_15[6  : 0], w_15[31 :  7]} ^ 
           {w_15[17 : 0], w_15[31 : 18]} ^ 
           {3'b000, w_15[31 : 3]};

    end // d0_logic


  //----------------------------------------------------------------
  // w_schedule
  //----------------------------------------------------------------
  always @*
    begin : w_schedule
      w0_15_we = 0;
      w16_we   = 0;
      w17_we   = 0;
      w18_we   = 0;
      w19_we   = 0;
      w20_we   = 0;
      w21_we   = 0;
      w22_we   = 0;
      w23_we   = 0;
      w24_we   = 0;
      w25_we   = 0;
      w26_we   = 0;
      w27_we   = 0;
      w28_we   = 0;
      w29_we   = 0;
      w30_we   = 0;
      w31_we   = 0;
      w32_we   = 0;
      w33_we   = 0;
      w34_we   = 0;
      w35_we   = 0;
      w36_we   = 0;
      w37_we   = 0;
      w38_we   = 0;
      w39_we   = 0;
      w40_we   = 0;
      w41_we   = 0;
      w42_we   = 0;
      w43_we   = 0;
      w44_we   = 0;
      w45_we   = 0;
      w46_we   = 0;
      w47_we   = 0;
      w48_we   = 0;
      w49_we   = 0;
      w50_we   = 0;
      w51_we   = 0;
      w52_we   = 0;
      w53_we   = 0;
      w54_we   = 0;
      w55_we   = 0;
      w56_we   = 0;
      w57_we   = 0;
      w58_we   = 0;
      w59_we   = 0;
      w60_we   = 0;
      w61_we   = 0;
      w62_we   = 0;
      w63_we   = 0;
      
      w_new = d1 + w_7 + d0 + w_16;
      
      if (w_init)
        begin
          w0_15_we = 1;
        end

      if (w_update)
        begin
          case (w_ctr_reg)
            16:
              begin
                w16_we = 1;
              end
            17:
              begin
                w17_we = 1;
              end
            18:
              begin
                w18_we = 1;
              end
            19:
              begin
                w19_we = 1;
              end

            20:
              begin
                w20_we = 1;
              end
            21:
              begin
                w21_we = 1;
              end
            22:
              begin
                w22_we = 1;
              end
            23:
              begin
                w23_we = 1;
              end
            24:
              begin
                w24_we = 1;
              end
            25:
              begin
                w25_we = 1;
              end
            26:
              begin
                w26_we = 1;
              end
            27:
              begin
                w27_we = 1;
              end
            28:
              begin
                w28_we = 1;
              end
            29:
              begin
                w29_we = 1;
              end

            30:
              begin
                w30_we = 1;
              end
            31:
              begin
                w31_we = 1;
              end
            32:
              begin
                w32_we = 1;
              end
            33:
              begin
                w33_we = 1;
              end
            34:
              begin
                w34_we = 1;
              end
            35:
              begin
                w35_we = 1;
              end
            36:
              begin
                w36_we = 1;
              end
            37:
              begin
                w37_we = 1;
              end
            38:
              begin
                w38_we = 1;
              end
            39:
              begin
                w39_we = 1;
              end

            40:
              begin
                w40_we = 1;
              end
            41:
              begin
                w41_we = 1;
              end
            42:
              begin
                w42_we = 1;
              end
            43:
              begin
                w43_we = 1;
              end
            44:
              begin
                w44_we = 1;
              end
            45:
              begin
                w45_we = 1;
              end
            46:
              begin
                w46_we = 1;
              end
            47:
              begin
                w47_we = 1;
              end
            48:
              begin
                w48_we = 1;
              end
            49:
              begin
                w49_we = 1;
              end

            50:
              begin
                w50_we = 1;
              end
            51:
              begin
                w51_we = 1;
              end
            52:
              begin
                w52_we = 1;
              end
            53:
              begin
                w53_we = 1;
              end
            54:
              begin
                w54_we = 1;
              end
            55:
              begin
                w55_we = 1;
              end
            56:
              begin
                w56_we = 1;
              end
            57:
              begin
                w57_we = 1;
              end
            58:
              begin
                w58_we = 1;
              end
            59:
              begin
                w59_we = 1;
              end

            60:
              begin
                w60_we = 1;
              end
            61:
              begin
                w61_we = 1;
              end
            62:
              begin
                w62_we = 1;
              end
            63:
              begin
                w63_we = 1;
              end
          endcase // case (w_ctr_reg)
        end // if (w_update)
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
