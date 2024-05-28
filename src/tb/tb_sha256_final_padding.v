//======================================================================
//
// tb_sha256_final_padding.v
// -------------------------
// Testbench for the sha256 final padding.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2024, Assured AB
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

module tb_sha256_final_padding();

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DISPLAY_STATE   = 0;

  parameter CLK_HALF_PERIOD = 2;
  parameter CLK_PERIOD      = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [63 : 0]   cycle_ctr;
  reg [31 : 0]   error_ctr;
  reg [31 : 0]   tc_ctr;

  reg            tb_display_state;

  reg            tb_clk;
  reg            tb_reset_n;
  reg            tb_init_in;
  reg            tb_next_in;
  reg            tb_final_in;
  reg [8 : 0]    tb_final_len;
  reg [511 : 0]  tb_block_in;
  reg            tb_core_ready;

  wire [511 : 0] tb_block_out;
  wire           tb_init_out;
  wire           tb_next_out;


  //----------------------------------------------------------------
  // sha256_final_padding devices under test.
  //----------------------------------------------------------------
  sha256_final_padding dut(
			   .clk(tb_clk),
			   .reset_n(tb_reset_n),

			   .init_in(tb_init_in),
			   .next_in(tb_next_in),
			   .final_in(tb_final_in),
			   .final_len(tb_final_len),
			   .block_in(tb_block_in),

			   .core_ready(tb_core_ready),

			   .init_out(tb_init_out),
			   .next_out(tb_next_out),
			   .block_out(tb_block_out)
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


  //----------------------------------------------------------------
  // reset_dut
  //----------------------------------------------------------------
  task reset_dut;
    begin
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // inc_tc_ctr()
  //----------------------------------------------------------------
  task inc_tc_ctr;
    begin
      tc_ctr = tc_ctr + 1;
    end
  endtask // inc_tc_ctr


  //----------------------------------------------------------------
  // inc_error_ctr()
  //----------------------------------------------------------------
  task inc_error_ctr;
    begin
      error_ctr = error_ctr + 1;
    end
  endtask // inc_error_ctr


  //----------------------------------------------------------------
  // enable_display_state()
  //----------------------------------------------------------------
  task enable_display_state;
    begin
      tb_display_state = 1;
    end
  endtask // enable_display_state


  //----------------------------------------------------------------
  // disable_display_state()
  //----------------------------------------------------------------
  task disable_display_state;
    begin
      tb_display_state = 0;
    end
  endtask // disable_display_state


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      cycle_ctr = cycle_ctr + 1;
      #(CLK_PERIOD);
      if (tb_display_state)
        begin
          dump_dut_state();
        end
    end


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("-- All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("-- %2d test cases cases completed. %2d test cases did not complete successfully.", tc_ctr, error_ctr);
        end
    end
  endtask // display_test_result


  //----------------------------------------------------------------
  // dump_dut_state()
  //----------------------------------------------------------------
  task dump_dut_state;
    begin
//       $display("Counters and control state::");
//       $display("blake2_ctrl_reg = 0x%02x  round_ctr_reg = 0x%02x  ready = 0x%01x  valid = 0x%01x",
//                dut.blake2_ctrl_reg, dut.round_ctr_reg, tb_ready, tb_digest_valid);
//       $display("");
//
//       $display("Chaining value:");
//       $display("h[0] = 0x%016x  h[1] = 0x%016x  h[2] = 0x%016x  h[3] = 0x%016x",
//                dut.h_reg[0], dut.h_reg[1], dut.h_reg[2], dut.h_reg[3]);
//       $display("h[4] = 0x%016x  h[5] = 0x%016x  h[6] = 0x%016x  h[7] = 0x%016x",
//                dut.h_reg[4], dut.h_reg[5], dut.h_reg[6], dut.h_reg[7]);
//       $display("");
//
//       $display("Internal state:");
//       $display("v[00] = 0x%016x  v[01] = 0x%016x  v[02] = 0x%016x  v[03] = 0x%016x",
//                dut.v_reg[0], dut.v_reg[1], dut.v_reg[2], dut.v_reg[3]);
//       $display("v[04] = 0x%016x  v[05] = 0x%016x  v[06] = 0x%016x  v[07] = 0x%016x",
//                dut.v_reg[4], dut.v_reg[5], dut.v_reg[6], dut.v_reg[7]);
//       $display("v[08] = 0x%016x  v[09] = 0x%016x  v[10] = 0x%016x  v[11] = 0x%016x",
//                dut.v_reg[8], dut.v_reg[9], dut.v_reg[10], dut.v_reg[11]);
//       $display("v[12] = 0x%016x  v[13] = 0x%016x  v[14] = 0x%016x  v[15] = 0x%016x",
//                dut.v_reg[12], dut.v_reg[13], dut.v_reg[14], dut.v_reg[15]);
//       $display("");
//
//       $display("Message block:");
//       $display("m[00] = 0x%016x  m[01] = 0x%016x  m[02] = 0x%016x  m[03] = 0x%016x",
//                dut.mselect.m_reg[0], dut.mselect.m_reg[1],
//                dut.mselect.m_reg[2], dut.mselect.m_reg[3]);
//       $display("m[04] = 0x%016x  m[05] = 0x%016x  m[06] = 0x%016x  m[07] = 0x%016x",
//                dut.mselect.m_reg[4], dut.mselect.m_reg[5],
//                dut.mselect.m_reg[6], dut.mselect.m_reg[7]);
//       $display("m[08] = 0x%016x  m[09] = 0x%016x  m[10] = 0x%016x  m[11] = 0x%016x",
//                dut.mselect.m_reg[8], dut.mselect.m_reg[9],
//                dut.mselect.m_reg[10], dut.mselect.m_reg[11]);
//       $display("m[12] = 0x%016x  m[13] = 0x%016x  m[14] = 0x%016x  m[15] = 0x%016x",
//                dut.mselect.m_reg[12], dut.mselect.m_reg[13],
//                dut.mselect.m_reg[14], dut.mselect.m_reg[15]);
//       $display("");
    end
  endtask // dump_state


  //----------------------------------------------------------------
  // init()
  //
  // Set the input to the DUT to defined values.
  //----------------------------------------------------------------
  task init;
    begin
      cycle_ctr        = 0;
      error_ctr        = 0;
      tc_ctr           = 0;
      tb_display_state = 0;

      tb_clk           = 1'h0;
      tb_reset_n       = 1'h1;
      tb_init_in       = 1'h0;
      tb_next_in       = 1'h0;
      tb_final_in      = 1'h0;
      tb_final_len     = 9'h0;
      tb_block_in      = 512'h0;
      tb_core_ready    = 1'h0;
    end
  endtask // init


  //----------------------------------------------------------------
  // tc1
  // Test that the FIPS 180-4 padding example in chapter
  // 5.1.1 works as intended.
  //----------------------------------------------------------------
  task tc1;
    begin : tc1
      tc_ctr = tc_ctr + 1;
      $display("TC%2d started: NIST FIPS 180-4 padding example.", tc_ctr);

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 488] = 24'h616263;
      tb_final_len           = 9'h018;
      tb_final_in            = 1'h1;
      #(CLK_PERIOD);
      tb_final_in            = 1'h0;

      if (tb_block_out == {24'h616263, 8'h80, 416'h0,64'h00000018}) begin
	$display("Correct block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect block: 0x%064x", tb_block_out);
	$display("Expected block:  0x%064x", {24'h616263, 8'h80, 416'h0,64'h00000018});
	error_ctr = error_ctr + 1;
      end

      $display("TC%2d completed", tc_ctr);
      $display();
    end
  endtask // tc1


  //----------------------------------------------------------------
  // tc2
  // Test that triggers a the second type od padding where the
  // padding does not fit and we get a single one block
  // and a second block with the length at the end.
  //----------------------------------------------------------------
  task tc2;
    begin : tc2
      reg tc2_error;
      tc2_error = 0;
      tc_ctr = tc_ctr + 1;
      $display("TC%2d started: Padding that does not fit in the block.", tc_ctr);

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 0] = {{15{32'hdeadbeef}}, 32'h0};
      tb_final_len           = 9'h1e0;
      tb_final_in            = 1'h1;
      #(CLK_PERIOD);
      tb_final_in            = 1'h0;

      if (tb_block_out == {{15{32'hdeadbeef}}, 1'h1, 31'h0}) begin
	$display("Correct first block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect first block:  0x%064x", tb_block_out);
	$display("Expected first block:   0x%064x", {{15{32'hdeadbeef}}, 1'h1, 31'h0});
	tc2_error = 1;
      end
      $display();

      #(2 * CLK_PERIOD);
      tb_core_ready = 1'h1;
      #(CLK_PERIOD);
      tb_core_ready = 1'h0;

      if (tb_block_out == {{15{32'hdeadbeef}}, 1'h1, 31'h0}) begin
	$display("Correct second block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect second block: 0x%064x", tb_block_out);
	$display("Expected second block:  0x%064x", {{15{32'hdeadbeef}}, 1'h1, 31'h0});
	tc2_error = 1;
      end

      if (tc2_error) begin
	error_ctr = error_ctr + 1;
      end

      $display("TC%2d completed", tc_ctr);
      $display();
    end
  endtask // tc2


  //----------------------------------------------------------------
  // sha256_final_padding_test
  //----------------------------------------------------------------
  initial
    begin : sha256_final_padding_test
      $display("- Testbench for sha256_final_padding started -");
      $display("----------------------------------------------");
      $display("");

      init();
      reset_dut();
      tc1();
      tc2();

      display_test_result();

      $display("");
      $display("- Testbench for sha256_final_padding completed -");
      $display("------------------------------------------------");

      $finish_and_return(error_ctr);
    end // sha256_final_padding_test
endmodule // tb_sha256_final_padding

//======================================================================
// EOF tb_sha256_final_padding.v
//======================================================================
