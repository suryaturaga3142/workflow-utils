#!/bin/bash
# ~/.bash_functions

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Make Directory and Change into it
mkcd() {
    mkdir -p "$1"
    cd "$1" || return 1
}

# Switch to win
cdwin() {
    cd "$WIN" || return 1
}

# Universal Extractor
extract() {
    if [ -f "$1" ] ; then
        echo -e "Extracting ${YELLOW}$1${NC}..."
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar e "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           
                echo -e "${RED}Error:${NC} '${YELLOW}$1${NC}' cannot be extracted via extract()" 
                return 1
                ;;
        esac
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Success!${NC}"
        fi
    else
        echo -e "${RED}Error:${NC} '${YELLOW}$1${NC}' is not a valid file"
        return 1
    fi
}

# --- Extra Additions ---

# Vim cheat sheet
vimcheat() {
    echo -e "\n${B_PURPLE}=== VIM CHEAT SHEET ===${NC}"

    echo -e "\n${B_BLUE}--- GLOBAL KEYS ---${NC}"
    echo -e "${B_CYAN}Leader${NC}           Space"
    echo -e "${B_CYAN}Ctrl-h/j/k/l${NC}     Navigate splits (Vim + Tmux aware)"

    echo -e "\n${B_BLUE}--- SPLITS ---${NC}"
    echo -e "${B_CYAN}:vsp file${NC}        Vertical split (Right)"
    echo -e "${B_CYAN}:sp file${NC}         Horizontal split (Down)"
    echo -e "${B_CYAN}Leader + |${NC}       Vertical split (current buffer)"
    echo -e "${B_CYAN}Leader + _${NC}       Horizontal split (current buffer)"
    echo -e "${B_CYAN}Leader + =${NC}       Equalize split sizes"
    echo -e "${B_CYAN}Ctrl - Arrows${NC}    Resize splits"
    echo -e "${B_CYAN}Ctrl-w + H/J/K/L${NC} Rearrange splits"

    echo -e "\n${B_BLUE}--- TABS ---${NC}"
    echo -e "${B_CYAN}Leader + tn${NC}      New tab"
    echo -e "${B_CYAN}Leader + h / l${NC}   Previous / Next tab"
    echo -e "${B_CYAN}Leader + 1..9${NC}    Jump to tab N"
    echo -e "${B_CYAN}Leader + th / tl${NC} Move tab left / right"

    echo -e "\n${B_BLUE}--- SEARCH ---${NC}"
    echo -e "${B_CYAN}/word${NC}            Forward search"
    echo -e "${B_CYAN}?word${NC}            Backward search"
    echo -e "${B_CYAN}n / N${NC}            Next / Previous match"
    echo -e "${B_CYAN}Leader + Leader${NC}  Clear highlights"

    echo ""
}

# tmux cheat sheet
tmuxcheat() {
    echo -e "\n${B_PURPLE}=== TMUX CHEAT SHEET ===${NC}"

    echo -e "\n${B_BLUE}--- GLOBAL KEYS ---${NC}"
    echo -e "${B_CYAN}Prefix${NC}           Ctrl-a"
    echo -e "${B_CYAN}Ctrl-h/j/k/l${NC}     Navigate panes (Vim aware)"
    echo -e "${B_CYAN}Prefix + Ctrl-l${NC}  Clear screen"

    echo -e "\n${B_BLUE}--- PANES ---${NC}"
    echo -e "${B_CYAN}Prefix + |${NC}       Vertical split (side-by-side)"
    echo -e "${B_CYAN}Prefix + -${NC}       Horizontal split (stacked)"
    echo -e "${B_CYAN}Prefix + Arrows${NC}  Resize pane (holdable)"
    echo -e "${B_CYAN}Prefix + H/J/K/L${NC} Rearrange pane"

    echo -e "\n${B_BLUE}--- WINDOWS ---${NC}"
    echo -e "${B_CYAN}Prefix + c${NC}       New window"
    echo -e "${B_CYAN}Prefix + h / l${NC}   Previous / Next window"
    echo -e "${B_CYAN}Prefix + < / >${NC}   Move window left / right"

    echo -e "\n${B_BLUE}--- QUALITY OF LIFE ---${NC}"
    echo -e "${B_CYAN}Mouse${NC}            Enabled (pane resize / scroll)"
    echo -e "${B_CYAN}Indexing${NC}         Windows & panes start at 1"

    echo ""
}

# TODO tree cheat sheet
todocheat () {
    echo -e "\n${B_PURPLE}=== TODO TREE CHEAT SHEET ===${NC}"

    echo -e "\n${B_BLUE}--- LEVEL 1: URGENT / BROKEN ---${NC}"
    echo -e "${B_CYAN}BUG${NC}         Broken functionality, crashes, or known errors."
    echo -e "${B_CYAN}CRITICAL${NC}    Severe issues causing data loss or system failure."

    echo -e "\n${B_BLUE}--- LEVEL 2: NEEDS ATTENTION ---${NC}"
    echo -e "${B_CYAN}FIXME${NC}       Code runs but logic is flawed or incomplete."
    echo -e "${B_CYAN}OPTIMIZE${NC}    Performance bottleneck; needs speed/efficiency update."

    echo -e "\n${B_BLUE}--- LEVEL 3: STANDARD / INFO ---${NC}"
    echo -e "${B_CYAN}TODO${NC}        Standard task or feature to be implemented."
    echo -e "${B_CYAN}HACK${NC}        Working but messy solution; technical debt."
    echo -e "${B_CYAN}NOTE${NC}        General information or clarification."
    echo -e "${B_CYAN}REVIEW${NC}      Code requires a peer review or double-check."
    echo -e "${B_CYAN}XXX${NC}         Warning, placeholder, or scary code."
    echo ""
}

# Login ssh
sshgit() {
    eval "$(ssh-agent)" 1>/dev/null
    ssh-add "${HOME}/.ssh/github_ed25519"
}

# Helper functions for Purdue accounts
sudef() {
    echo -e "${CYAN}Logging in to default account via SSH...${NC}"
    ssh turagas_ececomp
}
su337() {
    echo -e "${CYAN}Logging in to ECE33700 account via SSH...${NC}"
    ssh 337mg_ececomp
}
su406() {
    echo -e "${CYAN}Logging in to ECE40656 account via SSH...${NC}"
    ssh ee455p_ececomp
}
su437() {
    echo -e "${YELLOW}Note:${NC} Full functionality will need RHEL server."
    echo -e "${CYAN}Logging in to ECE43700 account via SSH...${NC}"
    ssh 437mg_ececomp
}
suhelp() {
    echo -e "\n${B_PURPLE}=== PURDUE ACCOUNTS CHEAT SHEET ===${NC}"
    echo -e "   ${B_CYAN}sudef${NC}         Purdue      turagas"
    echo -e "   ${B_CYAN}su337${NC}         ECE33700    337mg300"
    echo -e "   ${B_CYAN}su406${NC}         ECE40656    ee455p25"
    echo -e "   ${B_CYAN}su437${NC}         ECE43700    437mg105"
    echo ""
}

# Activate condas
# Sourced script.
cm () {
    local script_path="$HOME/stuff/condas/conda_manager.sh"
    if [ -f "$script_path" ]; then
        . "$script_path" "$@"
    else
        echo -e "${RED}Error:${NC} Venv Manager not found at ${YELLOW}$script_path${NC}"
        return 1
    fi
}

# Add todo tree settings
newtodo() {
    local template="$HOME/stuff/templates/todo_basic.json"
    local target_dir=".vscode"
    local target_file="$target_dir/settings.json"

    if [ ! -f "$template" ]; then
        echo -e "${RED}Error: Template not found at ${YELLOW}$template${NC}"
        return 1
    fi

    if [ ! -d "$target_dir" ]; then
        echo -e "${CYAN}Creating directory ${YELLOW}$target_dir${NC}..."
        mkdir -p "$target_dir"
    fi

    if [ ! -f "$target_file" ]; then
        echo -e "${CYAN}Creating new ${YELLOW}$target_file${NC} from template..."
        cp "$template" "$target_file"
        echo -e "${GREEN}Success! Todo Tree settings installed.${NC}"
    else
        echo -e "${CYAN}Found existing ${YELLOW}$target_file${NC}. Injecting settings..."
        # Create backup
        cp "$target_file" "${target_file}.bak"
        echo -e "${CYAN}Backup created at ${YELLOW}${target_file}.bak${NC}"
        
        # Remove the last line (the closing '}') of the target file
        sed -i '$d' "$target_file"
        # Add a comma to the new last line (to ensure valid JSON syntax)
        # Note: This assumes the file ends with a property/value.
        sed -i '$s/$/,/' "$target_file"
        # Strip the first line ('{') and last line ('}') from template and append
        sed '1d;$d' "$template" >> "$target_file"
        # Close the main object
        echo -e "\n}" >> "$target_file"

        echo -e "${GREEN}Success! Todo Tree settings injected into ${YELLOW}$target_file${NC}."
    fi
}

# Setup tmux workspace
mytmux () {
    local session="work"
    local tab0="def"
    local mtabs=("alt" "mon" "syn")
    if [ -n "$TMUX" ]; then
        echo "Already in a tmux session. Detach and try again."
        return 1
    fi
    if tmux has-session -t $session 2>/dev/null; then
        tmux attach -t $session
        return 0
    fi
    tmux new-session -d -s $session -n $tab0
    for tab_name in ${mtabs[@]}; do
        tmux new-window -t $session -n $tab_name
    done
    tmux attach -t "$session:$tab0"
}

