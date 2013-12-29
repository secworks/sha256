//======================================================================
//
// tb_sha256_core.v
// ----------------
// Testbench for the SHA-256 core.
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

module tb_sha256_core();
  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG = 0;

  parameter CLK_HALF_PERIOD = 2;
  
  
  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg            tb_clk;
  reg            tb_reset_n;
  reg            tb_init;
  reg            tb_next;
  reg [511 : 0]  tb_block;
  wire           tb_ready;
  wire [255 : 0] tb_digest;
  wire           tb_digest_valid;
  
  
  
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  sha256_core dut(
                   .clk(tb_clk),
                   .reset_n(tb_reset_n),
                 
                   .init(tb_init),
                   .next(tb_next),

                   .block(tb_block),
                   
                   .ready(tb_ready),
                   
                   .digest(tb_digest),
                   .digest_valid(tb_digest_valid)
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
  //----------------------------------------------------------------
  task dump_dut_state();
    begin
      $display("State of DUT");
      $display("------------");
      
      $display("Control signals and counter:");
      $display("sha256_ctrl_reg = 0x%02x", dut.sha256_ctrl_reg);
      $display("digest_init = 0x%01x, digest_update = 0x%01x", 
               dut.digest_init, dut.digest_update);
      $display("state_init = 0x%01x, state_update = 0x%01x", 
               dut.state_init, dut.state_update);
      $display("first_block = 0x%01x, ready_flag = 0x%01x, w_init = 0x%01x", 
               dut.first_block, dut.ready_flag, dut.w_init);
      $display("t_ctr_inc = 0x%01x, t_ctr_rst = 0x%01x, t_ctr_reg = 0x%02x", 
               dut.t_ctr_inc, dut.t_ctr_rst, dut.t_ctr_reg);
      $display("");

      $display("State registers:");
      $display("a_reg = 0x%08x, b_reg = 0x%08x, c_reg = 0x%08x, d_reg = 0x%08x", 
               dut.a_reg, dut.b_reg, dut.c_reg, dut.d_reg);
      $display("e_reg = 0x%08x, f_reg = 0x%08x, g_reg = 0x%08x, h_reg = 0x%08x", 
               dut.e_reg, dut.f_reg, dut.g_reg, dut.h_reg);
      $display("");

      $display("State update values:");
      $display("w  = 0x%08x, k  = 0x%08x", dut.w, dut.K);
      $display("t1 = 0x%08x, t2 = 0x%08x", dut.t1, dut.t2);
      $display("");
    end
  endtask // dump_dut_state
  
  
  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task init_sim();
    begin
      tb_clk = 0;
      tb_reset_n = 1;

      tb_init = 0;
      tb_next = 0;
      tb_block = 512'h00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
  endtask // init_dut

  
  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task single_block_test(input [7 : 0] tc_number,
                         input [511 : 0] block,
                         input [255 : 0] expected);
   begin
     
     init_sim();
     
     $display("*** Single block test case %d: Done", tc_number);
     $display("");
   end
  endtask // single_block_test

  
  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task double_block_test(input [7 : 0] tc_number,
                         input [511 : 0] block1,
                         input [255 : 0] expected1,
                         input [511 : 0] block2,
                         input [255 : 0] expected2);
   begin

      $display("*** Double block test case %d: Done", tc_number);
      $display("");
   end
  endtask // single_block_test
                         
    
  //----------------------------------------------------------------
  // sha256_core_test
  // The main test functionality. 
  //
  // Test cases taken from:
  // http://csrc.nist.gov/groups/ST/toolkit/documents/Examples/SHA256.pdf
  //----------------------------------------------------------------
  initial
    begin : sha256_core_test
      reg [511 : 0] tc1;
      reg [255 : 0] res1;

      reg [511 : 0] tc2_1;
      reg [255 : 0] res2_1;
      reg [511 : 0] tc2_2;
      reg [255 : 0] res2_2;
      
      $display("   -- Testbench for sha256 core started --");

      init_sim();
      dump_dut_state();
        
      // TC1: Single block message: "abc".
      tc1 = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
      res1 = 256'hBA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD;
      single_block_test(1, tc1, res1);
      

      // TC2: Double block message.
      // "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
      tc2_1 = 512'h6162636462636465636465666465666765666768666768696768696A68696A6B696A6B6C6A6B6C6D6B6C6D6E6C6D6E6F6D6E6F706E6F70718000000000000000;
      res2_1 = 256'h85E655D6417A17953363376A624CDE5C76E09589CAC5F811CC4B32C1F20E533A;
      
      tc2_2 = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001C0;
      res2_2 = 256'h248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1;
      double_block_test(2, tc2_1, res2_1, tc2_2, res2_2);
      
      
      $display("*** Simulation done.");
      $finish;
    end // sha256_core_test
endmodule // tb_sha256_core

//======================================================================
// EOF tb_sha256_core.v
//======================================================================
