#!/bin/bash
# scripts/gen_tb.sh
#
# Purpose:
#   Orchestrates the creation of a testbench cell.
#   Does not use any temp SKILL scripts. 
#   It's a clever use of gen_project.sh and place_parts.sh 
#   to make a testbench and populate it with the DUT.

set -euo pipefail
source "$(dirname "$0")/config.sh"

LIB_NAME="${1:-}"
DUT_NAME="${2:-}"

if [ -z "$LIB_NAME" ] || [ -z "$DUT_NAME" ]; then
    die "Insufficient arguments.
    Usage: ./scripts/gen_tb.sh <lib_name> <dut_cell_name>"
fi

TB_CELL_NAME="tb_${DUT_NAME}"
DUT_SYMBOL_PATH="$DESIGN_LIBS_DIR/$LIB_NAME/$DUT_NAME/symbol"
TEMPLATE_CSV="$SPECS_DIR/default_tb_parts.csv"

[ -f "$CDS_LIB" ] || die "cds.lib not found."

if [ ! -d "$DUT_SYMBOL_PATH" ]; then
    die "Prerequisite missing: Symbol for '$DUT_NAME' not found in '$LIB_NAME'.
    You must generate the symbol for the DUT before creating its testbench."
fi

if [ ! -f "$TEMPLATE_CSV" ]; then
    die "Template missing: $TEMPLATE_CSV not found."
fi

info "Initializing Testbench Generation for: $DUT_NAME"

# Using gen_cell.sh for generation
"$SCRIPTS_DIR/gen_cell.sh" "$LIB_NAME" "$TB_CELL_NAME"

DEST_CSV="gen/${DUT_NAME}_default_tb_parts.csv"
DEST_CSV_PATH="$SPECS_DIR/$DEST_CSV"

echo ""
info "Constructing parts list..."

mkdir -p "$SPECS_DIR/gen"

# Append the DUT to the CSV
# Format: part,lib,orient,x,y,count
cp "$TEMPLATE_CSV" "$DEST_CSV_PATH"
echo "$DUT_NAME,$LIB_NAME,N,0,0,1" >> "$DEST_CSV_PATH"

info "Added DUT '$DUT_NAME' to placement list."

# Use place_parts.sh to handle.
"$SCRIPTS_DIR/place_parts.sh" "$LIB_NAME" "$TB_CELL_NAME" "$DEST_CSV"

ok "Testbench '$TB_CELL_NAME' generated and populated successfully."