# scripts/gen_syn.tcl

source [file dirname [info script]]/colors.tcl

print_header "Synthesis Run"

set top_name ""
if { $argc > 0 } {
    set top_name [lindex $argv 0]
}

cputs $C_CYAN "Opening Project..."
set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] == 0} {
    print_error "No .xpr project found. Run 'make project' first."
    exit 1
}
open_project -quiet [lindex $project_files 0]

if { $top_name eq "" } {
    # Fetch the current "top" property from the source fileset
    set top_name [get_property top [get_filesets sources_1]]
    cputs $C_YELLOW "Warning: No top module specified. Using project default: $top_name"
} else {
    cputs $C_GREEN "Target Top Module: $top_name"
}

set_property top $top_name [get_filesets sources_1]
update_compile_order -fileset sources_1

cputs $C_CYAN "Resetting previous synthesis runs..."
reset_run synth_1

cputs $C_CYAN "Launching Synthesis for $top_name..."
if {[catch {launch_runs synth_1 -jobs 4 -quiet} err]} {
    print_error "Failed to launch synthesis."
    puts $err
    exit 1
}

wait_on_run synth_1

set run_status [get_property PROGRESS [get_runs synth_1]]

if {$run_status eq "100%"} {
    # Check if it ended in error or success
    set run_result [get_property STATUS [get_runs synth_1]]
    
    if {[string match "*Complete*" $run_result]} {
        print_success "Synthesis Complete! ($run_result)"
        
        set report_file "../hardware/work/[current_project].runs/synth_1/${top_name}_utilization_synth.rpt"
        cputs $C_YELLOW "Report available at: $report_file"
        
    } else {
        print_error "Synthesis Failed with status: $run_result"
        cputs $C_YELLOW "Check log for details: ../hardware/work/[current_project].runs/synth_1/runme.log"
        exit 1
    }
} else {
    print_error "Synthesis did not complete (Stuck at $run_status)."
    exit 1
}