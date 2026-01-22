# scripts/program_fpga.tcl

source [file dirname [info script]]/colors.tcl

print_header "Program FPGA (JTAG)"

cputs $C_CYAN "Opening Hardware Manager..."
open_hw_manager -quiet

cputs $C_CYAN "Connecting to Hardware Server..."
connect_hw_server -quiet
if {[catch {open_hw_target} err]} {
    print_error "Could not connect to target. Is the board plugged in?"
    exit 1
}

set hw_device [lindex [get_hw_devices] 0]
current_hw_device $hw_device
refresh_hw_device -update_hw_probes false $hw_device

cputs $C_GREEN "Found Device: [get_property PART $hw_device]"

# Find the bitstream from the implementation run
set project_files [glob -nocomplain ../hardware/work/*.xpr]
open_project -quiet [lindex $project_files 0]
set impl_dir [get_property DIRECTORY [get_runs impl_1]]
set bit_files [glob -nocomplain "$impl_dir/*.bit"]

if {[llength $bit_files] == 0} {
    print_error "No bitstream found. Run 'make hwimpl' first."
    exit 1
}

set bitstream [lindex $bit_files 0]
cputs $C_CYAN "Programming with: [file tail $bitstream]"

set_property PROGRAM.FILE $bitstream $hw_device
if {[catch {program_hw_devices $hw_device} err]} {
    print_error "Programming failed."
    puts $err
    exit 1
}

print_success "FPGA Programmed Successfully."
close_hw_manager