" ~/.vimrc

" --- Plugins ---
call plug#begin('~/.vim/plugged')
Plug 'christoomey/vim-tmux-navigator'
Plug 'morhetz/gruvbox'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

" --- General Settings ---
set nocompatible            " Disable vi-compatibility
set encoding=utf8           " Force UTF-8
filetype plugin indent on   " Enable filetype detection
syntax on                   " Enable syntax highlighting

" --- UI & Visuals ---
set number                  " Show line numbers
set ruler                   " Show cursor position
set cursorline              " Highlight current line
set showcmd                 " Show incomplete commands
set scrolloff=5             " Keep 5 lines context when scrolling
set laststatus=2            " Always show status line
set wildmenu                " Enhanced command completion
set splitbelow              " New horizontal splits go down
set splitright              " New vertical splits go right

" --- Search Behavior ---
set incsearch               " Highlight as you type
set hlsearch                " Keep matches highlighted
set ignorecase              " Ignore case...
set smartcase               " ...unless capital letter used

" --- Colors ---
set t_Co=256
if (has("termguicolors"))
    set termguicolors
endif

set background=dark
try
    colorscheme gruvbox
catch
    colorscheme elflord
endtry

" --- Indentation & Formatting ---
set tabstop=4               " Visual width of tab
set shiftwidth=4            " Indent width
set softtabstop=4           " Edit as if tabs are spaces
set expandtab               " Tabs -> Spaces
set autoindent              " Copy indent from previous line

" Language Specifics
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4
autocmd FileType c,cpp,verilog,systemverilog setlocal tabstop=4 shiftwidth=4 shiftround
autocmd BufRead,BufNewFile *.sv set filetype=systemverilog

" --- Backup Management ---
" Prevents cluttering project folders with swp/backup files
let &backupdir=($HOME . '/.vim_backup_files')
if ! isdirectory(&backupdir)
    call mkdir(&backupdir, "", 0700)
endif
set backup
set writebackup

" --- Key Mappings ---

" Define Leader Key (Space)
let mapleader = " "

" Navigation (Vim + Tmux)
" Uses Ctrl + h/j/k/l to move between Vim splits AND Tmux panes
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>

" Resizing Splits (Ctrl + Arrow Keys)
" We use 3 'greater/less than' signs to resize faster per press
nnoremap <silent> <C-Left> :vertical resize -3<CR>
nnoremap <silent> <C-Right> :vertical resize +3<CR>
nnoremap <silent> <C-Up> :resize +3<CR>
nnoremap <silent> <C-Down> :resize -3<CR>

" Doesn't work bc of tab movement for now.
" Rearranging Splits (Ctrl + H/J/K/L)
"nnoremap <silent> <leader>H <C-w>H
"nnoremap <silent> <leader>J <C-w>J
"nnoremap <silent> <leader>K <C-w>K
"nnoremap <silent> <leader>L <C-w>L

" Vim Tab Management
" Space + tn = New Tab
nnoremap <leader>tn :tabnew<CR>

" Space + h/l = Previous/Next Tab
nnoremap <leader>h :tabprevious<CR>
nnoremap <leader>l :tabnext<CR>

" Space + number = Go to specific Tab
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt

" Space + th/tl = Move the actual tab position left/right
nnoremap <leader>th :tabmove -1<CR>
nnoremap <leader>tl :tabmove +1<CR>

" Utilities
" Space + Space = Clear search highlighting
nnoremap <leader><leader> :noh<CR>

" Split shortcuts (Space + | or _ or =)
nnoremap <leader><Bar> <C-W><Bar>
nnoremap <leader>_ <C-W>_
nnoremap <leader>= <C-W>=

" Fuzzy finder keymaps
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fg :Rg<CR>
