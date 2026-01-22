# scripts/view_waves.tcl

set tb_name ""
set sim_mode "rtl" ;# Default to RTL

foreach arg $argv {
    if {$arg == "rtl" || $arg == "synth"} {
        set sim_mode $arg
    } else {
        # If it's not a reserved keyword, it must be the TB name
        set tb_name $arg
    }
}

if { $tb_name eq "" } {
    puts "No testbench specified. Checking project for default..."
    
    set project_files [glob -nocomplain ../hardware/work/*.xpr]
    if {[llength $project_files] == 0} {
        puts "Error: No .xpr project found. Run 'make project' first."
        exit 1
    }
    
    open_project -quiet [lindex $project_files 0]
    set tb_name [get_property top [get_filesets sim_1]]
    close_project
    puts "Using project default: $tb_name"
} else {
    puts "Target Testbench: $tb_name"
}

set project_name [file rootname [file tail [lindex [glob ../hardware/work/*.xpr] 0]]]
set sim_dir "../hardware/work/${project_name}.sim/sim_1"

# Determine WDB Path based on Mode
if { $sim_mode eq "synth" } {
    puts "Mode: Post-Synthesis Simulation"
    set wdb_path "${sim_dir}/synth/func/xsim/${tb_name}_func_synth.wdb"
} else {
    puts "Mode: Behavioral (RTL) Simulation"
    set wdb_path "${sim_dir}/behav/xsim/${tb_name}_behav.wdb"
}

set wcfg_path "../hardware/waves/${tb_name}.wcfg"

if {[file exists $wdb_path]} {
    puts "Opening waveform database: $wdb_path"
    
    open_wave_database $wdb_path
    
    if {[file exists $wcfg_path]} {
        puts "Loading unified configuration: $wcfg_path"
        open_wave_config $wcfg_path
    } else {
        puts "No custom configuration found at $wcfg_path"
        puts "Loading default view (all signals)."
        add_wave /
    }
    
} else {
    puts "Error: Waveform file not found at: $wdb_path"
    if { $sim_mode eq "synth" } {
        puts "Did you run 'make sim_synth'? (gen_synth.tcl then run_synth_sim.tcl)"
    } else {
        puts "Did the simulation run successfully? Check run_sim.tcl output."
    }
}