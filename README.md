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
- 9037 LEs
- 3349 registers
- 71.5 MHz
- 66 cycles latency


## Todo ##
 - Verify the top.
 - Cleanup of the code and documentation


## Status ##
**(2014-01-09)**
- The core is functionally correct for single and multiple block messages.
- The Python model is functionally correct.
- Test implementation in FPGA has been done.


**(2014-01-07)**
The core and the wrapper is basically done but needs to be
debugged. There are testbenches for the core, the wrapper as well as the
message word scheduler memory.

The Python model is almost verified.



