#!/bin/bash
# ~/ece40656/scripts/init_workspace.sh

# Purpose: RUN ONCE!! Initializes the custom directory structure for ECE40656.
# You should basically never have to run this unless you're starting. It's just a convinience script.

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}Initializing ECE40656 Workspace...${NC}"

# --- Configuration ---
#ROOT_DIR=$(pwd)
REQUIRED_DIRS=("scripts" "design_libs" "results" "tmp" "logs" "specs")
CDS_LIB="cds.lib"
#PDK_LIB="gpdk045"

# --- Directory Structure ---
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "Created directory: ${YELLOW}$dir${NC}"
    else
        echo -e "Directory exists: ${GREEN}$dir${NC}"
    fi
done

# --- cds.lib Management ---
if [ ! -f "$CDS_LIB" ]; then
    echo -e "${CYAN}Creating $CDS_LIB...${NC}"
    touch "$CDS_LIB"
    echo "INCLUDE ${GPDK45_ROOT}/cds.lib" >> "$CDS_LIB"
    echo -e "Created: ${YELLOW}$CDS_LIB${NC}"
else
    echo -e "Found: ${GREEN}$CDS_LIB${NC}"
fi

# --- Permissions ---
# Ensure scripts are executable
chmod +x scripts/*.sh 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "Permissions: ${GREEN}Scripts made executable.${NC}"
fi

echo -e "${GREEN}Initialization Complete.${NC}"
