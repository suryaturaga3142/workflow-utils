#!/bin/bash

# --- Colors ---
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
B_PURPLE='\033[1;35m'
B_RED='\033[1;31m'
B_CYAN='\033[1;36m'

# --- Parse Arguments ---
PROJECT_NAME=""
IS_PRIVATE=0
SHOW_HELP=0

for arg in "$@"
do
    case $arg in
        --help|-h)
            SHOW_HELP=1
            ;;
        --private)
            IS_PRIVATE=1
            ;;
        *)
            PROJECT_NAME="$arg"
            ;;
    esac
done

# --- Display Help and Exit ---
if [ "$SHOW_HELP" -eq 1 ]; then
    echo -e "${B_PURPLE}Breadboard Diaries Project Creator${NC}"
    echo -e "Usage: ./new_project.sh \"${YELLOW}project-name${NC}\" [flags]"
    echo ""
    echo -e "Flags:"
    echo -e "  ${CYAN}--private${NC}    Mark project as private (adds exclusions to .gitignore)."
    echo -e "  ${CYAN}--help${NC}       Show this help message."
    echo ""
    exit 0
fi

# --- Validation ---
if [[ -z "$PROJECT_NAME" ]]; then
    echo -e "${RED}Error:${NC} Missing project name."
    echo -e "Try: ./new_project.sh ${CYAN}--help${NC} for usage instructions."
    exit 1
fi

# --- Calculate Next Project Number ---
# Find the last directory starting with digits (e.g., 05-MyProject)
LAST_NUM=$(ls -d [0-9][0-9]-* 2>/dev/null | sort | tail -n 1 | cut -d'-' -f1)

if [ -z "$LAST_NUM" ]; then
    LAST_NUM=0
fi

# Force base-10 calculation to avoid octal errors (08 vs 8)
NEXT_NUM=$((10#$LAST_NUM + 1))
NEXT_ID=$(printf "%02d" $NEXT_NUM)
FULL_DIR="${NEXT_ID}-${PROJECT_NAME}"

# --- Create Directories ---
echo -e "Initializing Project: ${YELLOW}${FULL_DIR}${NC}"

if [ -d "$FULL_DIR" ]; then
    echo -e "${RED}Error:${NC} Directory ${YELLOW}$FULL_DIR${NC} already exists."
    exit 1
fi

mkdir -p "$FULL_DIR/media"
mkdir -p "$FULL_DIR/schematics"
mkdir -p "$FULL_DIR/simulations"

# --- Create README.md ---
# Convert "my-cool-project" -> "My Cool Project"
TITLE_NAME=$(echo "$PROJECT_NAME" | sed -r 's/-/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

echo "# $TITLE_NAME" > "$FULL_DIR/README.md"
echo "" >> "$FULL_DIR/README.md"
echo "Project description goes here." >> "$FULL_DIR/README.md"

echo -e "  -> Created ${CYAN}README.md${NC}"

# --- Template Configuration ---
TEMPLATE_DIR="/path/to/templates"
KICAD_TEMPLATE="kicad_9.0_basic"
LTSPICE_TEMPLATE="ltspice_basic"

# Paths to Source Templates
KICAD_SRC_DIR="${TEMPLATE_DIR}/${KICAD_TEMPLATE}"
LTSPICE_SRC_FILE="${TEMPLATE_DIR}/${LTSPICE_TEMPLATE}/${LTSPICE_TEMPLATE}.asc"

# --- Copy KiCad Template ---
if [[ -d "$KICAD_SRC_DIR" ]]; then
    # Copy project, schematic, and PCB files, renaming them to match the new project
    cp "${KICAD_SRC_DIR}/${KICAD_TEMPLATE}.kicad_pro" "./${FULL_DIR}/schematics/${PROJECT_NAME}.kicad_pro"
    cp "${KICAD_SRC_DIR}/${KICAD_TEMPLATE}.kicad_sch" "./${FULL_DIR}/schematics/${PROJECT_NAME}.kicad_sch"
    cp "${KICAD_SRC_DIR}/${KICAD_TEMPLATE}.kicad_pcb" "./${FULL_DIR}/schematics/${PROJECT_NAME}.kicad_pcb"
    echo -e "  -> Created ${CYAN}KiCad Project${NC} (from ${YELLOW}$KICAD_TEMPLATE${NC})"
else
    echo -e "  -> ${RED}Warning:${NC} KiCad Template not found at ${YELLOW}$KICAD_SRC_DIR${NC}"
fi

# --- Copy LTSpice Template ---
if [[ -f "$LTSPICE_SRC_FILE" ]]; then
    cp "$LTSPICE_SRC_FILE" "./${FULL_DIR}/simulations/${PROJECT_NAME}.asc"
    echo -e "  -> Created ${CYAN}LTSpice Project${NC}"
else
    echo -e "  -> ${RED}Warning:${NC} LTSpice Template not found at ${YELLOW}$LTSPICE_SRC_FILE${NC}"
fi

# --- Update .gitignore ---
GITIGNORE_FILE=".gitignore"

# Build the rules string
RULES_TO_ADD="# $NEXT_ID $TITLE_NAME\n$FULL_DIR/schematics/*.kicad_pcb"

if [ "$IS_PRIVATE" -eq 1 ]; then
    echo -e "  -> Configuration: ${YELLOW}PRIVATE${NC} (Ignoring schematics & simulations)"
    RULES_TO_ADD="$RULES_TO_ADD\n$FULL_DIR/schematics/*\n$FULL_DIR/simulations/*\n$FULL_DIR/media/*"
fi

# Apply to file (if it exists)
if [ -f "$GITIGNORE_FILE" ]; then
    # Use a temp file to safely write the change
    awk -v rules="$RULES_TO_ADD" '{ print } /# --- AUTOMATIC-PROJECT-RULES-START ---/ { print rules }' "$GITIGNORE_FILE" > "${GITIGNORE_FILE}.tmp" && mv "${GITIGNORE_FILE}.tmp" "$GITIGNORE_FILE"
    echo -e "  -> Updated ${CYAN}.gitignore${NC}"
else
    echo -e "  -> ${RED}Warning:${NC} ${YELLOW}.gitignore${NC} not found. Skipping auto-update."
fi

# --- Exit sequence ---
echo -e "${GREEN}Success!${NC} Project ready at: ${YELLOW}./$FULL_DIR${NC}"
exit 0