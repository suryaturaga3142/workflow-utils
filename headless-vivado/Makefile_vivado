# ./Makefile

# ==============================================================================
#  algoFPGA Makefile
#  Description: Modular build system for Hardware (Vivado) and Software
# ==============================================================================

# --- Configuration ---
SHELL         := /bin/bash
PROJECT_NAME  := algoFPGA
SCRIPTS_DIR   := scripts
HARDWARE_DIR  := hardware
TIMESTAMP_DIR := $(SCRIPTS_DIR)/timestamps
WORK_DIR      := $(HARDWARE_DIR)/work
SRC_DIR       := $(HARDWARE_DIR)/src
SIM_DIR       := $(HARDWARE_DIR)/sim
CONST_DIR     := $(HARDWARE_DIR)/constraints
WAVES_DIR     := $(HARDWARE_DIR)/waves

# Scripts
REBUILD        := rebuild_project.tcl
UPDATE_FILESET := update_fileset.tcl
LINT           := lint.tcl
GEN_SYN        := gen_syn.tcl
SRC_SIM        := run_src_sim.tcl
SYN_SIM        := run_syn_sim.tcl
VW_WVS         := view_waves.tcl
GEN_IMPL	   := gen_impl.tcl
PROG_FPGA	   := program_fpga.tcl

# Extract the testbench/module name for unique timestamps (defaults to 'default')
# If ARGS="tb_adder -gui", MD_ID becomes "tb_adder"
MD_ID := $(if $(ARGS),$(firstword $(ARGS)),default)

# Vivado Commands
VIVADO_BAT := vivado -mode batch -notrace -quiet -source
VIVADO_GUI := vivado -mode gui -notrace -quiet -source

# --- ANSI Colors ---
COLOR_RESET   = \033[0m
COLOR_BOLD    = \033[1m
COLOR_GREEN   = \033[32m
COLOR_CYAN    = \033[36m
COLOR_RED     = \033[31m
COLOR_YELLOW  = \033[33m

# --- Helper Functions ---
define print_header
	echo -e "\n$(COLOR_BOLD)$(COLOR_CYAN)=== $(1) ===$(COLOR_RESET)"
endef

define clean_vivado_junk
	rm -rf $(SCRIPTS_DIR)/.Xil $(SCRIPTS_DIR)/*.jou $(SCRIPTS_DIR)/*.log
endef

define check_work_dir
	if [ ! -d "$(WORK_DIR)" ]; then \
		echo -e "$(COLOR_RED)Error: Project directory $(WORK_DIR) does not exist.$(COLOR_RESET)"; \
		echo -e "Run '$(COLOR_BOLD)make hwbuild$(COLOR_RESET)' to create it."; \
		exit 1; \
	fi
endef

# --- Targets ---
.PHONY: all help hw hwlist hwbuild hwlint hwsim_src hwopen_wv_src hwsrc \
        hwgen_syn hwsim_syn hwopen_wv_syn hwsyn hwsave hwimpl hwflash hwcram \
		hwclean hwveryclean clean veryclean

# Default: Update fileset for hardware (software coming soon)
all: hw

# ==============================================================================
#  Dependency Tracking
# ==============================================================================

# Fileset Timestamps
$(TIMESTAMP_DIR)/.fileset_timestamp: $(shell find $(SRC_DIR) $(SIM_DIR) $(CONST_DIR) -type f 2>/dev/null)
	@$(call check_work_dir)
	@$(call print_header,Updating Fileset)
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(UPDATE_FILESET)
	@touch $@
	@$(call clean_vivado_junk)

# Lint Timestamps
# Depends on fileset. specific to the module ID (MD_ID) passed in ARGS.
$(TIMESTAMP_DIR)/.lint_$(MD_ID).timestamp: $(TIMESTAMP_DIR)/.fileset_timestamp
	@$(call print_header,Running Lint ($(MD_ID)))
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(LINT) -tclargs $(ARGS)
	@touch $@
	@$(call clean_vivado_junk)

# RTL Simulation Timestamps
# Matches files like: scripts/timestamps/.sim_src_*.timestamp
$(TIMESTAMP_DIR)/.sim_src_%.timestamp: $(TIMESTAMP_DIR)/.fileset_timestamp
	@$(call print_header,Running RTL Simulation ($*))
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(SRC_SIM) -tclargs $(ARGS)
	@touch $@
	@$(call clean_vivado_junk)

# Synthesis Timestamp
$(TIMESTAMP_DIR)/.syn_%.timestamp: $(TIMESTAMP_DIR)/.fileset_timestamp
	@$(call print_header,Running Synthesis)
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(GEN_SYN) -tclargs $(ARGS)
	@touch $@
	@$(call clean_vivado_junk)

# Post-Synthesis Simulation Timestamp
$(TIMESTAMP_DIR)/.sim_syn_%.timestamp: $(TIMESTAMP_DIR)/.syn_%.timestamp
	@$(call check_work_dir)
	@$(call print_header,Running Post-Synth Simulation ($*))
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(SYN_SIM) -tclargs $(ARGS)
	@touch $@
	@$(call clean_vivado_junk)

# Implementation Timestamp
$(TIMESTAMP_DIR)/.impl_%.timestamp: $(TIMESTAMP_DIR)/.syn_%.timestamp
	@$(call print_header,Running Implementation)
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(GEN_IMPL) -tclargs $(ARGS)
	@touch $@
	@$(call clean_vivado_junk)

# ==============================================================================
#  Hardware Commands (hw*)
# ==============================================================================

# Update Fileset
hw: $(TIMESTAMP_DIR)/.fileset_timestamp
	@echo -e "$(COLOR_GREEN)Project fileset is up to date.$(COLOR_RESET)"

# List Files
hwlist:
	@$(call print_header,Hardware File List)
	@echo -e "$(COLOR_YELLOW)[ Sources ]$(COLOR_RESET)"
	@find $(SRC_DIR) -type f -name "*.sv" -o -name "*.v" 2>/dev/null | sed 's/^/  /'
	@echo -e "$(COLOR_YELLOW)[ Simulation ]$(COLOR_RESET)"
	@find $(SIM_DIR) -type f -name "*.sv" -o -name "*.v" 2>/dev/null | sed 's/^/  /'
	@echo -e "$(COLOR_YELLOW)[ Constraints ]$(COLOR_RESET)"
	@find $(CONST_DIR) -type f -name "*.xdc" 2>/dev/null | sed 's/^/  /'

# Build Project
hwbuild:
	@if [ -d "$(WORK_DIR)" ]; then \
		echo -e "$(COLOR_YELLOW)Warning: Project already exists at $(WORK_DIR).$(COLOR_RESET)"; \
	else \
		$(call print_header,Building Project); \
		mkdir -p $(TIMESTAMP_DIR) && \
		(cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(REBUILD)) && \
		touch $(TIMESTAMP_DIR)/.fileset_timestamp && \
		$(call clean_vivado_junk) && \
		echo -e "$(COLOR_GREEN)Project built successfully.$(COLOR_RESET)"; \
	fi

# Linting
hwlint: $(TIMESTAMP_DIR)/.lint_$(MD_ID).timestamp

# Simulation (RTL)
hwsim_src: $(TIMESTAMP_DIR)/.sim_src_$(MD_ID).timestamp

# Open Waveform (RTL)
hwopen_wv_src:
	@$(call check_work_dir)
	@$(call print_header,Opening RTL Waveform)
	@cd $(SCRIPTS_DIR) && $(VIVADO_GUI) $(VW_WVS) -tclargs $(ARGS) rtl
	@$(call clean_vivado_junk)

# Full RTL Flow (Lint -> Sim -> Open)
hwsrc: hwlint hwsim_src hwopen_wv_src

# Synthesis
hwgen_syn: $(TIMESTAMP_DIR)/.syn_$(MD_ID).timestamp

# Simulation (Post-Synth)
hwsim_syn: $(TIMESTAMP_DIR)/.sim_syn_$(MD_ID).timestamp

# Open Waveform (Post-Synth)
hwopen_wv_syn:
	@$(call check_work_dir)
	@$(call print_header,Opening Synthesis Waveform)
	@cd $(SCRIPTS_DIR) && $(VIVADO_GUI) $(VW_WVS) -tclargs $(ARGS) synth
	@$(call clean_vivado_junk)

# Full Synth Flow (Synth -> Sim -> Open)
hwsyn: hwgen_syn hwsim_syn hwopen_wv_syn

# Save the system block diagram
hwsave:
	@$(call print_header,"Saving Block Diagram")
	@(cd $(SCRIPTS_DIR) && $(VIVADO_BAT) save_bd.tcl); \
	RET=$$?; \
	$(call clean_vivado_junk); \
	if [ $$RET -eq 0 ]; then \
		echo -e "$(COLOR_GREEN)Block diagram exported to hardware/src/bd_system.tcl$(COLOR_RESET)"; \
	else \
		echo -e "$(COLOR_RED)Error: Failed to save block diagram.$(COLOR_RESET)"; \
		exit $$RET; \
	fi

# Implementation (Bitstream)
hwimpl: $(TIMESTAMP_DIR)/.impl_$(MD_ID).timestamp

# Program FPGA (JTAG)
hwflash:
	@$(call print_header,Programming FPGA via JTAG)
	@cd $(SCRIPTS_DIR) && $(VIVADO_BAT) $(PROG_FPGA)
	@$(call clean_vivado_junk)

# Full FPGA Flash Flow (Synth -> Impl -> Flash)
hwcram: hwgen_syn hwimpl hwflash

# Cleaning
hwclean:
	@$(call print_header,Cleaning Hardware Artifacts)
	@rm -rf $(SCRIPTS_DIR)/.Xil $(SCRIPTS_DIR)/*.jou $(SCRIPTS_DIR)/*.log
	@rm -f $(TIMESTAMP_DIR)/.*timestamp
	@rm -rf $(WORK_DIR)/$(PROJECT_NAME).sim/*
	@rm -f $(WORK_DIR)/*.rpt
	@echo -e "$(COLOR_GREEN)Removed logs, journals, simulation files, and timestamp sentinels.$(COLOR_RESET)"

# Deep Cleaning
hwveryclean: hwclean
	@$(call print_header,Removing Project Directory)
	@rm -f $(WAVES_DIR)/*
	@echo -e "$(COLOR_GREEN)Cleared waveform configuration files.$(COLOR_RESET)"
	@rm -rf $(WORK_DIR)
	@echo -e "$(COLOR_GREEN)Removed $(WORK_DIR)$(COLOR_RESET)"

# ==============================================================================
#  Software Commands (sw*)
# ==============================================================================
# Coming soon!


# ==============================================================================
#  Common Commands (*)
# ==============================================================================

# Cleaning (software addition coming soon)
clean: hwclean
veryclean: hwveryclean

# Help
help:
	@echo -e "$(COLOR_BOLD)Project Makefile Help$(COLOR_RESET)"
	@echo -e "Usage: make [target] [ARGS=\"<arguments>\"]"
	@echo -e "If the module/testbench name is not passed, most commands default to detected top level."
	@echo ""
	@echo -e "$(COLOR_CYAN)General Commands:$(COLOR_RESET)"
	@echo -e "  $(COLOR_GREEN)help$(COLOR_RESET)           : Print this help message."
	@echo -e "  $(COLOR_GREEN)all$(COLOR_RESET)            : Updates project fileset (default target)."
	@echo -e "  $(COLOR_GREEN)clean$(COLOR_RESET)          : Cleans project logs, journals, and temp files."
	@echo -e "  $(COLOR_GREEN)veryclean$(COLOR_RESET)      : Removes ALL project related build files. Keeps sources only."
	@echo ""
	@echo -e "$(COLOR_CYAN)Hardware Commands:$(COLOR_RESET)"
	@echo -e "  $(COLOR_GREEN)hw$(COLOR_RESET)             : Update hardware project fileset."
	@echo -e "  $(COLOR_GREEN)hwlist$(COLOR_RESET)         : List all source, simulation, and constraint files."
	@echo -e "  $(COLOR_GREEN)hwbuild$(COLOR_RESET)        : Create the Vivado project (run once)."
	@echo -e "  $(COLOR_GREEN)hwlint$(COLOR_RESET)         : Lint RTL design with Vivado."
	@echo -e "  $(COLOR_GREEN)hwsim_src$(COLOR_RESET)      : Run RTL Simulation and generate waveform file."
	@echo -e "  $(COLOR_GREEN)hwopen_wv_src$(COLOR_RESET)  : Open RTL waveform in Vivado GUI."
	@echo -e "  $(COLOR_GREEN)hwsrc$(COLOR_RESET)          : Full RTL Flow (Lint -> Sim -> Open)."
	@echo -e "  $(COLOR_GREEN)hwgen_syn$(COLOR_RESET)      : Run Vivado Synthesis tool."
	@echo -e "  $(COLOR_GREEN)hwsim_syn$(COLOR_RESET)      : Run Post-Synthesis Simulation and generate waveform file."
	@echo -e "  $(COLOR_GREEN)hwopen_wv_syn$(COLOR_RESET)  : Open Post-Synth waveform in Vivado GUI."
	@echo -e "  $(COLOR_GREEN)hwsyn$(COLOR_RESET)          : Full Synth Flow (Synth -> Sim -> Open)."
	@echo -e "  $(COLOR_GREEN)hwsave$(COLOR_RESET)         : Save system level block diagram."
	@echo -e "  $(COLOR_GREEN)hwimpl$(COLOR_RESET)         : Run Implementation and generate Bitstream."
	@echo -e "  $(COLOR_GREEN)hwexport$(COLOR_RESET)       : Uses Implementation to generate project XSA file for Petalinux Build (Coming soon)."
	@echo -e "  $(COLOR_GREEN)hwflash$(COLOR_RESET)        : Flashes FPGA with existing bitstream through JTAG."
	@echo -e "  $(COLOR_GREEN)hwcram$(COLOR_RESET)         : Full FPGA Flash Flow (Synth -> Impl -> Flash)."
	@echo -e "  $(COLOR_GREEN)hwclean$(COLOR_RESET)        : Remove logs, journals, and temp files."
	@echo -e "  $(COLOR_GREEN)hwveryclean$(COLOR_RESET)    : Remove entire project directory. Will need to rerun '$(COLOR_BOLD)make hwbuild$(COLOR_RESET)'."
	@echo ""
	@echo -e "$(COLOR_CYAN)Software Commands:$(COLOR_RESET)"
	@echo -e "  (Coming Soon)"
	@echo ""
