#!/bin/bash

# This is sourced

# --- Color Configuration ---
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
B_PURPLE='\033[1;35m'

CONDA_ROOT_DIR="/path/to/condas"

# --- Helper Functions ---

function get_cm_list {
    # Check if dir exists
    if [ -d "$CONDA_ROOT_DIR" ]; then
        # List directories in the root, remove full path to just get names
        ls -d "$CONDA_ROOT_DIR"/*/ 2>/dev/null | xargs -n 1 basename
    fi
}

function show_cm_usage {
    echo ""
    echo -e "${B_PURPLE}Python Conda Manager${NC}"
    echo -e "Usage: cm ${YELLOW}<name>${NC} [flags]"
    echo ""
    echo -e "Commands:"
    echo -e "  ${YELLOW}<name>${NC}          Activate an existing environment (e.g., 'cm ece438')."
    echo -e "  ${YELLOW}<name>${NC} ${CYAN}--create${NC} Create and activate a new environment (Python 3.12 default)."
    echo -e "  ${CYAN}list${NC}            List environments in $CONDA_ROOT_DIR."
    echo -e "  ${CYAN}--kill${NC}          Deactivate the current session."
    echo -e "  ${CYAN}--help${NC}          Show this help message."
    echo ""
    
    local clist=$(get_cm_list)
    if [ -z "$clist" ]; then
        echo -e "Detected Envs: ${RED}None${NC}"
    else
        # Replace newlines with spaces for a clean single-line list
        local formatted_list=$(echo "$clist" | tr '\n' ' ')
        echo -e "Detected Envs: ${YELLOW}$formatted_list${NC}"
    fi
}

# --- Main Logic ---

if [[ -z "$1" || "$1" == "--help" ]]; then
    show_cm_usage
    return 0
fi

MODE="$1"
FLAG="$2"

if [ ! -d "$CONDA_ROOT_DIR" ]; then
    echo -e "${CYAN}Initializing Conda Root at ${YELLOW}$CONDA_ROOT_DIR${NC}..."
    mkdir -p "$CONDA_ROOT_DIR"
fi

case "$MODE" in
    # List Command
    list)
        echo -e "${B_PURPLE}Available Environments:${NC}"
        get_cm_list
        ;;

    # Kill Command
    --kill)
        # Check if conda is active
        if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
            conda deactivate
            echo -e "${GREEN}Success:${NC} Environment deactivated."
        else
            echo -e "${RED}Error:${NC} No custom environment is currently active (or you are in base)."
            return 1
        fi
        ;;

    # Activate / Create Logic
    *)
        ENV_NAME="$MODE"
        TARGET_DIR="$CONDA_ROOT_DIR/$ENV_NAME"
        
        # --- Creation Phase ---
        if [ "$FLAG" == "--create" ]; then
            if [ -d "$TARGET_DIR" ]; then
                echo -e "${YELLOW}Warning:${NC} '$ENV_NAME' already exists. Activating..."
            else
                echo -e "Creating new conda env: ${CYAN}$ENV_NAME${NC}..."
                
                # Create specifically in the target directory (prefix)
                # Defaults to python 3.12 for stability, change as needed
                conda create --prefix "$TARGET_DIR" python=3.12 -y
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Success:${NC} Environment created."
                    
                    # Optional: Set prompt config so it doesn't show full path
                    # conda config --set env_prompt '({name})' 
                else
                    echo -e "${RED}Error:${NC} Conda creation failed."
                    return 1
                fi
            fi

        elif [ ! -d "$TARGET_DIR" ]; then
            echo -e "${RED}Error:${NC} Environment '${YELLOW}$ENV_NAME${NC}' does not exist."
            echo -e "To create it, run: ${CYAN}cm $MODE --create${NC}"
            return 1
        fi

        echo -e "Activating ${CYAN}$ENV_NAME${NC}..."

        conda activate "$TARGET_DIR"
        ;;
esac
