# scripts/gen_impl.tcl

source [file dirname [info script]]/colors.tcl

print_header "Implementation & Bitstream Generation"

set top_name ""
if { $argc > 0 } {
    set top_name [lindex $argv 0]
}

cputs $C_CYAN "Opening Project..."
set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] == 0} {
    print_error "No .xpr project found. Run 'make hwbuild' first."
    exit 1
}
open_project -quiet [lindex $project_files 0]

# Check Synthesis Status
cputs $C_CYAN "Checking Synthesis status..."
set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]

if {![string match "*Complete*" $synth_status] || $synth_progress != "100%"} {
    print_error "Synthesis is not complete (Status: $synth_status)."
    cputs $C_YELLOW "Please run 'make hwgen_syn' first."
    exit 1
}

# Reset previous implementation run to ensure a clean build
if {[string match "*Complete*" [get_property STATUS [get_runs impl_1]]]} {
    cputs $C_CYAN "Resetting previous implementation run..."
    reset_run impl_1
}

cputs $C_CYAN "Launching Implementation & Bitstream Generation..."
# -to_step write_bitstream: runs all steps including bitstream generation
if {[catch {launch_runs impl_1 -to_step write_bitstream -jobs 4 -quiet} err]} {
    print_error "Failed to launch implementation."
    puts $err
    exit 1
}

wait_on_run impl_1

set run_status [get_property PROGRESS [get_runs impl_1]]

if {$run_status eq "100%"} {
    set run_result [get_property STATUS [get_runs impl_1]]
    
    if {[string match "*Complete*" $run_result]} {
        print_success "Implementation Complete! ($run_result)"
        
        # Verify Bitstream existence
        set impl_dir [get_property DIRECTORY [get_runs impl_1]]
        set bit_files [glob -nocomplain "$impl_dir/*.bit"]
        
        if {[llength $bit_files] > 0} {
            set bit_name [file tail [lindex $bit_files 0]]
            cputs $C_GREEN "Bitstream generated successfully: $bit_name"
            cputs $C_YELLOW "Location: $impl_dir/$bit_name"
        } else {
            cputs $C_RED "Warning: Run completed, but no .bit file found."
        }
        
    } else {
        print_error "Implementation Failed with status: $run_result"
        cputs $C_YELLOW "Check log for details: ../hardware/work/[current_project].runs/impl_1/runme.log"
        exit 1
    }
} else {
    print_error "Implementation did not complete (Stuck at $run_status)."
    exit 1
}