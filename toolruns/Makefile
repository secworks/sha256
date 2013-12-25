#===================================================================
#
# Makefile
# --------
# Makefile for building sha256 core and top simulation.
#
#
# (c) 2013 Joachim Strombergson
#
#===================================================================

WMEM_SRC=../src/rtl/sha256_w_mem.v
WMEM_TB_SRC=../src/tb/tb_sha256_w_mem.v

CORE_SRC=../src/rtl/sha256_core.v ../src/rtl/sha256_k_constants.v ../src/rtl/sha256_w_mem.v
CORE_TB_SRC=../src/tb/tb_sha256_core.v

TOP_SRC=../src/rtl/sha256.v $(CORE_SRC)
TOP_TB_SRC=../src/tb/tb_sha256.v

CC=iverilog


all: top core


top: $(TOP_TB_SRC) $(TOP_SRC)
	$(CC) -o top.sim $(TOP_TB_SRC) $(TOP_SRC)


core: $(CORE_TB_SRC) $(CORE_SRC)
	$(CC) -o core.sim $(CORE_SRC) $(CORE_TB_SRC)


wmem: $(WMEM_SRC) $(WMEM_TB_SRC)
	$(CC) -o wmem.sim $(WMEM_SRC) $(WMEM_TB_SRC)


sim-top: top.sim
	./top.sim


sim-core: core.sim
	./core.sim


sim-wmem: wmem.sim
	./wmem.sim


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
	@echo "top:      Build the top simulation target."
	@echo "core:     Build the core simulation target."
	@echo "wmem:     Build the wmem simulation target."
	@echo "sim-top:  Run top level simulation."
	@echo "sim-core: Run core level simulation."
	@echo "sim-core: Run wmem level simulation."
	@echo "debug:    Print the internal varibles."
	@echo "clean:    Delete all built files."

#===================================================================
# EOF Makefile
#===================================================================

