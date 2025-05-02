
PROJECT_NAME = saylinx_scr1

QUARTUS_BIN_DIR = ~/intelFPGA_lite/21.1/quartus/bin/
# QUARTUS_MAP = ./intelFPGA_lite/21.1/quartus/bin/quartus_map

FPGA_FAMILY = "Cyclone IV E"
FPGA_DEVICE = EP4CE6F17I7

FPGA_TOP = $(PROJECT_NAME).sv

NUM_PROC_CMD = NUM_PARALLEL_PROCESSORS
NUM_PROC_CNT = 14 

# Исключаем файлы с AXI
AHB_SYNTH_FILES = \
	$(foreach file, \
		$(wildcard ip/scr1/src/top/*.sv), \
			$(if $(findstring axi, $(file)), ,$(file)))

SYNTH_FILES =  \
	$(wildcard *.sv) \
	$(wildcard ip/scr1/src/core/pipeline/*.sv) \
	$(wildcard ip/scr1/src/core/primitives/*.sv) \
	$(wildcard ip/scr1/src/core/*.sv) \
	$(wildcard ip/uart16550/rtl/verilog/*.v) \
	$(wildcard ip/ahb-2-wishbone/src/*.v) \
	$(AHB_SYNTH_FILES) 

LIB_DIRS = \
	ip \
	ip/scr1/src/includes 

	
all:
	bash $(QUARTUS_BIN_DIR)/quartus_map $(PROJECT_NAME)

	

