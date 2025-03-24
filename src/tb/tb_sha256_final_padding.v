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

  wire           tb_init_out;
  wire           tb_next_out;
  wire           tb_ready_out;
  wire [511 : 0] tb_block_out;


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
			   .ready_out(tb_ready_out),
			   .block_out(tb_block_out)
			  );

  sha256_core core(
		   .clk(tb_clk),
		   .reset_n(tb_reset_n),
		   .init(tb_init_out),
		   .next(tb_next_out),
		   .mode(tb_core_mode),
		   .block(tb_block_out),
		   .ready(tb_core_ready),
		   .digest(tb_core_digest),
		   .digest_valid(tb_core_valid)
		   );


  //----------------------------------------------------------------
  // sha256_core_model
  //
  // A very simple model that simulates the input-output begaviour
  // to some degree. Basically wait for an init or next. Drop
  // core_ready and wait a few cycles. And then set
  // core_ready again.
  //----------------------------------------------------------------
  always @*
    begin : sha256_core_model
      tb_core_ready = 1'h1;

//      if ((init_out) or (next_out)) begin
	//	#(2 * CLK_PERIOD);
	//	tb_core_ready = 1'h0;
	//
	//	#(10 * CLK_PERIOD);
//      end
    end // sha256_core_model


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
      $display("Resetting DUT");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
      #(2 * CLK_PERIOD);
      $display("");
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
      $display("");
      $display("DUT state at cycle: %08d", cycle_ctr);

      $display("Inputs:");
      $display("init_in: %1d, next_in: %1d, final_in: %1d, core_ready: %1d",
	       dut.init_in, dut.next_in, dut.final_in, dut.core_ready);
      $display("final_len: 0x%03x", dut.final_len);
      $display("block_in: 0x%064x", dut.block_in);
      $display("");

      $display("Outputs:");
      $display("init_out: %1d, next_out: %1d, ready_out: %1d",
	       dut.init_out, dut.next_out, dut.ready_out);
      $display("block_out: 0x%064x", dut.block_out);
      $display("");

      $display("Internal state:");
      $display("padding_ctrl_reg: 0x%02x, padding_ctrl_new: 0x%02x, padding_ctrl_we: %1d",
               dut.sha256_final_padding_ctrl_reg, dut.sha256_final_padding_ctrl_new,
	       dut.sha256_final_padding_ctrl_we);

      $display("bit_ctr_reg: 0x%016x, bit_ctr_new: 0x%016x, bit_ctr_rst: %1d, bit_ctr_inc: 0x%01x, bit_ctr_we: %1d",
               dut.bit_ctr_reg, dut.bit_ctr_new, dut.bit_ctr_rst, dut.bit_ctr_inc, dut.bit_ctr_we);
      $display("");
      $display("");
    end
  endtask // dump_state


  //----------------------------------------------------------------
  // init_sim()
  //
  // Set the input to the DUT to defined values.
  //----------------------------------------------------------------
  task init_sim;
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
      tb_core_ready    = 1'h1;
    end
  endtask // init


  //----------------------------------------------------------------
  // tc0
  // Test that padding for a zero length message is correct.
  //----------------------------------------------------------------
  task tc0;
    begin : tc1
      tb_display_state = 1;
      tc_ctr = tc_ctr + 1;
      $display("TC0 started: Padding of a zero length message.");

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 0] = {512'h0};
      tb_final_len         = 9'h000;
      tb_final_in          = 1'h1;
      #(CLK_PERIOD);
      tb_final_in          = 1'h0;

      #(CLK_PERIOD);
      if (tb_block_out == {8'h80, 495'h0,9'h020}) begin
	$display("Correct block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect block: 0x%064x", tb_block_out);
	$display("Expected block:  0x%064x", {24'h616263, 8'h80, 416'h0,64'h00000018});
	error_ctr = error_ctr + 1;
      end

      $display("TC%2d completed", tc_ctr);
      $display();
      tb_display_state = 1;
    end
  endtask // tc1


  //----------------------------------------------------------------
  // tc1
  // Test that the FIPS 180-4 padding example in chapter
  // 5.1.1 works as intended.
  //----------------------------------------------------------------
  task tc1;
    begin : tc1
      tb_display_state = 1;
      tc_ctr = tc_ctr + 1;
      $display("TC%2d started: NIST FIPS 180-4 padding example.", tc_ctr);

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 0] = {8'h61, 504'h0};
      tb_final_len         = 9'h008;
      tb_final_in          = 1'h1;
      #(CLK_PERIOD);
      tb_final_in          = 1'h0;

      #(CLK_PERIOD);
      if (tb_block_out == {8'h61, 8'h80, 416'h0,9'h020}) begin
	$display("Correct block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect block: 0x%064x", tb_block_out);
	$display("Expected block:  0x%064x", {24'h616263, 8'h80, 416'h0,64'h00000018});
	error_ctr = error_ctr + 1;
      end

      $display("TC%2d completed", tc_ctr);
      $display();
      tb_display_state = 1;
    end
  endtask // tc1


  //----------------------------------------------------------------
  // tc2
  // Test that extends the FIPS 180-4 padding example in chapter
  // 5.1.1 with a few more chars. This still fits within the final
  // block.
  //----------------------------------------------------------------
  task tc2;
    begin : tc2
      tb_display_state = 1;
      tc_ctr = tc_ctr + 1;
      $display("TC%2d started: Extended NIST FIPS 180-4 padding example.", tc_ctr);

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 0] = {72'h616263616263616263, 440'h0};
      tb_final_len         = 9'h048;
      tb_final_in          = 1'h1;
      #(CLK_PERIOD);
      tb_final_in          = 1'h0;

      #(10 * CLK_PERIOD);
      if (tb_block_out == {72'h616263616263616263, 8'h80, 368'h0, 64'h00000048}) begin
	$display("Correct block: 0x%064x", tb_block_out);
      end
      else begin
	$display("Incorrect block: 0x%064x", tb_block_out);
	$display("Expected block:  0x%064x", {72'h616263616263616263, 8'h80, 368'h0, 64'h00000048});
	error_ctr = error_ctr + 1;
      end

      $display("TC%2d completed", tc_ctr);
      $display();
      tb_display_state = 0;
    end
  endtask // tc2


  //----------------------------------------------------------------
  // tc3
  // Test that triggers a the second type of padding where the
  // padding does not fit and we get a single one block
  // and a second block with the length at the end.
  //----------------------------------------------------------------
  task tc3;
    begin : tc3
      reg tc2_error;
      tc2_error = 0;
      tc_ctr = tc_ctr + 1;
      $display("TC%2d started: Padding that does not fit in the final block.", tc_ctr);

      tb_init_in = 1'h1;
      #(CLK_PERIOD);
      tb_init_in = 1'h0;

      #(CLK_PERIOD);
      tb_block_in[511 : 0] = {{15{32'h13371337}}, 32'h0};
      tb_final_len           = 9'h1e0;
      tb_final_in            = 1'h1;

      if (tb_next_out == 1'h1) begin
	if (tb_block_out == {{15{32'h13371337}}, 1'h1, 31'h0}) begin
	  $display("Correct first block: 0x%064x", tb_block_out);
	end
	else begin
	  $display("Incorrect first block:  0x%064x", tb_block_out);
	  $display("Expected first block:   0x%064x", {{15{32'h13371337}}, 1'h1, 31'h0});
	  tc2_error = 1;
	end
      end

      tb_final_in = 1'h0;

      #(10 * CLK_PERIOD);
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
  endtask // tc3


  //----------------------------------------------------------------
  // sha256_final_padding_test
  //----------------------------------------------------------------
  initial
    begin : sha256_final_padding_test
      $display("- Testbench for sha256_final_padding started -");
      $display("----------------------------------------------");
      $display("");

      init_sim();
      reset_dut();
      tc0();
//      tc1();
//      tc2();
//      tc3();

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
