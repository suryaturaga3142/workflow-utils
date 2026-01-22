#!/bin/bash

# This is sourced

# --- Color Configuration ---
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
B_PURPLE='\033[1;35m'

VENV_ROOT_DIR="/path/to/venvs"

# --- Helper Functions ---

# Get list of venvs
function get_venv_list {
    # Check if dir exists first to avoid ls errors
    if [ -d "$VENV_ROOT_DIR" ]; then
        # Find directories starting with venv-, get basename, remove 'venv-' prefix
        ls -d "$VENV_ROOT_DIR"/venv-*/ 2>/dev/null | xargs -n 1 basename | sed 's/^venv-//'
    fi
}

function show_usage {
    echo -e "${B_PURPLE}Python Venv Manager${NC}"
    echo -e "Usage: vm ${YELLOW}<name>${NC} [flags]"
    echo ""
    echo -e "Commands:"
    echo -e "  ${YELLOW}<name>${NC}          Activate an existing venv (e.g., 'vm work')."
    echo -e "  ${YELLOW}<name>${NC} ${CYAN}--create${NC} Create and activate a new venv."
    echo -e "  ${CYAN}list${NC}            List all available venvs."
    echo -e "  ${CYAN}--kill${NC}          Deactivate the current session."
    echo -e "  ${CYAN}--help${NC}          Show this help message."
    echo ""
    
    local vlist=$(get_venv_list)
    if [ -z "$vlist" ]; then
        echo -e "Detected Venvs: ${RED}None${NC}"
    else
        # Replace newlines with spaces for a clean single-line list
        local formatted_list=$(echo "$vlist" | tr '\n' ' ')
        echo -e "Detected Venvs: ${YELLOW}$formatted_list${NC}"
    fi
}

# --- Main Logic ---

# Check for Help or Empty Args
if [[ -z "$1" || "$1" == "--help" ]]; then
    show_usage
    return 0
fi

MODE="$1"
FLAG="$2"

# Ensure root dir exists
if [ ! -d "$VENV_ROOT_DIR" ]; then
    echo -e "${CYAN}Initializing Venv Root at ${YELLOW}$VENV_ROOT_DIR${NC}..."
    mkdir -p "$VENV_ROOT_DIR"
fi

case "$MODE" in
    # List Command
    list)
        echo -e "${B_PURPLE}Available Virtual Environments:${NC}"
        get_venv_list
        ;;

    # Kill Command
    --kill)
        # Check if 'deactivate' function exists in shell
        if type deactivate >/dev/null 2>&1; then
            deactivate
            echo -e "${GREEN}Success:${NC} Environment deactivated."
        else
            echo -e "${RED}Error:${NC} No virtual environment is currently active."
            return 1
        fi
        ;;

    # Activate / Create Logic
    *)
        # Internal naming convention: venv-lab1
        ENV_NAME="venv-$MODE"
        TARGET_DIR="$VENV_ROOT_DIR/$ENV_NAME"
        
        # --- Creation Phase ---
        if [ "$FLAG" == "--create" ]; then
            if [ -d "$TARGET_DIR" ]; then
                echo -e "${YELLOW}Warning:${NC} '$ENV_NAME' already exists. Activating..."
            else
                echo -e "Creating new venv: ${CYAN}$ENV_NAME${NC}..."
                # Try 'py' alias first, fall back to 'python3'
                if type py >/dev/null 2>&1; then
                    py -m venv "$TARGET_DIR"
                else
                    python3 -m venv "$TARGET_DIR"
                fi
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Success:${NC} Venv created."
                else
                    echo -e "${RED}Error:${NC} Python creation failed."
                    return 1
                fi
            fi

        # --- Check Existence (if not creating) ---
        elif [ ! -d "$TARGET_DIR" ]; then
            echo -e "${RED}Error:${NC} Venv '${YELLOW}$ENV_NAME${NC}' does not exist."
            echo -e "To create it, run: ${CYAN}vm $MODE --create${NC}"
            return 1
        fi

        # --- Activation Phase ---
        # Robust Path Checking: Support both Windows (Scripts) and Linux (bin)
        if [ -f "$TARGET_DIR/Scripts/activate" ]; then
            ACTIVATE_SCRIPT="$TARGET_DIR/Scripts/activate"
        elif [ -f "$TARGET_DIR/bin/activate" ]; then
            ACTIVATE_SCRIPT="$TARGET_DIR/bin/activate"
        else
            echo -e "${RED}Error:${NC} Venv folder exists, but cannot find activation script."
            echo -e "Checked: ${YELLOW}$TARGET_DIR/Scripts${NC} and ${YELLOW}$TARGET_DIR/bin${NC}"
            return 1
        fi

        echo -e "Activating ${CYAN}$ENV_NAME${NC}..."
        source "$ACTIVATE_SCRIPT"
        ;;
esac
