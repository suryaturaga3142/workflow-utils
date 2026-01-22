#!/bin/bash
# scripts/config.sh
#
# Global configuration shared by all Cadence automation scripts.
# This file must be sourced, never executed directly.

# --- Root & Directory Layout ---

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DESIGN_LIBS_DIR="$PROJECT_ROOT/design_libs"
RESULTS_DIR="$PROJECT_ROOT/results"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
LOGS_DIR="$PROJECT_ROOT/logs"
TMP_DIR="$PROJECT_ROOT/tmp"
SPECS_DIR="$PROJECT_ROOT/specs"

CDS_LIB="$PROJECT_ROOT/cds.lib"

DEFAULT_TECH_LIB="gpdk045"

# --- ANSI Colors ---

COLOR_INFO='\033[0;36m'    # Cyan
COLOR_OK='\033[0;32m'      # Green
COLOR_WARN='\033[0;33m'    # Yellow
COLOR_ERR='\033[0;31m'     # Red
COLOR_RESET='\033[0m'

# --- Helpers ---

die() {
    echo -e "${COLOR_ERR}Error: $1${COLOR_RESET}" >&2
    exit 1
}

info() {
    echo -e "${COLOR_INFO}$1${COLOR_RESET}"
}

ok() {
    echo -e "${COLOR_OK}$1${COLOR_RESET}"
}

warn() {
    echo -e "${COLOR_WARN}$1${COLOR_RESET}"
}
