# scripts/run_src_sim.tcl

source [file dirname [info script]]/colors.tcl

print_header "Behavioral Simulation"

set tb_name ""
if { $argc > 0 } {
    set tb_name [lindex $argv 0]
}

# Open Project
cputs $C_CYAN "Opening Project..."
set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] == 0} {
    print_error "No .xpr project found. Run 'make project' first."
    exit 1
}
open_project -quiet [lindex $project_files 0]

# Resolve Testbench Name
if { $tb_name eq "" } {
    # fetch the "top" property from the simulation fileset
    set tb_name [get_property top [get_filesets sim_1]]
    cputs $C_YELLOW "Warning: No testbench specified. Using project default: $tb_name"
} else {
    cputs $C_GREEN "Target Testbench: $tb_name"
}

set_property top $tb_name [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

# Launch Simulation
cputs $C_CYAN "Running Simulation..."
if {[catch {launch_simulation -quiet} err]} {
    print_error "Simulation failed."
    puts $err
    exit 1
}

print_success "Simulation Complete."

# Robustly construct the path instead of querying the run object
set project_name [current_project]
set wdb_path "../hardware/work/${project_name}.sim/sim_1/behav/xsim"

cputs $C_YELLOW "Waveform DB: ${wdb_path}/${tb_name}_behav.wdb"
# cputs $C_CYAN "To view waves, run: make view_sim"