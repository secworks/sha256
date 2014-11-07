# sha256 #
Hardware implementation of the SHA-256 cryptographic hash function. The
implementation is written in Verilog 2001 compliant code. The
implementation includes a core and wrappers that provides interfaces for
simple integration.

This is a low area implementation that iterates over the rounds but
there is no sharing of operations such as adders.

The hardware implementation is complemented by a functional model
written in Python.

The core is basically done and ready for use. (I think.)


## Implementation details ##
The sha256 design is divided into the following sections.
- src/rtl - RTL source files
- src/tb  - Testbenches for the RTL files
- src/model/python - Functional model written in python
- doc - documentation (currently not done.)
- toolruns - Where tools are supposed to be run. Includes a Makefile for
building and simulating the design using [Icarus Verilog](http://iverilog.icarus.com/)

The actual core consists of the following files:
- sha256_core.v - The core itself with wide interfaces.
- sha256_w_mem.v - W message block memort and expansion logic.
- sha256_k_constants.v - K constants ROM memory.

The top level entity is called sha256_core. This entity has wide
interfaces (512 bit block input, 256 bit digest). In order to make it
usable you probably want to wrap the core with a bus interface.

Unless you want to provide your own interface you therefore also need to
select one top level wrapper. There are two wrappers provided:
- sha256.v - A wrapper with a 32-bit memory like interface.
- wb_sha256.v - A wrapper that implements a [Wishbone](http://opencores.org/opencores,wishbone) interface.

***Do not include both wrappers in the same project.***

The core (sha256_core) will sample all data inputs when given the init
or next signal. the wrappers provided contains additional data
registers. This allows you to load a new block while the core is
processing the previous block.


## FPGA-results ##

### Altera Cyclone FPGAs ###
Implementation results using Altera Quartus-II 13.1.

*** Cyclone IV E ***
- EP4CE6F17C6
- 3882 LEs
- 1813 registers
- 74 MHz
- 66 cycles latency

*** Cyclone IV GX ***
- EP4CGX22CF19C6
- 3773 LEs
- 1813 registers
- 76 MHz
- 66 cycles latency

*** Cyclone V ***
- 5CGXFC7C7F23C8
- 1469 ALMs
- 1813 registers
- 79 MHz
- 66 cycles latency

### Xilinx FPGAs ###
Implementation results using ISE 14.7.

*** Spartan-6 ***
- xc6slx45-3csg324
- 2012 LUTs
- 688 Slices
- 1929 regs
- 70 MHz
- 66 cycles latency


## TODO ##
- Complete documentation.


## Status ##

***(2013-02-25)***

Added results for Spartan-6.


***(2013-02-25)***

Updated README with some more information about the design.


***(2013-02-23)***

Cleanup, more results etc. Move all wmem update logic to a separate
process for a cleaner code.


***(2014-02-21)***

Reworked the W-memory into a sliding window solution that only
requires 16 32-bit words. The difference in size is quite
impressive. The old results was:

- 9587 LEs
- 3349 registers
- 73 MHz

The new results are:

- 3765 LEs
- 1813 registers
- 76 MHz

That is a 2.5x reduction in size, 1.8x less regs and slightly higher
clock frequency.


***(2014-02-19)***
- Added name and version constants to the top level wrapper. Also added
  an api error signal that flags read or write attempts to addresses
  that does not support these operations. Writing to the version
  constant for example."

- There is also an experimental Wishbone wrapper (wb_sha256.v) as an
  alternative to the standard top. There is also a testbench for the
  Wisbone top.


***(2014-02-04)***
- Completed testbench for top level wrapper. The top level interface can
control, check status of the SHA-256. Single as well as multiple block
processing is being tested and works.

- The initial version of a Wishbone wrapper and associated testbench has
been added.


***(2014-01-25)***
- Changed the W memory to an array based implementation. The resulting
core is 10% larger and 2 MHz slower. But the code is much more compact
and should be easy to optimize down to the previous results. The
original register based implementation is available in the file
sha256_w_mem_regs.v


***(2014-01-09)***
- The core is functionally correct for single and multiple block messages.
- The Python model is functionally correct.
- Test implementation in FPGA has been done. The results in Cyclone IV GX:
  - 9037 LEs
  - 3349 registers
  - 71.5 MHz
  - 66 cycles latency



***(2014-01-07)***
- The core and the wrapper is basically done but needs to be
debugged. There are testbenches for the core, the wrapper as well as the
message word scheduler memory.

- The Python model is almost verified.
