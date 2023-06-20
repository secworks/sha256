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

`default_nettype none

module tb_sha256_w_mem();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG          = 1;
  parameter DISPLAY_CYCLES = 0;

  parameter CLK_HALF_PERIOD = 2;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg            tb_clk;
  reg            tb_reset_n;

  reg           tb_init;
  reg           tb_next;
  reg [511 : 0] tb_block;
  reg [5 : 0]   tb_round;
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

                   .block(tb_block),
                   .round(tb_round),

                   .init(tb_init),
                   .next(tb_next),

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
          $display("dut round      = %02x:", dut.round);
          $display("dut w_tmp      = %02x:", dut.w_tmp);
          dump_w_state();
        end
    end // dut_monitor


  //----------------------------------------------------------------
  // dump_w_state()
  //
  // Dump the current state of all W registers.
  //----------------------------------------------------------------
  task dump_w_state;
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

      $display("w_new = %08x", dut.w_new);
      $display("");
    end
  endtask // dump_state


  //----------------------------------------------------------------
  // reset_dut
  //----------------------------------------------------------------
  task reset_dut;
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
  task init_sim;
    begin
      $display("*** Simulation init.");
      tb_clk = 0;
      tb_reset_n = 1;
      cycle_ctr = 0;

      tb_init = 0;
      tb_block = 512'h0;
      tb_round = 6'h0;
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // test_w_schedule()
  //
  // Test that W scheduling happens and work correctly.
  // Note: Currently not a self checking test case.
  //----------------------------------------------------------------
  task test_w_schedule;
    begin : test_w_schedule
      integer i;
      $display("*** Test of W schedule processing. --");
      tb_block = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
      tb_init = 1;
      #(4 * CLK_HALF_PERIOD);
      tb_init = 0;
      dump_w_state();

      tb_round = 0;
      for (i = 0 ; i < 64 ; i = i + 1) begin
	#(2 * CLK_HALF_PERIOD);
	tb_round = tb_round + 1;
      end

      dump_w_state();
    end
  endtask // test_w_schedule


  //----------------------------------------------------------------
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : w_mem_test
      $display("   -- Testbench for sha256 w memory started --");
      init_sim();
      reset_dut();
      test_w_schedule();

      $display("*** Simulation done.");
      $finish;
    end

endmodule // w_mem_test

//======================================================================
// EOF tb_sha256_w_mem.v
//======================================================================
