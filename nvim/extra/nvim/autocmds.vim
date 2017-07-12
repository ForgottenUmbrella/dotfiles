" extra/nvim/autocmds.vim: defines autocmds for neovim

augroup terminal
    autocmd!
    autocmd TermOpen term://* setfiletype terminal
    autocmd TermClose term://* setlocal relativenumber
augroup END
