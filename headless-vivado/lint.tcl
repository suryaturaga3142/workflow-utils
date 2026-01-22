# scripts/lint.tcl

source [file dirname [info script]]/colors.tcl

print_header "RTL Linting (Elaboration & DRC)"

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
    set top_name [get_property top [get_filesets sources_1]]
    cputs $C_YELLOW "Warning: No top module specified. Using project default: $top_name"
} else {
    cputs $C_GREEN "Target Top Module: $top_name"
}

# -rtl: tells Vivado NOT to synthesize to gates, just build the structure
# -name rtl_1: creates a memory design snapshot named 'rtl_1'
cputs $C_CYAN "Elaborating Design..."
if {[catch {synth_design -top $top_name -rtl -name rtl_1 -quiet} err]} {
    print_error "Elaboration Failed! Syntax errors found."
    puts $err
    exit 1
}

cputs $C_CYAN "Running Methodology Checks..."
set report_file "../hardware/work/lint_methodology.rpt"
report_methodology -file $report_file -quiet

# Scan the design for 'Critical Warnings' which usually indicate broken logic
set crit_warnings [get_msg_config -count -severity {CRITICAL WARNING}]
set warnings [get_msg_config -count -severity {WARNING}]

puts ""
puts "----------------------------------------"
puts "             LINT SUMMARY               "
puts "----------------------------------------"

if {$crit_warnings > 0} {
    cputs $C_RED "CRITICAL WARNINGS: $crit_warnings"
    puts "(These will likely cause Simulation/Synthesis failure)"
} else {
    cputs $C_GREEN "CRITICAL WARNINGS: 0"
}

if {$warnings > 0} {
    cputs $C_YELLOW "WARNINGS: $warnings"
} else {
    cputs $C_GREEN "WARNINGS: 0"
}

puts "Detailed report: $report_file"

# Run DRC (Design Rule Checks)
# report_drc -file "../hardware/work/lint_drc.rpt" -quiet

if {$crit_warnings > 0} {
    exit 1
} else {
    print_success "Lint Passed."
}