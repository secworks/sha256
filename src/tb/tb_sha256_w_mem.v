//======================================================================
//
// tb_sha256_w_mem.v
// -----------------
// Testbench for the SHA-256 W memory module.
//
//
// Copyright (c) 2013, Secworks Sweden AB
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

//------------------------------------------------------------------
// Simulator directives.
//------------------------------------------------------------------
`timescale 1ns/10ps

module tb_sha256_w_mem();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG          = 0;
  parameter DISPLAY_CYCLES = 0;

  parameter CLK_HALF_PERIOD = 2;

  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------

  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg            tb_clk;
  reg            tb_reset_n;

  reg           tb_init;
  reg [511 : 0] tb_block;
  reg [5 : 0]   tb_addr;
  wire          tb_ready;
  wire [31 : 0] tb_w;

  reg [63 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;
  
  
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  sha256_w_mem dut(
                   .clk(tb_clk),
                   .reset_n(tb_reset_n),
                   
                   .init(tb_init),
                   
                   .block(tb_block),
                   .addr(tb_addr),
                   
                   .ready(tb_ready),
                   .w(tb_w)
                  );
  

  //----------------------------------------------------------------
  // clk_gen
  //
  // Clock generator process. 
  //----------------------------------------------------------------
  always 
    begin : clk_gen
      #CLK_HALF_PERIOD tb_clk = !tb_clk;
    end // clk_gen

  
  //--------------------------------------------------------------------
  // dut_monitor
  //
  // Monitor displaying information every cycle.
  // Includes the cycle counter.
  //--------------------------------------------------------------------
  always @ (posedge tb_clk)
    begin : dut_monitor
      cycle_ctr = cycle_ctr + 1;

      if (DISPLAY_CYCLES)
        begin
          $display("cycle = %016x:", cycle_ctr);
        end
      
      if (DEBUG)
        begin
          $display("dut ctrl_state = %02x:", dut.sha256_w_mem_ctrl_reg);
          $display("dut w_ctr      = %02x:", dut.w_ctr_reg);
        end
    end // dut_monitor
      
  
  //----------------------------------------------------------------
  // dump_w_state()
  //
  // Dump the current state of all W registers.
  //----------------------------------------------------------------
  task dump_w_state();
    begin
      $display("W state:");
      
      $display("w0_reg  = %08x, w1_reg  = %08x, w2_reg  = %08x, w3_reg  = %08x", 
               dut.w_mem[00], dut.w_mem[01], dut.w_mem[02], dut.w_mem[03]);

      $display("w4_reg  = %08x, w5_reg  = %08x, w6_reg  = %08x, w7_reg  = %08x", 
               dut.w_mem[04], dut.w_mem[05], dut.w_mem[06], dut.w_mem[07]);

      $display("w8_reg  = %08x, w9_reg  = %08x, w10_reg = %08x, w11_reg = %08x", 
               dut.w_mem[08], dut.w_mem[09], dut.w_mem[10], dut.w_mem[11]);

      $display("w12_reg = %08x, w13_reg = %08x, w14_reg = %08x, w15_reg = %08x", 
               dut.w_mem[12], dut.w_mem[13], dut.w_mem[14], dut.w_mem[15]);

      $display("w16_reg = %08x, w17_reg = %08x, w18_reg = %08x, w19_reg = %08x", 
               dut.w_mem[16], dut.w_mem[17], dut.w_mem[18], dut.w_mem[19]);

      $display("w20_reg = %08x, w21_reg = %08x, w22_reg = %08x, w23_reg = %08x", 
               dut.w_mem[20], dut.w_mem[21], dut.w_mem[22], dut.w_mem[23]);

      $display("w24_reg = %08x, w25_reg = %08x, w26_reg = %08x, w27_reg = %08x", 
               dut.w_mem[24], dut.w_mem[25], dut.w_mem[26], dut.w_mem[27]);

      $display("w28_reg = %08x, w29_reg = %08x, w30_reg = %08x, w31_reg = %08x", 
               dut.w_mem[28], dut.w_mem[29], dut.w_mem[30], dut.w_mem[31]);

      $display("w32_reg = %08x, w33_reg = %08x, w34_reg = %08x, w35_reg = %08x", 
               dut.w_mem[32], dut.w_mem[33], dut.w_mem[34], dut.w_mem[35]);

      $display("w36_reg = %08x, w37_reg = %08x, w38_reg = %08x, w39_reg = %08x", 
               dut.w_mem[36], dut.w_mem[37], dut.w_mem[38], dut.w_mem[39]);

      $display("w40_reg = %08x, w41_reg = %08x, w42_reg = %08x, w43_reg = %08x", 
               dut.w_mem[40], dut.w_mem[41], dut.w_mem[42], dut.w_mem[43]);

      $display("w44_reg = %08x, w45_reg = %08x, w46_reg = %08x, w47_reg = %08x", 
               dut.w_mem[44], dut.w_mem[45], dut.w_mem[46], dut.w_mem[47]);

      $display("w48_reg = %08x, w49_reg = %08x, w50_reg = %08x, w51_reg = %08x", 
               dut.w_mem[48], dut.w_mem[49], dut.w_mem[50], dut.w_mem[51]);

      $display("w52_reg = %08x, w53_reg = %08x, w54_reg = %08x, w55_reg = %08x", 
                dut.w_mem[52], dut.w_mem[53], dut.w_mem[54], dut.w_mem[55]);

      $display("w56_reg = %08x, w57_reg = %08x, w58_reg = %08x, w59_reg = %08x", 
               dut.w_mem[56], dut.w_mem[57], dut.w_mem[58], dut.w_mem[59]);

      $display("w60_reg = %08x, w61_reg = %08x, w62_reg = %08x, w63_reg = %08x", 
               dut.w_mem[60], dut.w_mem[61], dut.w_mem[62], dut.w_mem[63]);
      
      $display("");
    end
  endtask // dump_state
  
  
  //----------------------------------------------------------------
  // reset_dut
  //----------------------------------------------------------------
  task reset_dut();
    begin
      $display("*** Toggle reset.");
      tb_reset_n = 0;
      #(4 * CLK_HALF_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut
  
  
  //----------------------------------------------------------------
  // init_sim
  //----------------------------------------------------------------
  task init_sim();
    begin
      $display("*** Simulation init.");
      tb_clk = 0;
      tb_reset_n = 1;
      cycle_ctr = 0;
      
      tb_init = 0;
      tb_block = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      tb_addr = 0;
    end
  endtask // reset_dut

  
  //----------------------------------------------------------------
  // dump_mem()
  //
  // Dump the contents of the memory by directly reading from
  // the registers in the dut, not via the read port.
  //----------------------------------------------------------------
  task dump_mem();
    begin
      $display("*** Dumping memory:");
      $display("W[00] = 0x%08x", dut.w_mem[00]);
      $display("W[01] = 0x%08x", dut.w_mem[01]);
      $display("W[02] = 0x%08x", dut.w_mem[02]);
      $display("W[03] = 0x%08x", dut.w_mem[03]);
      $display("W[04] = 0x%08x", dut.w_mem[04]);
      $display("W[05] = 0x%08x", dut.w_mem[05]);
      $display("W[06] = 0x%08x", dut.w_mem[06]);
      $display("W[07] = 0x%08x", dut.w_mem[07]);
      $display("W[08] = 0x%08x", dut.w_mem[08]);
      $display("W[09] = 0x%08x", dut.w_mem[09]);
      $display("W[10] = 0x%08x", dut.w_mem[10]);
      $display("W[11] = 0x%08x", dut.w_mem[11]);
      $display("W[12] = 0x%08x", dut.w_mem[12]);
      $display("W[13] = 0x%08x", dut.w_mem[13]);
      $display("W[14] = 0x%08x", dut.w_mem[14]);
      $display("W[15] = 0x%08x", dut.w_mem[15]);
      $display("W[16] = 0x%08x", dut.w_mem[16]);
      $display("W[17] = 0x%08x", dut.w_mem[17]);
      $display("W[18] = 0x%08x", dut.w_mem[18]);
      $display("W[19] = 0x%08x", dut.w_mem[19]);
      $display("W[20] = 0x%08x", dut.w_mem[20]);
      $display("W[21] = 0x%08x", dut.w_mem[21]);
      $display("W[22] = 0x%08x", dut.w_mem[22]);
      $display("W[23] = 0x%08x", dut.w_mem[23]);
      $display("W[24] = 0x%08x", dut.w_mem[24]);
      $display("W[25] = 0x%08x", dut.w_mem[25]);
      $display("W[26] = 0x%08x", dut.w_mem[26]);
      $display("W[27] = 0x%08x", dut.w_mem[27]);
      $display("W[28] = 0x%08x", dut.w_mem[28]);
      $display("W[29] = 0x%08x", dut.w_mem[29]);
      $display("W[30] = 0x%08x", dut.w_mem[30]);
      $display("W[31] = 0x%08x", dut.w_mem[31]);
      $display("W[32] = 0x%08x", dut.w_mem[32]);
      $display("W[33] = 0x%08x", dut.w_mem[33]);
      $display("W[34] = 0x%08x", dut.w_mem[34]);
      $display("W[35] = 0x%08x", dut.w_mem[35]);
      $display("W[36] = 0x%08x", dut.w_mem[36]);
      $display("W[37] = 0x%08x", dut.w_mem[37]);
      $display("W[38] = 0x%08x", dut.w_mem[38]);
      $display("W[39] = 0x%08x", dut.w_mem[39]);
      $display("W[40] = 0x%08x", dut.w_mem[40]);
      $display("W[41] = 0x%08x", dut.w_mem[41]);
      $display("W[42] = 0x%08x", dut.w_mem[42]);
      $display("W[43] = 0x%08x", dut.w_mem[43]);
      $display("W[44] = 0x%08x", dut.w_mem[44]);
      $display("W[45] = 0x%08x", dut.w_mem[45]);
      $display("W[46] = 0x%08x", dut.w_mem[46]);
      $display("W[47] = 0x%08x", dut.w_mem[47]);
      $display("W[48] = 0x%08x", dut.w_mem[48]);
      $display("W[49] = 0x%08x", dut.w_mem[49]);
      $display("W[50] = 0x%08x", dut.w_mem[50]);
      $display("W[51] = 0x%08x", dut.w_mem[51]);
      $display("W[52] = 0x%08x", dut.w_mem[52]);
      $display("W[53] = 0x%08x", dut.w_mem[53]);
      $display("W[54] = 0x%08x", dut.w_mem[54]);
      $display("W[55] = 0x%08x", dut.w_mem[55]);
      $display("W[56] = 0x%08x", dut.w_mem[56]);
      $display("W[57] = 0x%08x", dut.w_mem[57]);
      $display("W[58] = 0x%08x", dut.w_mem[58]);
      $display("W[59] = 0x%08x", dut.w_mem[59]);
      $display("W[60] = 0x%08x", dut.w_mem[00]);
      $display("W[61] = 0x%08x", dut.w_mem[61]);
      $display("W[62] = 0x%08x", dut.w_mem[62]);
      $display("W[63] = 0x%08x", dut.w_mem[63]);
      $display("");
    end
  endtask // dump_mem
  
  
  //----------------------------------------------------------------
  // test_w_schedule()
  //
  // Test that W scheduling happens and work correctly.
  // Note: Currently not a self checking test case.
  //----------------------------------------------------------------
  task test_w_schedule();
    begin
      $display("*** Test of W schedule processing. --");
      tb_block = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
      tb_init = 1;
      #(4 * CLK_HALF_PERIOD);
      tb_init = 0;
      dump_w_state();

      #(25 * CLK_HALF_PERIOD);
      dump_w_state();
      
      #(25 * CLK_HALF_PERIOD);
      dump_w_state();
      
      #(25 * CLK_HALF_PERIOD);
      dump_w_state();
      
      #(25 * CLK_HALF_PERIOD);
      dump_w_state();
    end
  endtask // test_w_schedule
  

  //----------------------------------------------------------------
  // test_read_w/(
  //
  // Test that we can read data from all W registers.
  // Note: Currently not a self checking test case.
  //----------------------------------------------------------------
  task test_read_w();
    reg [6 : 0] i;
    begin
      $display("*** Test of W read operations. --");
      i = 0;
      while (i < 64)
        begin
          tb_addr = i[5 : 0];
          $display("API: w%02x, internal w%02x = 0x%02x", tb_addr, dut.addr, dut.w_tmp);
          i = i + 1;
          #(2 * CLK_HALF_PERIOD);
        end
    end
  endtask // read_w
  
    
  //----------------------------------------------------------------
  // The main test functionality. 
  //----------------------------------------------------------------
  initial
    begin : w_mem_test
      $display("   -- Testbench for sha256 w memory started --");
      init_sim();

      dump_mem();
      reset_dut();
      dump_mem();
      
      test_w_schedule();
      dump_mem();

      test_read_w();

      $display("*** Simulation done.");
      $finish;
    end
  
endmodule // w_mem_test
  
//======================================================================
// EOF tb_sha256_w_mem.v
//======================================================================
