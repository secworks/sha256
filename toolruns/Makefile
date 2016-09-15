#===================================================================
#
# Makefile
# --------
# Makefile for building sha256 wmem, core and top simulations.
#
#
# Author: Joachim Strombergson
# Copyright (c) 2013, Secworks Sweden AB
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#===================================================================

WMEM_SRC=../src/rtl/sha256_w_mem.v
WMEM_TB_SRC=../src/tb/tb_sha256_w_mem.v

CORE_SRC=../src/rtl/sha256_core.v ../src/rtl/sha256_k_constants.v ../src/rtl/sha256_w_mem.v
CORE_TB_SRC=../src/tb/tb_sha256_core.v

TOP_SRC=../src/rtl/sha256.v $(CORE_SRC)
TOP_TB_SRC=../src/tb/tb_sha256.v

CC=iverilog
LINT=verilator


all: top.sim core.sim wmem.sim


top.sim: $(TOP_TB_SRC) $(TOP_SRC)
	$(CC) -o top.sim $(TOP_TB_SRC) $(TOP_SRC)


core.sim: $(CORE_TB_SRC) $(CORE_SRC)
	$(CC) -o core.sim $(CORE_SRC) $(CORE_TB_SRC)


wmem.sim: $(WMEM_SRC) $(WMEM_TB_SRC)
	$(CC) -o wmem.sim $(WMEM_SRC) $(WMEM_TB_SRC)

#The stream testbench computes the digest of a randomly created reference file,
# and compares it to the output of Python's hashlib library
# Before the testbench can be run, the reference file must be padded by the
# pad.py script, and the expected sha must be calculated by python's hashlib
# Any file can be digested in the testbench by running
# REFERENCE_FILE=</path/to/file> make sim-stream
# Note that this testbench also uses FuseSoC and can be run with different
# simulators by setting $(SIM) to any of icarus, modelsim, isim or xsim.
# Default is icarus

SIM ?= icarus
REFERENCE_FILE ?= reference_file

reference_file:
	dd if=/dev/random of=$@ count=1 bs=1k

%.padded: %
	python ../src/scripts/pad.py $<

$(REFERENCE_FILE).sha: $(REFERENCE_FILE)
	python -c "import hashlib;print(int(hashlib.sha256(open('$<', 'rb').read()).hexdigest(), 16))" > $@

sim-stream: $(REFERENCE_FILE).padded $(REFERENCE_FILE).sha
	fusesoc --cores-root=.. sim --sim=$(SIM) --testbench=tb_sha256_stream sha256 --file=$< --expected_sha=$(shell cat $(REFERENCE_FILE).sha)

sim-top: top.sim
	./top.sim


sim-core: core.sim
	./core.sim


sim-wmem: wmem.sim
	./wmem.sim

lint:
	verilator --lint-only ../src/rtl/sha256.v ../src/rtl/sha256_core.v ../src/rtl/sha256_k_constants.v ../src/rtl/sha256_w_mem.v
	verilator --lint-only ../src/rtl/sha256_stream.v ../src/rtl/sha256_core.v ../src/rtl/sha256_k_constants.v ../src/rtl/sha256_w_mem.v



debug:
	@echo "No debug available."


clean:
	rm -f top.sim
	rm -f core.sim
	rm -f wmem.sim


help:
	@echo "Supported targets:"
	@echo "------------------"
	@echo "all:      Build all simulation targets."
	@echo "wb:       Build the Wishbone simulation target."
	@echo "top:      Build the top simulation target."
	@echo "core:     Build the core simulation target."
	@echo "wmem:     Build the wmem simulation target."
	@echo "sim-wb:   Run top Wishbone simulation."
	@echo "sim-top:  Run top level simulation."
	@echo "sim-core: Run core level simulation."
	@echo "sim-wmem: Run wmem level simulation."
	@echo "lint:     Run the linter on both the block based and the stream based top levels."
	@echo "debug:    Print the internal varibles."
	@echo "clean:    Delete all built files."

#===================================================================
# EOF Makefile
#===================================================================
