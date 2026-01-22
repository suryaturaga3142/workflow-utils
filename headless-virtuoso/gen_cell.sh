#!/bin/bash
# ~/ece40656/scripts/gen_cell.sh
#
# Purpose:
#   Create schematic, symbol, and layout views for a cell
#   inside an existing Cadence library.
#
# Assumptions:
#   - Library already exists
#   - Technology is already attached (via PDK / gen_project)


set -euo pipefail
source "$(dirname "$0")/config.sh"


LIB_NAME="${1:-}"
CELL_NAME="${2:-}"

if [ -z "$LIB_NAME" ] || [ -z "$CELL_NAME" ]; then
    die "Missing arguments.
Usage: ./scripts/gen_cell.sh <lib_name> <cell_name>"
fi

LIB_PATH="$DESIGN_LIBS_DIR/$LIB_NAME"
CELL_PATH="$LIB_PATH/$CELL_NAME"

SKILL_SCRIPT="$TMP_DIR/gen_cell_${LIB_NAME}_${CELL_NAME}.il"
LOG_FILE="$LOGS_DIR/gen_cell_${LIB_NAME}_${CELL_NAME}.log"

mkdir -p "$LOGS_DIR" "$TMP_DIR"

info "Creating cell '$CELL_NAME' in library '$LIB_NAME'"


[ -f "$CDS_LIB" ] || die "cds.lib not found at project root."

if [ ! -d "$LIB_PATH" ]; then
    die "Library directory not found: $LIB_PATH"
fi

if ! awk '$1=="DEFINE" && $2=="'"$LIB_NAME"'" {found=1} END{exit !found}' "$CDS_LIB"; then
    die "Library '$LIB_NAME' not defined in cds.lib"
fi


mkdir -p "$CELL_PATH"

# --- Temp SKILL Script ---

cat > "$SKILL_SCRIPT" <<EOF
;------------------------------------------------------------
; gen_cell_${LIB_NAME}_${CELL_NAME}.il
;------------------------------------------------------------

procedure( create_cell(libName cellName)
    let( (libObj cv)

        printf("INFO: Creating cell %s in %s\\n" cellName libName)

        libObj = ddGetObj(libName)
        unless(libObj
            error("Library not accessible: %s" libName)
        )

        foreach( viewSpec
            list(
                list("schematic" "schematic")
                list("symbol"    "schematicSymbol")
                list("layout"    "maskLayout")
            )

            viewName = car(viewSpec)
            viewType = cadr(viewSpec)

            printf("INFO: Opening %s view...\\n" viewName)

            cv = dbOpenCellViewByType(
                libName
                cellName
                viewName
                viewType
                "a"
            )

            unless(cv
                error("Failed to open/create %s view" viewName)
            )

            dbSave(cv)
            dbClose(cv)
        )

        printf("SUCCESS: Cell created successfully\\n")
    )
)

create_cell("$LIB_NAME" "$CELL_NAME")
exit(0)
EOF


info "Running Virtuoso in batch mode..."
virtuoso -nograph -restore "$SKILL_SCRIPT" > "$LOG_FILE" 2>&1

if grep -q "SUCCESS: Cell created" "$LOG_FILE"; then
    ok "Cell '$CELL_NAME' created successfully."
    info "Log:  $LOG_FILE"
    info "SKILL: $SKILL_SCRIPT"
else
    die "Cell creation failed. See log: $LOG_FILE"
fi
