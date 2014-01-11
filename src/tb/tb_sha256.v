//======================================================================
//
// tb_sha256.v
// ----------------
// Testbench for the SHA-256 top level wrapper.
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

module tb_sha256();
  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG = 1;

  parameter CLK_HALF_PERIOD = 2;
  
  
  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0] cycle_ctr;
  reg [31 : 0] error_ctr;
  reg [31 : 0] tc_ctr;

  reg           tb_clk;
  reg           tb_reset_n;
  reg           tb_cs;
  reg           tb_write_read;
  reg [7 : 0]   tb_address;
  reg [31 : 0]  tb_data_in;
  wire [31 : 0] tb_data_out;
  
  
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  sha256 dut(
             .clk(tb_clk),
             .reset_n(tb_reset_n),
             
             .cs(tb_cs),
             .write_read(tb_write_read),
             
             
             .address(tb_address),
             .data_in(tb_data_in),
             .data_out(tb_data_out)
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
  // sys_monitor
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      #(2 * CLK_HALF_PERIOD);
      if (DEBUG)
        begin
          dump_dut_state();
        end
    end

  
  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state();
    begin
    end
  endtask // dump_dut_state
  
  
  //----------------------------------------------------------------
  // reset_dut()
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
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim();
    begin
      cycle_ctr = 32'h00000000;
      error_ctr = 32'h00000000;
      tc_ctr = 32'h00000000;
      
      tb_clk = 0;
      tb_reset_n = 0;
      tb_cs = 0;
      tb_write_read = 0;
      tb_address = 6'h00;
      tb_data_in = 32'h00000000;
    end
  endtask // init_dut

  
  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result();
    begin
      if (error_ctr == 0)
        begin
          $display("*** All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("*** %02d test cases did not complete successfully.", error_ctr);
        end
    end
  endtask // display_test_result
  

  //----------------------------------------------------------------
  // wait_ready()
  //
  // Wait for the ready flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing and will in fact at some
  // point set the flag.
  //----------------------------------------------------------------
  task wait_ready();
    begin
      while (!tb_ready)
        begin
          #(2 * CLK_HALF_PERIOD);
        end
    end
  endtask // wait_ready
                         
    
  //----------------------------------------------------------------
  // sha256_test
  // The main test functionality. 
  //
  // Test cases taken from:
  // http://csrc.nist.gov/groups/ST/toolkit/documents/Examples/SHA256.pdf
  //----------------------------------------------------------------
  initial
    begin : sha256_test
      $display("   -- Testbench for sha256 started --");

      init_sim();
      display_test_result();
      $display("*** Simulation done. ***");
      $finish;
    end // sha256_test
endmodule // tb_sha256

//======================================================================
// EOF tb_sha256.v
//======================================================================

