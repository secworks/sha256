//======================================================================
//
// tb_sha256.v
// -----------
// Testbench for the SHA-256 top level wrapper.
//
//
// Author: Joachim Strombergson
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


//------------------------------------------------------------------
// Test module.
//------------------------------------------------------------------
module tb_sha256();
  
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter DEBUG = 1;

  parameter CLK_HALF_PERIOD = 2;

  // The address map.
  parameter ADDR_CTRL        = 8'h00;
  parameter CTRL_INIT_BIT    = 0;
  parameter CTRL_NEXT_BIT    = 1;

  parameter ADDR_STATUS      = 8'h01;
  parameter STATUS_READY_BIT = 0;
  parameter STATUS_VALID_BIT = 1;
                             
  parameter ADDR_BLOCK0    = 8'h10;
  parameter ADDR_BLOCK1    = 8'h11;
  parameter ADDR_BLOCK2    = 8'h12;
  parameter ADDR_BLOCK3    = 8'h13;
  parameter ADDR_BLOCK4    = 8'h14;
  parameter ADDR_BLOCK5    = 8'h15;
  parameter ADDR_BLOCK6    = 8'h16;
  parameter ADDR_BLOCK7    = 8'h17;
  parameter ADDR_BLOCK8    = 8'h18;
  parameter ADDR_BLOCK9    = 8'h19;
  parameter ADDR_BLOCK10   = 8'h1a;
  parameter ADDR_BLOCK11   = 8'h1b;
  parameter ADDR_BLOCK12   = 8'h1c;
  parameter ADDR_BLOCK13   = 8'h1d;
  parameter ADDR_BLOCK14   = 8'h1e;
  parameter ADDR_BLOCK15   = 8'h1f;
                             
  parameter ADDR_DIGEST0   = 8'h20;
  parameter ADDR_DIGEST1   = 8'h21;
  parameter ADDR_DIGEST2   = 8'h22;
  parameter ADDR_DIGEST3   = 8'h23;
  parameter ADDR_DIGEST4   = 8'h24;
  parameter ADDR_DIGEST5   = 8'h25;
  parameter ADDR_DIGEST6   = 8'h26;
  parameter ADDR_DIGEST7   = 8'h27;

  
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

  reg [31 : 0] read_data;
  
  
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
  //
  // Generates a cycle counter and displays information about
  // the dut as needed.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      #(2 * CLK_HALF_PERIOD);
      cycle_ctr = cycle_ctr + 1;
    end

  
  //----------------------------------------------------------------
  // dump_dut_state()
  //
  // Dump the state of the dump when needed.
  //----------------------------------------------------------------
  task dump_dut_state();
    begin
      $display("State of DUT");
      $display("------------");
      $display("Inputs and outputs:");
      $display("cs = 0x%01x, write_read = 0x%01x", 
               dut.cs, dut.write_read);
      $display("address = 0x%02x", dut.address);
      $display("data_in = 0x%08x, data_out = 0x%08x", 
               dut.data_in, dut.data_out);
      $display("tmp_data_out = 0x%08x", dut.tmp_data_out);
      $display("");

      $display("Control and status:");
      $display("ctrl = 0x%02x, status = 0x%02x", 
               {dut.next_reg, dut.init_reg}, 
               {dut.digest_valid_reg, dut.ready_reg});
      $display("");
      
      $display("Message block:");
      $display("block0  = 0x%08x, block1  = 0x%08x, block2  = 0x%08x,  block3  = 0x%08x",
               dut.block0_reg, dut.block1_reg, dut.block2_reg, dut.block3_reg);
      $display("block4  = 0x%08x, block5  = 0x%08x, block6  = 0x%08x,  block7  = 0x%08x",
               dut.block4_reg, dut.block5_reg, dut.block6_reg, dut.block7_reg);

      $display("block8  = 0x%08x, block9  = 0x%08x, block10 = 0x%08x,  block11 = 0x%08x",
               dut.block8_reg, dut.block9_reg, dut.block10_reg, dut.block11_reg);
      $display("block12 = 0x%08x, block13 = 0x%08x, block14 = 0x%08x,  block15 = 0x%08x",
               dut.block12_reg, dut.block13_reg, dut.block14_reg, dut.block15_reg);
      $display("");
      
      $display("Digest:");
      $display("digest = 0x%064x", dut.digest_reg);
      $display("");
      
    end
  endtask // dump_dut_state
  
  
  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggles reset to force the DUT into a well defined state.
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
  // write_word()
  //
  // Write the given word to the DUT using the DUT interface.
  //----------------------------------------------------------------
  task write_word(input [7 : 0]  address,
                  input [31 : 0] word);
    begin
      if (DEBUG)
        begin
          $display("*** Writing 0x%08x to 0x%02x.", word, address);
          $display("");
        end
         
      tb_address = address;
      tb_data_in = word;
      tb_cs = 1;
      tb_write_read = 1;
      #(2 * CLK_HALF_PERIOD);
      tb_cs = 0;
      tb_write_read = 0;
    end
  endtask // write_word
  

  //----------------------------------------------------------------
  // read_word()
  //
  // Read a data word from the given address in the DUT.
  //----------------------------------------------------------------
  task read_word(input [7 : 0]  address);
    begin
      tb_address = address;
      tb_cs = 1;
      tb_write_read = 0;
      #(2 * CLK_HALF_PERIOD);
      read_data = tb_data_out;
      tb_cs = 0;

      if (DEBUG)
        begin
          $display("*** Reading 0x%08x from 0x%02x.", read_data, address);
          $display("");
        end
    end
  endtask // read_word


  //----------------------------------------------------------------
  // write_block()
  //
  // Write the given block to the dut.
  //----------------------------------------------------------------
  task write_block(input [511 : 0] block);
    begin
      write_word(ADDR_BLOCK0,  block[511 : 480]);
      write_word(ADDR_BLOCK1,  block[479 : 448]);
      write_word(ADDR_BLOCK2,  block[447 : 416]);
      write_word(ADDR_BLOCK3,  block[415 : 384]);
      write_word(ADDR_BLOCK4,  block[383 : 352]);
      write_word(ADDR_BLOCK5,  block[351 : 320]);
      write_word(ADDR_BLOCK6,  block[319 : 288]);
      write_word(ADDR_BLOCK7,  block[287 : 256]);
      write_word(ADDR_BLOCK8,  block[255 : 224]);
      write_word(ADDR_BLOCK9,  block[223 : 192]);
      write_word(ADDR_BLOCK10, block[191 : 160]);
      write_word(ADDR_BLOCK11, block[159 : 128]);
      write_word(ADDR_BLOCK12, block[127 :  96]);
      write_word(ADDR_BLOCK13, block[95  :  64]);
      write_word(ADDR_BLOCK14, block[63  :  32]);
      write_word(ADDR_BLOCK15, block[31  :   0]);
    end
  endtask // write_block
  
  
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
      // while (!tb_ready)
      //   begin
      //     #(2 * CLK_HALF_PERIOD);
      //   end
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
      reset_dut();
      dump_dut_state();

      write_word(8'h10, 32'hdeadbeef);
      dump_dut_state();

      read_word(8'h10);
      dump_dut_state();

      write_block(512'hff001122334455667788990123456789abcdefa55aa55aa55adeadbeefdeadead001122334455667788990123456789abcdefa55aa55aa55adeadbeefdeadead);
      dump_dut_state();
      
      display_test_result();
      $display("*** Simulation done. ***");
      $finish;
    end // sha256_test
endmodule // tb_sha256

//======================================================================
// EOF tb_sha256.v
//======================================================================
