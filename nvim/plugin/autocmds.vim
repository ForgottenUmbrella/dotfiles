" plugin/autocmds.vim: defines autocommands

augroup newlines
    autocmd!
    autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
    autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
augroup END

augroup windoze
    autocmd!
    autocmd BufWritePre * setlocal fileformat=unix
    if has('win32')
        autocmd GuiEnter * simalt ~x
    endif
augroup END

augroup templates
    autocmd!
    autocmd BufNewFile *.*
        \ silent! execute '0r ~/.config/nvim/templates/skeleton.'
        \ . expand('<afile>:e')
    autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=
        \eval(submatch(1))#e
augroup END

augroup stubborn
    autocmd!
    autocmd FileType * setlocal formatoptions=tcqj formatoptions-=ro
augroup END

augroup pep8
    autocmd!
    autocmd CursorMoved,CursorMovedI *
        \ if &filetype == 'python' |
            \ execute 'setlocal textwidth=' . GetPythonTextWidth() |
        \ endif
augroup END
