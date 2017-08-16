" plugin/mappings.vim: defines keyboard mappings/bindings

" Buffers
nnoremap <Leader>b :buffers<CR>:b

" Search
noremap <C-l> :Refresh<CR>
nnoremap <Leader>. \(\.\|?\|!\)\(\s\|\n\)\@=<CR><C-o>

" System clipboard
noremap =y "+y
noremap =p "+p
noremap =P "+P
noremap =d "+d
noremap =x "+x

" Void
noremap -d "_d

" Yanking
nnoremap Y y$

" Get help
nnoremap <S-F1> :call FHelp()<CR>
if has('win32')
    nnoremap K :execute ":help" expand("<cword>")<CR>
endif

" Windows
for s:char in split('hjklHJKL=Tqsv+-<>_]fwW', '\zs')
    execute 'noremap <A-' . s:char . '> <C-w>' . s:char
endfor
noremap <A-Q> :quit!<CR>
noremap <A-n> :new<Space>
noremap <A-N> :vnew<Space>
noremap <A-F> :vsplit <cfile><CR>

" Formatting
noremap gW gwip

" Files
nnoremap <Leader>o :browse oldfiles<CR>
nnoremap <Leader>e :edit<Space>
nnoremap <Leader>E :edit! <Space>
nnoremap <Leader>u :update<CR>
nnoremap <Leader>W :write!<CR>

" Scratch
nnoremap <F8> :call ScratchOpen()<CR>
nnoremap <S-F8> :call ScratchClose()<CR>

" Movement
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <expr> / wildmenumode() ? '<BS>/' : '/'
nnoremap <silent> <C-]> :try <Bar>
    \ execute 'tag' expand('<cword>') <Bar>
    \ catch <Bar>
    \ execute 'silent! /' . expand('<cword>') . '\(\s\{-}=\s{-}\)\@=' <Bar>
    \ endtry <CR>


" F- key extension
for i in range(1, 12)
    execute 'map <F' . (i + 12) . '> <S-F' . i . '>'
endfor

" Sessions
nnoremap <F10> :mksession! ~/.config/nvim/sessions/<Tab>
nnoremap <S-F10> :source ~/.config/nvim/sessions/<Tab>

" Undo
nnoremap U <C-r>

" Indentation
vnoremap > >gv
vnoremap < <gv
inoremap <silent><expr> <CR> RemoveEmptyIndentOrClosePopup()


" Spelling
nnoremap z1 1z=

" Macros
nnoremap Q @q

" Re-indent lists with new bullets
nnoremap <Leader>j Jxxs<CR><Esc>

" Completion
inoremap <expr> <Tab> pumvisible() ? '<C-n>' : '<Tab>'
inoremap <expr> <S-Tab> pumvisible() ? '<C-p>' : '<S-Tab>'
