" extra/plugged/autocmds.vim: defines autocmds for plugins

augroup plugins
    autocmd!
    " XXX
    " autocmd BufWritePost * if &filetype != 'help' | Neomake | endif
    autocmd VimEnter * colorscheme solarized8_dark
    autocmd VimEnter * AirlineRefresh
    autocmd BufNewFile,BufRead *.ps1,*.psc1 setfiletype ps1
    autocmd BufWritePre *.py FixWhitespace
augroup END
