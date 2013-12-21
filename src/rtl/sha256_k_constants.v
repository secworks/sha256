//======================================================================
//
// sha256_k_constants.v
// --------------------
// The table K with constants in the SHA-256 hash function.
//
//
// Copyright (c) 2013 Secworks Sweden AB
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

module sha256_k_constants(
                          input wire  [5 : 0] addr,
                          output wire [31 : 0] K
                         );

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] tmp_K;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign K = tmp_K;
  
  
  //----------------------------------------------------------------
  // addr_mux
  //----------------------------------------------------------------
  always @*
    begin : addr_mux
      case(addr)
        0:
          begin
            tmp_K = 32'h428a2f98;
          end

        1:
          begin
            tmp_K = 32'h71374491;
          end

        2:
          begin
            tmp_K = 32'hb5c0fbcf;
          end
        
        3:
          begin
            tmp_K = 32'he9b5dba5;
          end
        
        4:
          begin
            tmp_K = 32'h3956c25b;
          end
        
        5:
          begin
            tmp_K = 32'h59f111f1;
          end
        
        6:
          begin
            tmp_K = 32'h923f82a4;
          end
        
        7:
          begin
            tmp_K = 32'hab1c5ed5;
          end
        
        8:
          begin
            tmp_K = 32'hd807aa98;
          end
        
        9:
          begin
            tmp_K = 32'h12835b01;
          end
        
        10:
          begin
            tmp_K = 32'h243185be;
          end
        
        11:
          begin
            tmp_K = 32'h550c7dc3;
          end
        
        12:
          begin
            tmp_K = 32'h72be5d74;
          end
        
        13:
          begin
            tmp_K = 32'h80deb1fe;
          end
        
        14:
          begin
            tmp_K = 32'h9bdc06a7;
          end
        
        15:
          begin
            tmp_K = 32'hc19bf174;
          end
        
        16:
          begin
            tmp_K = 32'he49b69c1;
          end
        
        17:
          begin
            tmp_K = 32'hefbe4786;
          end
        
        18:
          begin
            tmp_K = 32'h0fc19dc6;
          end
        
        19:
          begin
            tmp_K = 32'h240ca1cc;
          end
        
        20:
          begin
            tmp_K = 32'h2de92c6f;
          end
        
        21:
          begin
            tmp_K = 32'h4a7484aa;
          end
        
        22:
          begin
            tmp_K = 32'h5cb0a9dc;
          end
        
        23:
          begin
            tmp_K = 32'h76f988da;
          end
        
        24:
          begin
            tmp_K = 32'h983e5152;
          end
        
        25:
          begin
            tmp_K = 32'ha831c66d;
          end
        
        26:
          begin
            tmp_K = 32'hb00327c8;
          end
        
        27:
          begin
            tmp_K = 32'hbf597fc7;
          end
        
        28:
          begin
            tmp_K = 32'hc6e00bf3;
          end
        
        29:
          begin
            tmp_K = 32'hd5a79147;
          end
        
        30:
          begin
            tmp_K = 32'h06ca6351;
          end
        
        31:
          begin
            tmp_K = 32'h14292967;
          end
        
        32:
          begin
            tmp_K = 32'h27b70a85;
          end
        
        33:
          begin
            tmp_K = 32'h2e1b2138;
          end
        
        34:
          begin
            tmp_K = 32'h4d2c6dfc;
          end
        
        35:
          begin
            tmp_K = 32'h53380d13;
          end
        
        36:
          begin
            tmp_K = 32'h650a7354;
          end
        
        37:
          begin
            tmp_K = 32'h766a0abb;
          end
        
        38:
          begin
            tmp_K = 32'h81c2c92e;
          end
        
        39:
          begin
            tmp_K = 32'h92722c85;
          end
        
        40:
          begin
            tmp_K = 32'ha2bfe8a1;
          end
        
        41:
          begin
            tmp_K = 32'ha81a664b;
          end
        
        42:
          begin
            tmp_K = 32'hc24b8b70;
          end
        
        43:
          begin
            tmp_K = 32'hc76c51a3;
          end
        
        44:
          begin
            tmp_K = 32'hd192e819;
          end
        
        45:
          begin
            tmp_K = 32'hd6990624;
          end
        
        46:
          begin
            tmp_K = 32'hf40e3585;
          end
        
        47:
          begin
            tmp_K = 32'h106aa070;
          end
        
        48:
          begin
            tmp_K = 32'h19a4c116;
          end
        
        49:
          begin
            tmp_K = 32'h1e376c08;
          end
        
        50:
          begin
            tmp_K = 32'h2748774c;
          end
        
        51:
          begin
            tmp_K = 32'h34b0bcb5;
          end
        
        52:
          begin
            tmp_K = 32'h391c0cb3;
          end
        
        53:
          begin
            tmp_K = 32'h4ed8aa4a;
          end
        
        54:
          begin
            tmp_K = 32'h5b9cca4f;
          end
        
        55:
          begin
            tmp_K = 32'h682e6ff3;
          end
        
        56:
          begin
            tmp_K = 32'h748f82ee;
          end
        
        57:
          begin
            tmp_K = 32'h78a5636f;
          end
        
        58:
          begin
            tmp_K = 32'h84c87814;
          end
        
        59:
          begin
            tmp_K = 32'h8cc70208;
          end
        
        60:
          begin
            tmp_K = 32'h90befffa;
          end
        
        61:
          begin
            tmp_K = 32'ha4506ceb;
          end
        
        62:
          begin
            tmp_K = 32'hbef9a3f7;
          end
        
        63:
          begin
            tmp_K = 32'hc67178f2;
          end
      endcase // case (addr)
      
//======================================================================
// sha256_k_constants.v
//======================================================================
