echo 'Hi from not_init.vim'
finish

" Replaced with neomake
Plug 'scrooloose/syntastic'
Plug 'nvie/vim-flake8'
" Replaced with deoplete because this is heavy and buggy
" NOTE: Remember to install mono-complete, golang, nodejs, npm, rustc
Plug 'Valloric/YouCompleteMe', {
    \'do': './install.py --all; npm install -g typescript' }
" Replaced with vim-monokai
Plug 'tomasr/molokai', { 'dir': '~/.config/nvim/colors/molokai' }
" Replaced with my own, less-buggy simple thing
Plug 'mtth/scratch.vim'
" Replaced because this is annoying
Plug 'Raimondi/delimitMate'
" Unused
Plug 'tpope/vim-fugitive'
" Replaced with Airline tabline
Plug 'bling/vim-bufferline'
" Replaced with tagbar
Plug 'severin-lemaignan/vim-minimap', { 'on': 'MinimapToggle' }
" Replaced with vim-solarized8 because transparency
Plug 'iCyMind/NeoSolarized', { 'dir': '~/.config/nvim/colors/NeoSolarized' }
" Replaced with jwhitley's fork because GitGutter colours
Plug 'altercation/vim-colors-solarized',
" Replaced with all other plugins
Plug 'python-mode/python-mode', { 'for': 'python' }
" Replaced with Colorizer
Plug 'skammer/vim-css-color'
" Replaced with vim-solarized8 for true colour
Plug 'jwhitley/vim-colors-solarized'
    \ { 'dir': '~/.config/nvim/colors/vim-colors-solarized' }
" Replaced with vim-qf
Plug 'yssl/QFEnter'

" Plug Settings
" YouCompleteMe
let g:ycm_autoclose_preview_window_after_completion = 1
if !has('win32')
    let g:ycm_server_python_interpreter = '/usr/bin/python2'
endif
" Solarized
let g:solarized_termcolors=256
" Scratch
let g:scratch_persistence_file = glob('~/.config/nvim/scratch')
let g:scratch_autohide = 1
" Airline
let airline_section_c = '%{@%}'
let airline_section_b = '%{split(PWD(), '/')[-1]}'
let airline_section_z = '%3p%% %#__accent_bold#%{airline_symbols.linenr}%4l%#__restore__#%#__accent_bold#/%L%{airline_symbols.maxlinenr}%#__restore__# :%3v'


" Autocmds
" Apparently unneeded for pymode rope
autocmd BufRead,BufNewFile *.md,*.txt nunmap <C-]>
augroup bufferClose
    autocmd!
    autocmd BufDelete * call QuitIfLastBuffer()
augroup END
function! NumBuffers()
    let l:count = 0
    for l:i in range(1, bufnr('$'))
        if buflisted(l:i) && !empty(bufname(l:i))
            let l:count += 1
        endif
    endfor
    return l:count
endfunction
function! QuitIfLastBuffer()
    if NumBuffers() == 1
        :quit
    endif
endfunction
autocmd VimEnter * Minimap

" Mappings
" Proper scrolling (Replaced since relative number line gets confusing)
nnoremap <silent> j gj
nnoremap <silent> k gk


" Settings
" Removed since hidden buffers are annoying
set hidden
" Aesthetic
colorscheme monokai
" Removed since it breaks on Windows
set termguicolors
" Removed since it's confusing, and replaced with Rooter
set autochdir
" Removed since comemnts get unindented for some reason
set smartindent
