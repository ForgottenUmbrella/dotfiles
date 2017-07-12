" plugin/settings.vim: defines settings

" Aesthetic
syntax enable
set title
set background=dark
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,
    \r-cr:hor20-Cursor/lCursor
if !has('win32')
    set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" Buffers
set splitbelow
set splitright
set noequalalways

" Commands
set showcmd
set wildmenu
set wildmode=list:longest,full
let &wildcharm = &wildchar
set wildignorecase
set ttimeout
set ttimeoutlen=10
set noshowmode
if !has('win32')
    set shell=zsh
else
    " XXX
    " set shell=powershell
    set shellslash
endif

" Completion
set completeopt=longest,menuone

" Editing
set backspace=indent,eol,start
set comments+=fb:*,b:#
set formatoptions=tcqj
set clipboard=unnamedplus

" Files
set fileformats=unix,dos
if has('win32')
    let $TMP = "C:/tmp"
endif

" Folding
set foldmethod=syntax
set foldlevel=99

" Indentation
set expandtab
set shiftround
set autoindent
set smarttab
set shiftwidth=4
set softtabstop=4
let g:vim_indent_cont = &shiftwidth

" Lines
set cursorline
set number
set relativenumber
set nojoinspaces
set list
set listchars=tab:>\ ,trail:-,nbsp:+
set textwidth=79
set colorcolumn=+1
set scrolloff=1

" Terminal
set mouse=a

" Searching
set showmatch
set hlsearch
set ignorecase
set smartcase
set incsearch
set gdefault

" Spelling
set spell
set spelllang=en_au
set complete+=kspell
set thesaurus=~/.config/nvim/thesaurus/mthesaur.txt

" Statusline
set laststatus=2

" Tags
set tags=./tags;,tags
set omnifunc=syntaxcomplete#Complete

" Undo
set undofile
set undodir=~/.config/nvim/undo
