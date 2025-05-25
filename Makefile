# User & File Configuration
base=my_new
suff=_tb
lang=1
extra_src=
extra_h=
# For SystemVerilog / Verilog building
fpga=ice40#                        FPGA
device=8k#                         }
timedev=hx8k#                      } Model details
footprint=ct256#                   }
top=top_$(base)#                   Top module
pcf=$(fpga)$(timedev).pcf#         Pin constraint file
build_dir=./build-$(base)-$(fpga)# Directory to store build files
#######################

# Language Configuration - Extensions, Compilers, Flags
# SystemVerilog
ext_1=sv
ext_h_1=sv
cc_1=iverilog
cc_1_flags=-g2012
# Verilog
ext_2=v
ext_h_2=vh
cc_2=$(cc_1)
cc_2_flags=
# SystemVerilog / Verilog Simulation Specific
ext_wv=vcd
cc_wv=gtkwave
cc_wv_flags=
cc_linter=verilator
cc_linter_flags=--lint-only -Werror-WIDTH -Werror-SELRANGE -Werror-COMBDLY -Werror-LATCH -Werror-MULTIDRIVEN
# SystemVerilog / Verilog Build Specific
rtl_synth=yosys#                        RTL Synthesis tool
router=nextpnr-$(fpga)#                 FPGA Routing & Placing tool
router_flags=--pcf-allow-unconstrained# --gui then pack place route for visual placement & routing
pack=icepack#                           Tool for bitstream file handling
prog=iceprog#                           Tool for flashing
# C
ext_3=c
ext_h_3=h
cc_3=gcc
cc_3_flags=-g -std=c11 -Wall -Wshadow -Wvla -Werror -pedantic
# C++
ext_4=cpp
ext_h_4=hpp
cc_4=gcc
cc_4_flags=$(cc_3_flags)
# C / C++ Specific
cc_gcov_flags=$(cc_$(lang)_flags) -ftest-coverage -fprofile-arcs -dumpbase ''
#######################

# Language Selection
ext=$(ext_$(lang))
ext_h=$(ext_h_$(lang))
cc=$(cc_$(lang))
cc_flags=$(cc_$(lang)_flags)
#######################

# File Configuration
src=$(base).$(ext)#           base.ext
src_h=$(base).$(ext_h) #      base.ext_h
src_tb=$(base)$(suff).$(ext)# base_tb.ext
exec=$(base)$(suff)#          base_tb
exec_wv=$(exec).$(ext_wv)#    base_tb.ext_wv
exec_gcov=$(exec)_gcov#       base_tb_gcov
topc=$(top).$(ext)#           top_base.ext
src_json=$(base).json#        base.json
src_asc=$(base).asc#          base.asc
src_bin=$(base).bin#          base.bin
src_uf2=$(base).uf2#          base.uf2
#######################

# Targets
# Executable file compilation
$(exec): $(src) $(extra_src) $(src_tb) $(src_h) $(extra_h)
ifeq ($(shell expr $(lang) \<= 2),1)# Lints source files with cc_linter for HDL
	$(cc_linter) $(src) $(extra_src) $(cc_linter_flags)
endif
	$(cc) -o $@ $(src) $(extra_src) $(src_tb) $(cc_flags)
# Waveform executable check
$(exec_wv): $(exec)
# Run the executable file
test: $(exec)
	./$<
# Run waveforms
sim: hdl_guard $(exec_wv) test
	$(cc_wv) $(exec_wv) $(cc_wv_flags)
# Synthesize code for FPGA
synth: hdl_guard $(src) $(extra_src) $(topc)
	mkdir -p $(build_dir)
	$(rtl_synth) -p "synth_$(fpga) -top $(top) -json $(build_dir)/$(src_json)" $(topc) $(src) $(extra_src)
# Place & Route for FPGA
route: synth $(pcf)
	$(router) --$(timedev) --package $(footprint) --json $(build_dir)/$(src_json) --pcf $(pcf) --asc $(build_dir)/$(src_asc) $(router_flags)
# Bitstream handling for FPGA
bits: route
	$(pack) $(build_dir)/$(src_asc) $(build_dir)/$(src_bin)
# Flashing to FPGA
flash: bits
	bin2uf2 -o $(build_dir)/$(src_uf2) $(build_dir)/$(src_bin)
#$(prog) -S $(build_dir)/$(src_bin)
# Compile and run coverage for C / C++ only
coverage: $(src) $(src_tb)
ifeq ($(shell expr $(lang) \<= 2), 1)
	@echo "Error: Command not applicable for lang="$(lang); exit 2
endif
	$(cc) -o $(exec_gcov) $^ $(cc_gcov_flags)
	./$(exec_gcov)
	gcov -f $<
# Guard for HDL specific commands
hdl_guard:
ifeq ($(shell expr $(lang) \> 2), 1)
	@echo "Error: Command not applicable for lang="$(lang); exit 2
endif
	@echo "Success: HDL Guard check"
# Clean all test files
clean-exec:
	rm -f $(exec) *.o *.$(ext-wv)
clean-gcov:
	rm -f $(exec_gcov) *.gcda *.gcno *.c.gcov *.gcov
clean-build:
	rm -f $(build_dir)/*.json $(build_dir)/*.asc $(build_dir)/*.bin $(build_dir)/*.uf2
	rm -d $(build_dir)
clean: clean-exec clean-gcov clean-build
#######################

# PHONY Commands
.PHONY: test sim synth route bits flash coverage hdl_guard clean-exec clean-gcov clean-build clean