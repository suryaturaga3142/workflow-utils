#!/bin/bash
# scripts/place_parts.sh
#
# Place schematic parts from a CSV with explicit mode and library control.

set -euo pipefail
source "$(dirname "$0")/config.sh"

LIB_NAME="${1:-}"
CELL_NAME="${2:-}"
CSV_NAME="${3:-}"

[ -z "$LIB_NAME" ] || [ -z "$CELL_NAME" ] || [ -z "$CSV_NAME" ] && \
    die "Insufficent arguments.
    Usage: ./scripts/place_parts.sh <lib_name> <cell_name> <parts_csv_name>"

CELL_PATH="$DESIGN_LIBS_DIR/$LIB_NAME/$CELL_NAME"
CSV_FILE="$SPECS_DIR/$CSV_NAME"

[ -f "$CDS_LIB" ] || die "cds.lib not found"
[ -d "$CELL_PATH" ] || die "Cell not found: $LIB_NAME/$CELL_NAME"
[ -f "$CSV_FILE" ] || {
    warn "CSV file missing. Nothing to place."
    exit 0
}

INVALID_ROWS=$(awk -F, 'NF!=6 {print NR}' "$CSV_FILE")
if [ ! -z "$INVALID_ROWS" ]; then
    die "Error: CSV file has rows with missing fields (must be 6 fields per row).
    Format: component,techlib,orientation,x,y,count
    Bad rows: \n$INVALID_ROWS"
    exit 1
fi

mkdir -p "$LOGS_DIR" "$TMP_DIR"

SKILL_SCRIPT="$TMP_DIR/place_parts_${LIB_NAME}_${CELL_NAME}.il"
LOG_FILE="$LOGS_DIR/place_parts_${LIB_NAME}_${CELL_NAME}.log"

info "Placing parts into $LIB_NAME/$CELL_NAME"

cat > "$SKILL_SCRIPT" <<'EOF'
;------------------------------------------------------------
; place_parts.il
; CSV format: part,lib,orient,x,y,count
;------------------------------------------------------------

procedure( place_parts(libName cellName csvFile)
    ; Use prog to allow 'return' and safer scoping
    prog( (cv fp line vals part lib orient x y instCount master instName orientSKILL spacing partCounts pIdx key i)
        
        spacing    = 1.0
        partCounts = makeTable('partCounts 0) ; Default value 0

        printf("INFO: Opening schematic %s/%s\n" libName cellName)
        cv = dbOpenCellViewByType(libName cellName "schematic" "schematic" "a")
        unless(cv
            printf("ERROR: Cannot open schematic %s/%s\n" libName cellName)
            return(nil)
        )

        fp = infile(csvFile)
        unless(fp
            printf("ERROR: Cannot open CSV file %s\n" csvFile)
            dbClose(cv)
            return(nil)
        )

        while(gets(line fp)
            when(strlen(line) > 1 
                vals = parseString(line ",")
                
                if(length(vals) < 6 then
                    printf("WARNING: Skipping invalid line: %s\n" line)
                else
                    part      = nth(0 vals)
                    lib       = nth(1 vals)
                    orient    = nth(2 vals)
                    x         = atof(nth(3 vals))
                    y         = atof(nth(4 vals))
                    instCount = atoi(nth(5 vals))

                    orientSKILL = case(orient
                        ("N"  "R0") ("E"  "R90") ("S"  "R180") ("W"  "R270")
                        ("MN" "MY") ("MS" "MYR180") ("ME" "MYR90") ("MW" "MYR270")
                        (t "R0")
                    )

                    master = dbOpenCellViewByType(lib part "symbol" "" "r")
                    if( !master then
                        printf("WARNING: Component %s/%s not found. Skipping.\n" lib part)
                    else
                        ; --- Index Logic ---
                        key  = strcat(lib ":" part)
                        pIdx = partCounts[key] 
                        if(pIdx == 0 then pIdx = 1)

                        ; --- Placement Logic ---
                        for(i 0 instCount-1
                            instName = sprintf(nil "%s_%d" part pIdx)
                            dbCreateInst(cv master instName list((x + i*spacing) y) orientSKILL)
                            pIdx = pIdx + 1
                        )
                        
                        ; Update Table
                        partCounts[key] = pIdx
                    ) 
                ) 
            ) 
        ) 

        close(fp)
        dbSave(cv)
        dbClose(cv)
        printf("SUCCESS: Placement complete.\n")
        return(t)
    )
)
EOF

echo "place_parts(\"$LIB_NAME\" \"$CELL_NAME\" \"$CSV_FILE\")" >> "$SKILL_SCRIPT"
echo "exit(0)" >> "$SKILL_SCRIPT"

info "Running Virtuoso in batch mode..."
virtuoso -nograph -restore "$SKILL_SCRIPT" > "$LOG_FILE" 2>&1

grep -q "SUCCESS" "$LOG_FILE" \
    && ok "Parts placed successfully" \
    || die "Placement failed. See $LOG_FILE"
