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

  
  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  sha256_w_mem dut(
                   .clk(clk),
                   .reset_n(reset_n),
                   
                   .init(w_init),
                   
                   .block(block),
                   .addr(w_addr),
                   
                   .ready(w_ready),
                   .w(w)
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
  // The main test functionality. 
  //----------------------------------------------------------------
  initial
    begin : w_mem_test
      $display("   -- Testbench for sha256 w memory started --");


      // TC1: Empty block
      // digest 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

      $display("*** Simulation done.");
      $finish;
    end // sha256_core_test
  
endmodule // w_mem_test
  
//======================================================================
// EOF tb_sha256_w_mem.v
//======================================================================
