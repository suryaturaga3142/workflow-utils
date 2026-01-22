#!/bin/bash
# ~/my_setup.sh

# My account setup script for new Purdue ECN accounts.

# --- SSH Key Generation ---
# Generates ed25519 key if it doesn't exist
KEY_FUNC="account"
KEY_PATH="/path/to/ssh"
if [ ! -f "$KEY_PATH" ]; then
    echo "Generating SSH key..."
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "email" -f "$KEY_PATH" -N ""
    chmod 600 "$KEY_PATH"
else
    echo "SSH Key already exists at $KEY_PATH"
fi

# --- Downloads & Directories ---
# Install git-prompt and vim Gruvbox
echo "Downloading Git Prompt and Gruvbox..."
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
mkdir -p ~/.vim/pack/default/start
if [ ! -d ~/.vim/pack/default/start/gruvbox ]; then
    git clone https://github.com/morhetz/gruvbox.git ~/.vim/pack/default/start/gruvbox
fi

# Create Todo Tree template directory and file
echo "Creating Todo Tree template..."
mkdir -p ~/stuff/templates
cat << 'EOF' > /path/to/todo_basic.json
{
    "todo-tree.regex.regex": "((//|#|%|/\\*|\\s*-\\s*\\[\\s*\\])\\s*($TAGS))",
    
    "todo-tree.general.tags": [
        "BUG",
        "CRITICAL",
        "FIXME",
        "OPTIMIZE", 
        "TODO",
        "HACK",
        "NOTE",
        "REVIEW",
        "XXX"
    ],

    "todo-tree.general.tagGroups": {
        "FIXME": ["FIXME", "FIX", "FIXIT"],
        "NOTE": ["NOTE", "INFO"],
        "OPTIMIZE": ["OPTIMIZE", "PERF", "SPEED"] 
    },

    "todo-tree.highlights.defaultHighlight": {
        "type": "text", 
        "gutterIcon": true, 
        "opacity": 50,
        "borderRadius": "3px"
    },

    "todo-tree.highlights.customHighlight": {
        "BUG": {
            "icon": "bug",
            "background": "#d32f2f",
            "foreground": "#ffffff",
            "iconColour": "#d32f2f",
            "rulerColour": "#d32f2f",
            "rulerLane": "full"
        },
        "CRITICAL": {
            "icon": "alert",
            "background": "#fc4040",
            "foreground": "#ffffff",
            "iconColour": "#fc4040",
            "rulerColour": "#fc4040",
            "rulerLane": "full"
        },

        "FIXME": {
            "icon": "flame",
            "background": "#f57c00",
            "foreground": "#000000",
            "iconColour": "#f57c00",
            "rulerColour": "#f57c00",
            "rulerLane": "right"
        },

        "OPTIMIZE": {
            "icon": "zap",
            "background": "#ffeb3b",
            "foreground": "#000000",
            "iconColour": "#ffeb3b",
            "rulerColour": "#ffeb3b",
            "rulerLane": "right"
        },

        "TODO": {
            "icon": "check",
            "background": "#1976d2",
            "foreground": "#ffffff",
            "iconColour": "#1976d2",
            "rulerColour": "#1976d2",
            "rulerLane": "right"
        },

        "HACK": {
            "icon": "tools",
            "background": "#7b1fa2",
            "foreground": "#ffffff",
            "iconColour": "#7b1fa2"
        },
        "XXX": {
            "icon": "beaker",
            "background": "#924efc",
            "foreground": "#ffffff",
            "iconColour": "#924efc"
        },

        "NOTE": {
            "icon": "note",
            "background": "#388e3c",
            "foreground": "#ffffff",
            "iconColour": "#388e3c"
        },
        "REVIEW": {
            "icon": "eye",
            "background": "#0097a7",
            "foreground": "#ffffff",
            "iconColour": "#0097a7"
        }
    },

    "todo-tree.filtering.excludeGlobs": [
        "**/node_modules/**",
        "**/dist/**",
        "**/build/**",
        "**/work/**",
        "**/__pycache__/**"
    ]
}
EOF

# --- Create .vimrc ---
# Overwrites existing .vimrc
echo "Creating new .vimrc..."
cat << 'EOF' > ~/.vimrc
" ~/.vimrc

" --- General Settings ---
set nocompatible            " Disable vi-compatibility (Must be first)
set encoding=utf8           " Force UTF-8 encoding
filetype plugin indent on   " Enable detection of file types
syntax on                   " Enable syntax highlighting

" --- UI & Visuals ---
set number                  " Show line numbers on the left
set ruler                   " Show cursor position (row, col) at bottom
set cursorline              " Highlight the current line (helps find cursor)
set showcmd                 " Show incomplete commands in status bar
set scrolloff=5             " Keep 5 lines of context above/below cursor when scrolling
set laststatus=2            " Always show the status line
set wildmenu                " Enhanced command-line completion (Tab key menu)

" --- Search Behavior ---
set incsearch               " Highlight matches as you type
set hlsearch                " Keep matches highlighted after searching
set ignorecase              " Ignore case when searching...
set smartcase               " ...unless you type a capital letter

" --- Colors ---
set t_Co=256                " Force 256 colors for Git Bash/Putty
if (has("termguicolors"))
    set termguicolors       " Enable True Color support if available
endif

set background=dark         " Tell vim we are using a dark background
try 
    colorscheme gruvbox
catch
    colorscheme elflord     " Backup if Gruvbox isn't installed
endtry

" --- Indentation & Formatting ---
" Default: 4 spaces, keep indentation from previous line
set tabstop=4               " Visual width of a tab
set shiftwidth=4            " Indentation width
set softtabstop=4           " Edit as if tabs are spaces
set expandtab               " Convert tabs to spaces (Safer default)
set autoindent              " Copy indent from current line when starting new one

" Python: Strict 4 spaces
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4

" C / SystemVerilog: 4 spaces (Tabs vs Spaces preference safe here)
autocmd FileType c,cpp,verilog,systemverilog setlocal tabstop=4 shiftwidth=4 shiftround

" Force .sv files to be detected as SystemVerilog
autocmd BufRead,BufNewFile *.sv set filetype=systemverilog

" --- Safety & Backups (The 'Hidden Drawer' Method) ---
" Prevents backup files (file.c~) from cluttering your actual project folders
let &backupdir=($HOME . '/.vim_backup_files')
if ! isdirectory(&backupdir)
    call mkdir(&backupdir, "", 0700)
endif
set backup
set writebackup

" --- Useful Key Mappings ---
" Set the 'Leader' key to Space (Easier to hit than \)
let mapleader = " "

" Press 'Space + Space' to clear search highlighting (Very useful!)
nnoremap <Leader><Leader> :noh<CR>

" Navigate splits easier (Ctrl+j/k/h/l instead of Ctrl+w+j...)
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
EOF

# --- Append .bash_functions ---
# Appends modified functions to .bash_functions
echo "Appending to .bash_functions..."
cat << EOF >> ~/.bash_functions

# --- Custom Functions ---

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

mkcd() {
    mkdir -p "\$1"
    cd "\$1" || return 1
}

extract() {
    if [ -f "\$1" ] ; then
        echo -e "Extracting \${YELLOW}\$1...\${NC}"
        case "\$1" in
            *.tar.bz2)   tar xjf "\$1"    ;;
            *.tar.gz)    tar xzf "\$1"    ;;
            *.bz2)       bunzip2 "\$1"    ;;
            *.rar)       unrar e "\$1"    ;;
            *.gz)        gunzip "\$1"     ;;
            *.tar)       tar xf "\$1"     ;;
            *.tbz2)      tar xjf "\$1"    ;;
            *.tgz)       tar xzf "\$1"    ;;
            *.zip)       unzip "\$1"      ;;
            *.Z)         uncompress "\$1" ;;
            *.7z)        7z x "\$1"       ;;
            *)           
                echo -e "\${RED}Error:\${NC} '\${YELLOW}\$1\${NC}' cannot be extracted" 
                return 1
                ;;
        esac
        if [ \$? -eq 0 ]; then
            echo -e "\${GREEN}Success!\${NC}"
        fi
    else
        echo -e "\${RED}Error:\${NC} '\${YELLOW}\$1\${NC}' is not a valid file"
        return 1
    fi
}

vimcheat() {
    echo -e "\n\${B_PURPLE}=== VIM CHEAT SHEET (Custom Config) ===\${NC}"

    echo -e "\n\${B_BLUE}--- SPLITS (View multiple files) ---\${NC}"
    echo -e "\${B_CYAN}:vsp filename\${NC}   Vertical Split (Left/Right)"
    echo -e "\${B_CYAN}:sp filename\${NC}    Horizontal Split (Top/Bottom)"
    echo -e "\${B_CYAN}Ctrl + h/j/k/l\${NC}  Navigate splits (Left/Down/Up/Right)"
    echo -e "\${B_CYAN}:q\${NC}              Close current split"

    echo -e "\n\${B_BLUE}--- TABS (Separate Workspaces) ---\${NC}"
    echo -e "\${B_CYAN}:tabnew file\${NC}    Open file in a brand new tab"
    echo -e "\${B_CYAN}gt\${NC}              Go to Next Tab"
    echo -e "\${B_CYAN}gT\${NC}              Go to Previous Tab"

    echo -e "\n\${B_BLUE}--- SEARCHING ---\${NC}"
    echo -e "\${B_CYAN}/word\${NC}           Search forward"
    echo -e "\${B_CYAN}?word\${NC}           Search backward"
    echo -e "\${B_CYAN}n / N\${NC}           Next match / Previous match"
    echo -e "\${B_CYAN}Space Space\${NC}     Clear search highlights (Custom Shortcut)"
    echo ""
}

todocheat () {
    echo -e "\n\${B_PURPLE}=== TODO TREE CHEAT SHEET ===\${NC}"

    echo -e "\n\${B_BLUE}--- LEVEL 1: URGENT / BROKEN ---\${NC}"
    echo -e "\${B_CYAN}BUG\${NC}         Broken functionality, crashes, or known errors."
    echo -e "\${B_CYAN}CRITICAL\${NC}    Severe issues causing data loss or system failure."

    echo -e "\n\${B_BLUE}--- LEVEL 2: NEEDS ATTENTION ---\${NC}"
    echo -e "\${B_CYAN}FIXME\${NC}       Code runs but logic is flawed or incomplete."
    echo -e "\${B_CYAN}OPTIMIZE\${NC}    Performance bottleneck; needs speed/efficiency update."

    echo -e "\n\${B_BLUE}--- LEVEL 3: STANDARD / INFO ---\${NC}"
    echo -e "\${B_CYAN}TODO\${NC}        Standard task or feature to be implemented."
    echo -e "\${B_CYAN}HACK\${NC}        Working but messy solution; technical debt."
    echo -e "\${B_CYAN}NOTE\${NC}        General information or clarification."
    echo -e "\${B_CYAN}REVIEW\${NC}      Code requires a peer review or double-check."
    echo -e "\${B_CYAN}XXX\${NC}         Warning, placeholder, or scary code."
    echo ""
}

sshgit() {
    eval "\$(ssh-agent)" 1>/dev/null
    ssh-add "$KEY_PATH"
}


newtodo() {
    local template="/path/to/todo_basic.json"
    local target_dir=".vscode"
    local target_file="\$target_dir/settings.json"

    if [ ! -f "\$template" ]; then
        echo -e "\${RED}Error: Template not found at \${YELLOW}\$template\${NC}"
        return 1
    fi

    if [ ! -d "\$target_dir" ]; then
        echo -e "\${CYAN}Creating directory \${YELLOW}\$target_dir\${NC}..."
        mkdir -p "\$target_dir"
    fi

    if [ ! -f "\$target_file" ]; then
        echo -e "\${CYAN}Creating new \${YELLOW}\$target_file\${NC} from template..."
        cp "\$template" "\$target_file"
        echo -e "\${GREEN}Success! Todo Tree settings installed.\${NC}"
    else
        echo -e "\${CYAN}Found existing \${YELLOW}\$target_file\${NC}. Injecting settings..."
        # Create backup
        cp "\$target_file" "\${target_file}.bak"
        echo -e "\${CYAN}Backup created at \${YELLOW}\${target_file}.bak\${NC}"
        
        # 1. Remove the last line (the closing '}') of the target file
        sed -i '\$d' "\$target_file"
        # 2. Add a comma to the new last line (to ensure valid JSON syntax)
        #    Note: This assumes the file ends with a property/value.
        sed -i '\$s/\$/,/' "\$target_file"
        # 3. Strip the first line ('{') and last line ('}') from template and append
        sed '1d;\$d' "\$template" >> "\$target_file"
        # 4. Close the main object
        echo -e "\n}" >> "\$target_file"

        echo -e "\${GREEN}Success! Todo Tree settings injected into \${YELLOW}\$target_file\${NC}."
    fi
}
EOF

# --- Append .bash_aliases ---
echo "Appending to .bash_aliases..."
cat << 'EOF' >> ~/.bash_aliases

# --- Custom Additions ---

# --- Escapes for Color ---
# Reset
NC='\033[0m'
# Regular Colors (Use often)
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
# Bold Colors (Brighter/Emphasized)
B_BLACK='\033[1;30m'
B_RED='\033[1;31m'
B_GREEN='\033[1;32m'
B_YELLOW='\033[1;33m'
B_BLUE='\033[1;34m'
B_PURPLE='\033[1;35m'
B_CYAN='\033[1;36m'
B_WHITE='\033[1;37m'
# Background Colors (Use sparingly)
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'

# --- Better Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
# alias -='cd -'

# --- Quality of Life Aliases ---
alias ll='ls -alF --color=auto'  # List all, long format, colored
alias la='ls -A --color=auto'    # List all (hide . and ..)
alias l='ls -CF --color=auto'
alias c='clear'
alias grep='grep --color=auto'   # Highlight search results

# Safety nets (ask before deleting/overwriting)
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# --- Developer Tools (C/C++ & SV) ---
# Default to "Safe Mode" compilation
alias g++='g++ -Wall -Wextra -std=c++17'
alias gcc='gcc -Wall -Wextra'
# Open current folder in VS Code
alias code.='code .'
# To use in python venv
alias pip='py -m pip'

# --- Git Shortcuts ---
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git pull'
alias gh='git push'
alias gl='git log --oneline --graph --decorate --all' # The "Subway Map" view

# --- Custom Functions ---
# Located in ~/.bash_functions
EOF

# --- Append .bashrc ---
echo "Appending to .bashrc..."
cat << 'EOF' >> ~/.bashrc

# --- Custom Config ---

# History
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTIGNORE="ls:ll:la:pwd:exit:clear:history"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s checkwinsize
shopt -s histappend

# Custom PS1 with Git Branch integration
if [ -f ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
fi
if command -v __git_ps1 >/dev/null 2>&1; then
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]: \[\033[01;34m\]\w\[\033[33m\]$(__git_ps1 " (%s)")\[\033[00m\] \$ '
else
    export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]: \[\033[01;34m\]\w\[\033[00m\] \$ '
fi


if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# Vim Mode
set -o vi
set -o noclobber
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# FZF (Disabled by default)
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash
# export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

EOF

echo "Setup Complete!"
echo "Please run source ~/.bashrc (and don't forget about your SSH key!)"