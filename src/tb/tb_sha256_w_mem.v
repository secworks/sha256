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
               dut.w0_reg, dut.w1_reg, dut.w2_reg, dut.w3_reg);

      $display("w4_reg  = %08x, w5_reg  = %08x, w6_reg  = %08x, w7_reg  = %08x", 
               dut.w4_reg, dut.w5_reg, dut.w6_reg, dut.w7_reg);

      $display("w8_reg  = %08x, w9_reg  = %08x, w10_reg = %08x, w11_reg = %08x", 
               dut.w8_reg, dut.w9_reg, dut.w10_reg, dut.w11_reg);

      $display("w12_reg = %08x, w13_reg = %08x, w14_reg = %08x, w15_reg = %08x", 
               dut.w12_reg, dut.w13_reg, dut.w14_reg, dut.w15_reg);

      $display("w16_reg = %08x, w17_reg = %08x, w18_reg = %08x, w19_reg = %08x", 
               dut.w16_reg, dut.w17_reg, dut.w18_reg, dut.w19_reg);

      $display("w20_reg = %08x, w21_reg = %08x, w22_reg = %08x, w23_reg = %08x", 
               dut.w20_reg, dut.w21_reg, dut.w22_reg, dut.w23_reg);

      $display("w24_reg = %08x, w25_reg = %08x, w26_reg = %08x, w27_reg = %08x", 
               dut.w24_reg, dut.w25_reg, dut.w26_reg, dut.w27_reg);

      $display("w28_reg = %08x, w29_reg = %08x, w30_reg = %08x, w31_reg = %08x", 
               dut.w28_reg, dut.w29_reg, dut.w30_reg, dut.w31_reg);

      $display("w32_reg = %08x, w33_reg = %08x, w34_reg = %08x, w35_reg = %08x", 
               dut.w32_reg, dut.w33_reg, dut.w34_reg, dut.w35_reg);

      $display("w36_reg = %08x, w37_reg = %08x, w38_reg = %08x, w39_reg = %08x", 
               dut.w36_reg, dut.w37_reg, dut.w38_reg, dut.w39_reg);

      $display("w40_reg = %08x, w41_reg = %08x, w42_reg = %08x, w43_reg = %08x", 
               dut.w40_reg, dut.w41_reg, dut.w42_reg, dut.w43_reg);

      $display("w44_reg = %08x, w45_reg = %08x, w46_reg = %08x, w47_reg = %08x", 
               dut.w44_reg, dut.w45_reg, dut.w46_reg, dut.w47_reg);

      $display("w48_reg = %08x, w49_reg = %08x, w50_reg = %08x, w51_reg = %08x", 
               dut.w48_reg, dut.w49_reg, dut.w50_reg, dut.w51_reg);

      $display("w52_reg = %08x, w53_reg = %08x, w54_reg = %08x, w55_reg = %08x", 
                dut.w52_reg, dut.w53_reg, dut.w54_reg, dut.w55_reg);

      $display("w56_reg = %08x, w57_reg = %08x, w58_reg = %08x, w59_reg = %08x", 
               dut.w56_reg, dut.w57_reg, dut.w58_reg, dut.w59_reg);

      $display("w60_reg = %08x, w61_reg = %08x, w62_reg = %08x, w63_reg = %08x", 
               dut.w60_reg, dut.w61_reg, dut.w62_reg, dut.w63_reg);
      
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
  // test_w_schedule()
  //
  // Test that W scheduling happens and work correctly.
  // Note: Currently not a self checking test case.
  //----------------------------------------------------------------
  task test_w_schedule();
    begin
      $display("*** Test of W schedule processing. --");
      tb_block = 512'ha5a5a5a5a5a5a5a5a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
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
          $display("   W%02x = 0x%02x", tb_addr, tb_w);
          #(2 * CLK_HALF_PERIOD);
          i = i + 1;
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
      dump_w_state();
      reset_dut();
      dump_w_state();

      test_w_schedule();
      test_read_w();

      $display("*** Simulation done.");
      $finish;
    end
  
endmodule // w_mem_test
  
//======================================================================
// EOF tb_sha256_w_mem.v
//======================================================================
