//======================================================================
//
// tb_sha256_stream.v
// -----------
// Testbench for the SHA-256 stream interface wrapper.
//
//
// Author: Olof Kindgren
// Copyright (c) 2016, Olof Kindgren
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

module tb_sha256_stream();

   vlog_tb_utils vtu();

   parameter DW = 32;

   reg clk = 1'b1;
   reg rst = 1'b1;

   wire [DW-1:0] tdata;
   wire 	 tvalid;
   wire 	 tready;

   wire [511:0]  tdata_resized;
   wire 	 tvalid_resized;
   wire 	 tready_resized;

   wire [255:0]  digest;
   wire 	 digest_valid;

   always #5 clk <= !clk;
   initial #20 rst = 1'b0;

   stream_writer
     #(.WIDTH (DW),
       .MAX_BLOCK_SIZE (1))
   writer
     (.clk (clk),
      .stream_m_data_o  (tdata),
      .stream_m_valid_o (tvalid),
      .stream_m_ready_i (tready));

   stream_upsizer
     #(.DW_IN (DW),
       .SCALE (512/DW),
       .BIG_ENDIAN(1))
   upsizer
     (.clk (clk),
      .rst (rst),
      //Slave Interface
      .s_data_i  (tdata),
      .s_valid_i (tvalid),
      .s_ready_o (tready),
      //Master Interface
      .m_data_o  (tdata_resized),
      .m_valid_o (tvalid_resized),
      .m_ready_i (tready_resized));

   sha256_stream dut
     (.clk            (clk),
      .rst            (rst),
      .mode           (1'b1),
      .s_tdata_i      (tdata_resized),
      .s_tlast_i      (1'b0),
      .s_tvalid_i     (tvalid_resized),
      .s_tready_o     (tready_resized),
      .digest_o       (digest),
      .digest_valid_o (digest_valid));

   integer 	 digested_blocks = 0;

   always @(posedge digest_valid)
     digested_blocks = digested_blocks + 1;

   reg [DW-1:0] word;

   reg [1024*8-1:0] filename = "";

   integer 	    filesize;
   integer 	    f;
   integer 	    c;

   reg [255:0] 	    expected_sha;

   initial begin
      if (!$value$plusargs("file=%s", filename)) begin
	 $display("No file specified");
	 $finish;
      end

      if (!$value$plusargs("expected_sha=%d", expected_sha)) begin
	 $display("No expected SHA specified. Will only print SHA, not verify");
      end

      @(negedge rst);
      @(posedge clk);

      f = $fopen(filename, "rb");

      c = $fread(word, f);
      while (c) begin
	 writer.write_word(word);
	 c = $fread(word, f);
      end
      filesize = $ftell(f);
      $fclose(f);

      while(digested_blocks*64 < filesize)
	@(posedge clk);
      $display("%h", digest);
      if (expected_sha)
	if (expected_sha == digest)
	  $display("SHA ok");
	else
	  $display("SHA failed! Expected %h", expected_sha);
      $finish;
   end

endmodule
