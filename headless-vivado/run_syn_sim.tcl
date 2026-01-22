# scripts/run_syn_sim.tcl

source [file dirname [info script]]/colors.tcl

print_header "Post-Synthesis Simulation"

set tb_name ""
if { $argc > 0 } {
    set tb_name [lindex $argv 0]
}

cputs $C_CYAN "Opening Project..."
set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] == 0} {
    print_error "No .xpr project found. Run 'make project' first."
    exit 1
}
open_project -quiet [lindex $project_files 0]

if { $tb_name eq "" } {
    set tb_name [get_property top [get_filesets sim_1]]
    cputs $C_YELLOW "Warning: No testbench specified. Using project default: $tb_name"
} else {
    cputs $C_GREEN "Target Testbench: $tb_name"
}

set_property top $tb_name [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1

# Enable Logging
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

set synth_status [get_property STATUS [get_runs synth_1]]
if {![string match "*Complete*" $synth_status]} {
    print_error "Synthesis has not completed yet. Run 'gen_synth.tcl' first."
    exit 1
}

# -mode post-synthesis: Uses the netlist, not the RTL
# -type functional: Ignores timing constraints
cputs $C_CYAN "Running Post-Synthesis Simulation..."
if {[catch {launch_simulation -mode post-synthesis -type functional -quiet} err]} {
    print_error "Simulation failed."
    puts $err
    exit 1
}

print_success "Simulation Complete."

set project_name [current_project]
set wdb_path "../hardware/work/${project_name}.sim/sim_1/synth/func/xsim"

cputs $C_YELLOW "Waveform DB: ${wdb_path}/${tb_name}_func_synth.wdb"