# scripts/colors.tcl
# Color Palette and Helper Functions

# --- ANSI Color Definitions ---
set C_RESET     "\033\[0m"
set C_CYAN      "\033\[0;36m"   ;# Info / Action
set C_GREEN     "\033\[0;32m"   ;# Success / Safe
set C_YELLOW    "\033\[0;33m"   ;# Artifacts / Paths
set C_RED       "\033\[0;31m"   ;# Danger / Errors
set C_BPURPLE   "\033\[1;35m"   ;# Headers (Bold Purple)

# --- Helper Procedures ---

# Usage: cputs $C_CYAN "Starting synthesis..."
# Purpose: Prints a message in color and automatically resets at the end.
proc cputs {color msg} {
    # Access global variables defined above
    global C_RESET
    puts "${color}${msg}${C_RESET}"
}

# Usage: print_header "My Script Title"
# Purpose: Standardized header format
proc print_header {title} {
    global C_BPURPLE C_RESET
    puts ""
    puts "${C_BPURPLE}=== $title ===${C_RESET}"
    puts ""
}

# Usage: print_error "Something went wrong"
# Purpose: Standardized error format
proc print_error {msg} {
    global C_RED C_RESET
    puts "${C_RED}Error: ${msg}${C_RESET}"
}

# Usage: print_success "Build complete"
# Purpose: Standardized success format
proc print_success {msg} {
    global C_GREEN C_RESET
    puts "${C_GREEN}Success: ${msg}${C_RESET}"
}