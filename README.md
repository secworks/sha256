[![build-openlane-sky130](https://github.com/secworks/sha256/actions/workflows/ci.yml/badge.svg?branch=master&event=push)](https://github.com/secworks/sha256/actions/workflows/ci.yml)

# sha256 #

## Implementation status ##
The core has been completed for a long time and been used in several
designs in ASICs as well as in FPGAs. The core is considered mature and
ready for use. Minor changes are non-functional cleanups of code.


## Introduction
Hardware implementation of the SHA-256 cryptographic hash function with
support for both SHA-256 and SHA-224. The implementation is written in
Verilog 2001 compliant code. The implementation includes the main core
as well as wrappers that provides interfaces for simple integration.

This is a low area implementation that iterates over the rounds but
there is no sharing of operations such as adders.

The hardware implementation is complemented by a functional model
written in Python.

Note that the core does **NOT** implement padding of final block. The
caller is expected to handle padding.


## Implementation details ##
The sha256 design is divided into the following sections.
- src/rtl - RTL source files
- src/tb  - Testbenches for the RTL files
- src/model/python - Functional model written in python
- doc - documentation (currently not done.)
- toolruns - Where tools are supposed to be run. Includes a Makefile for
building and simulating the design using
[Icarus Verilog](http://iverilog.icarus.com/). There are also targets
for linting the core using [Verilator](http://www.veripool.org/wiki/verilator).

The actual core consists of the following files:
- sha256_core.v - The core itself with wide interfaces.
- sha256_w_mem.v - W message block memory and block expansion logic.
- sha256_k_constants.v - K constants ROM memory.

The top level entity is called sha256_core. This entity has wide
interfaces (512 bit block input, 256 bit digest). In order to make it
usable you probably want to wrap the core with a bus interface.


The provided top level wrapper, sha256.v provides a simple 32-bit memory
like interface. The core (sha256_core) will sample all data inputs when
given the init or next signal. the wrapper contains additional data
registers. This allows you to load a new block while the core is
processing the previous block.


The core supports both sha224 and sha256 modes. The default mode is
sha256. The mode bit is located in the ADDR_CTRL API register and this
means that when writing to this register to start processing a block,
care must be taken to set the mode bit to the intended mode. This means
that old code that for example simply wrote 0x01 to initiate SHA256
processing will now initiate SHA224 processing. Writing 0x05 will
now initiate SHA256 processing.

Regarding SHA224, it is up to the user to only read seven, not eight
words from the digest registers. The core will update the LSW too.


## Streaming interface ##
There is a streaming interface for the core contributed by
[Olof Kindgren](https://github.com/olofk).

- src/interfaces/stream/rtl - RTL source file for wrapped core
- src/interfaces/stream/tb - Testbench for the wrapped core


## AXI4 interface ##

**NOTE** This interface is currently being developed. Expect bugs as this
interface is still under development.

There is now an AXI4 interface for the core contributed by
[Sanjay A Menon](https://github.com/Sanjay-A-Menon). The interface wraps
sha256_core, replacing sha256.v

The interface provides an AXI4-Lite slave interface with added hash
complete interrupt signal. Chip select is implemented via axi_awprot
signal.

- src/interfaces/axi4/rtl - RTL source file for wrapped core
- src/interfaces/axi4/tb  - Testbench for the wrapped core



## FuseSoC Integration
This core is supported by the
[FuseSoC](https://github.com/olofk/fusesoc) core package manager and
build system. Some quick  FuseSoC instructions:

install FuseSoC
~~~
pip install fusesoc
~~~

Create and enter a new workspace
~~~
mkdir workspace && cd workspace
~~~

Register sha256 as a library in the workspace
~~~
fusesoc library add sha256 /path/to/sha256
~~~

...if repo is available locally or...
...to get the upstream repo
~~~
fusesoc library add sha256 https://github.com/secworks/sha256
~~~

To run lint
~~~
fusesoc run --target=lint secworks:crypto:sha256
~~~

Run tb_sha256 testbench
~~~
fusesoc run --target=tb_sha256 secworks:crypto:sha256
~~~

Run with modelsim instead of default tool (icarus)
~~~
fusesoc run --target=tb_sha256 --tool=modelsim secworks:crypto:sha256
~~~

List all targets
~~~
fusesoc core show secworks:crypto:sha256
~~~


## ASIC-results ##
Implementation in 40 nm low power standard cell process.
- Area: 14200 um2
- Combinational cells: 2344.9230
- Non-combinational cells: 2902.4856
- Clock frequency: 250 MHz


## Fpga-results ##

### Altera Cyclone FPGAs ###
Implementation results using Altera Quartus-II 13.1.

**Cyclone IV E**
- EP4CE6F17C6
- 3882 LEs
- 1813 registers
- 74 MHz
- 66 cycles latency

**Cyclone IV GX**
- EP4CGX22CF19C6
- 3773 LEs
- 1813 registers
- 76 MHz
- 66 cycles latency

**Cyclone V**
- 5CGXFC7C7F23C8
- 1469 ALMs
- 1813 registers
- 79 MHz
- 66 cycles latency


### Microchip ###

***IGLOO2***
- Tool: Libero v 12.4
- Device: M2GL090TS-1FG484I
- LUTs: 2811
- SLEs: 1900
- BRAMs: 0
- Fmax: 114 MHz


### Xilinx FPGAs ###
Implementation results using ISE 14.7.

**Spartan-6**
- xc6slx45-3csg324
- 2012 LUTs
- 688 Slices
- 1929 regs
- 70 MHz
- 66 cycles latency

**Artix-7**
- xc7a200t-3fbg484
- 2471 LUTs
- 747 Slices
- 1930 regs
- 108 MHz
- 66 cycles latency


Implementation results using Vivado 2014.4.

**Zynq-7030**
- xc7z030fbg676-1
- 2308 LUTs
- 796 Slices
- 2116 regs
- 116 MHz
- 66 cycles latency


Implementation results using Vivado v.2019.2

Results kindly provided by
[Sanjay-A-Menon](https://github.com/Sanjay-A-Menon). Implemented design
includes the AXI4 wrapper.

**Zynq-7020**
- Device: 7z020clg400-1
- Slice LUTs: 2555
- Slice regs: 2606
- Fmax: 78 MHz
- 66 cycles latency
