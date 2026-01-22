#!/bin/bash
# ~/ece40656/scripts/gen_project.sh
#
# Purpose: Create a new Cadence library (project), register it in cds.lib,
#          and attach gpdk045 technology.


set -euo pipefail
source "$(dirname "$0")/config.sh"

PROJECT_NAME="${1:-}"

if [ -z "$PROJECT_NAME" ]; then
    die "No project name provided.
Usage: ./scripts/gen_project.sh <project_name>"
fi

LIB_PATH="$DESIGN_LIBS_DIR/$PROJECT_NAME"
SKILL_SCRIPT="$TMP_DIR/attach_tech_${PROJECT_NAME}.il"
LOG_FILE="$LOGS_DIR/gen_project_${PROJECT_NAME}.log"

mkdir -p "$LOGS_DIR" "$TMP_DIR"

info "Creating project library: $PROJECT_NAME"

[ -f "$CDS_LIB" ] || die "cds.lib not found at project root."

if [ -d "$LIB_PATH" ]; then
    die "Library directory already exists: $LIB_PATH"
fi

if awk '$1=="DEFINE" && $2=="'"$PROJECT_NAME"'" {exit 1}' "$CDS_LIB"; then
    :
else
    die "Library '$PROJECT_NAME' already defined in cds.lib"
fi


mkdir -p "$LIB_PATH"
touch "$LIB_PATH/cdsinfo.tag"

info "Created directory: $LIB_PATH"


echo "DEFINE $PROJECT_NAME $LIB_PATH" >> "$CDS_LIB"
info "Updated cds.lib"

# --- Temp SKILL Script ---

cat > "$SKILL_SCRIPT" <<EOF
;------------------------------------------------------------
; attach_tech_${PROJECT_NAME}.il
;------------------------------------------------------------

procedure( attach_tech(libName techName)
    let( (libObj)
        printf("INFO: Attaching tech library '%s' to design library '%s'...\n" techName libName)
        
        ; 1. Verify the Design Library exists
        libObj = ddGetObj(libName)
        unless(libObj
            error("Design Library not found: %s" libName)
        )

        ; 2. The Golden Command: Set the pointer
        ; This is what "Attach" in the GUI actually does.
        techSetTechLibName(libObj techName)
        
        printf("SUCCESS: Technology attached via pointer.\n")
    )
)

attach_tech("$PROJECT_NAME" "$DEFAULT_TECH_LIB")
exit(0)
EOF


info "Running Virtuoso in batch mode..."
virtuoso -nograph -restore "$SKILL_SCRIPT" > "$LOG_FILE" 2>&1

ok "Project '$PROJECT_NAME' created successfully."
info "Log:  $LOG_FILE"
info "SKILL: $SKILL_SCRIPT"
