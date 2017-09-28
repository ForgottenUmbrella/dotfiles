" These change everything.
set nocompatible
set encoding=utf-8
let mapleader = "\<Space>"

set runtimepath+=~/.config/nvim

if has('nvim')
    source ~/.config/nvim/extra/nvim/settings.vim
    source ~/.config/nvim/extra/nvim/functions.vim
    source ~/.config/nvim/extra/nvim/mappings.vim
    source ~/.config/nvim/extra/nvim/commands.vim
    source ~/.config/nvim/extra/nvim/autocmds.vim
    " NOTE: nvim/plugins.vim sourced in extra/plugins.vim
endif
source ~/.config/nvim/extra/plugins.vim
