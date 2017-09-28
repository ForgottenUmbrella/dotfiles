" extra/nvim/plugins.vim: declares plugins for Neovim

" Other
Plug 'vimlab/split-term.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/neco-syntax'
    Plug 'Shougo/neco-vim'
    Plug 'zchee/deoplete-jedi', { 'do': 'pip3 install jedi --user' }
    Plug 'carlitux/deoplete-ternjs', { 'do': 'sudo npm install -g ternjs' }
