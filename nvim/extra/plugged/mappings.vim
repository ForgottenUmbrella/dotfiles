" extra/plugged/mappings.vim: defines keyboard mappings for plugins

" NERDTree
nnoremap <F2> :NERDTreeFocus<CR>
nnoremap <S-F2> :NERDTreeClose<CR>

" Yankstack
call yankstack#setup()
nnoremap <Leader>p <Plug>yankstack_substitute_older_paste
nnoremap <Leader>P <Plug>yankstack_substitute_newer_paste

" ViewDoc
if !has('win32')
    cnoreabbrev <expr> h
        \ getcmdtype() == ':' && getcmdline() == 'h' ? GetDocCommand(1) : 'h'
endif

" FZF
nnoremap <F3> :FZF ~<CR>
nnoremap <S-F3> :FZF<CR>

" Solarized
if exists(':SolarizedOptions')
    call togglebg#map('<S-F4>')
else
    nnoremap <S-F4>
        \ :if g:colors_name == 'solarized8_dark' <Bar>
            \ colorscheme solarized8_light <Bar>
        \ elseif g:colors_name == 'solarized8_light' <Bar>
            \ colorscheme solarized8_dark <Bar>
        \ endif <CR>
endif

" Tagbar
nnoremap <F9> :TagbarOpen<CR>
nnoremap <S-F9> :TagbarClose<CR>

" Colorizer
nnoremap <F6> :ColorToggle<CR>

" Mundo
nnoremap <F5> :MundoShow<CR>
nnoremap <S-F5> :MundoHide<CR>
