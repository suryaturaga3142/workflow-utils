# scripts/save_bd.tcl

set project_files [glob -nocomplain ../hardware/work/*.xpr]
if {[llength $project_files] > 0} {
    open_project -quiet [lindex $project_files 0]
} else {
    puts "Error: No project found."
    exit 1
}

# Find the Block Diagram
set bd_files [get_files *.bd]
if {[llength $bd_files] > 0} {
    puts "Found Block Diagram. Exporting to Tcl..."
    open_bd_design [lindex $bd_files 0]
    # Write the Tcl to hardware/src/bd_system.tcl
    # -force: overwrite existing
    # -make_local: ensures IP settings are portable
    write_bd_tcl -force -make_local "../hardware/src/bd_system.tcl"
    
    puts "Success: Block Diagram saved to hardware/src/bd_system.tcl"
} else {
    puts "No Block Diagram found to save."
    exit 1
}