# scripts/update_fileset.tcl

source [file dirname [info script]]/colors.tcl

set_msg_config -id "filemgmt 20-742" -suppress

set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] > 0} {
    open_project -quiet [lindex $project_files 0]
} else {
    print_error "No project found to update. Run 'make project' first."
    exit 1
}

cputs $C_CYAN "Scanning for new design sources..."
set obj [get_filesets sources_1]
add_files -quiet -fileset $obj "../hardware/src"

set sv_files [get_files -quiet -of_objects $obj *.sv]
if {[llength $sv_files] > 0} {
    set_property file_type SystemVerilog $sv_files
}

# Block Diagram Wrapper Handling
set bd_files [get_files -quiet -of_objects $obj *.bd]
if {[llength $bd_files] > 0} {
    cputs $C_CYAN "Found Block Diagram. Checking for wrapper..."
    set bd_file [lindex $bd_files 0]

    # Check if a wrapper file already exists in the list of sources
    set wrapper_name "[file rootname [file tail $bd_file]]_wrapper"
    set wrapper_found [get_files -quiet -of_objects $obj "${wrapper_name}.*"]

    if {[llength $wrapper_found] == 0} {
        cputs $C_YELLOW "Wrapper missing. Generating HDL wrapper for BD..."
        # Create the wrapper file
        make_wrapper -files [get_files $bd_file] -top
        
        # Find where Vivado put it (usually inside the project structure) and add it
        set wrapper_path [glob -nocomplain "../hardware/work/*.gen/sources_1/bd/*/hdl/${wrapper_name}.v*"]
        if {[llength $wrapper_path] > 0} {
            add_files -norecurse [lindex $wrapper_path 0]
        }
    }
}

cputs $C_CYAN "Scanning for new constraints..."
set obj [get_filesets constrs_1]
catch { add_files -quiet -fileset $obj "../hardware/constraints" }

cputs $C_CYAN "Scanning for new simulation files..."
set obj [get_filesets sim_1]
add_files -quiet -fileset $obj "../hardware/sim"
set sv_files [get_files -quiet -of_objects $obj *.sv]
if {[llength $sv_files] > 0} {
    set_property file_type SystemVerilog $sv_files
}

cputs $C_CYAN "Updating design hierarchy..."
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

print_success "Project fileset updated successfully."