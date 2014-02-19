# sha256 #
Hardware implementation of the SHA-256 cryptographic hash function. The
implementation is written in Verilog 2001 compliant code. The
implementation includes a core and a wrapper that provides a 32-bit
interface for simple integration.

This is a low area implementation that iterates over the rounds but
there is no sharing of operations such as adders.

The hardware implementation is complemented by a functional model
written in Python.


## Implementation ##
Implementation results using the Altera Quartus 13 design tool.

### Cyclone IV GX ###
- 9587 LEs
- 3349 registers
- 73 MHz
- 66 cycles latency


## Todo ##
- Cleanup of the code.
- Complete documentation.


## Status ##
**(2014-02-19)**
- Added name and version constants to the top level wrapper. Also added
  an api error signal that flags read or write attempts to addresses
  that does not support these operations. Writing to the version
  constant for example."

- There is also an experimental Wishbone wrapper (wb_sha256.v) as an
  alternative to the standard top. There is also a testbench for the
  Wisbone top.
  

**(2014-02-04)**
- Completed testbench for top level wrapper. The top level interface can
control, check status of the SHA-256. Single as well as multiple block
processing is being tested and works.

- The initial version of a Wishbone wrapper and associated testbench has
been added.


**(2014-01-25)**
- Changed the W memory to an array based implementation. The resulting
core is 10% larger and 2 MHz slower. But the code is much more compact
and should be easy to optimize down to the previous results. The
original register based implementation is available in the file
sha256_w_mem_regs.v



**(2014-01-09)**
- The core is functionally correct for single and multiple block messages.
- The Python model is functionally correct.
- Test implementation in FPGA has been done. The results in Cyclone IV GX:
  - 9037 LEs
  - 3349 registers
  - 71.5 MHz
  - 66 cycles latency



**(2014-01-07)**
- The core and the wrapper is basically done but needs to be
debugged. There are testbenches for the core, the wrapper as well as the
message word scheduler memory.

- The Python model is almost verified.



