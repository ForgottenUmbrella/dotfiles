" extra/plugins.vim: declares plugins

filetype plugin indent on

" Auto-install
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    if has('win32')
        !mkdir ~/.config/nvim/autoload;
            \ $uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/
            \master/plug.vim';
            \ (New-Object Net.WebClient).DownloadFile(
            \ $uri, $ExecutionContext.SessionState.Path.
            \GetUnresolvedProviderPathFromPSPath(
            \'~\.config\nvim\autoload\plug.vim'))
    else
        !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug
            \/master/plug.vim
        " NOTE: This only gets called once
        augroup plugins
            autocmd!
            autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
        augroup END
    endif
endif


call plug#begin('~/.config/nvim_plugged')


" Visual grepping
Plug 'nathanaelkane/vim-indent-guides'
Plug 'bronson/vim-trailing-whitespace'
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
" XXX
" Plug 'kshenoy/vim-signature'
Plug 'vim-scripts/ShowMarks'
if has('win32')
    Plug 'PProvost/vim-ps1'
endif
Plug 'mileszs/ack.vim'
Plug 'chrisbra/Colorizer'

" Editing
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'ap/vim-you-keep-using-that-word'
Plug 'michaeljsmith/vim-indent-object'
Plug 'romainl/vim-qf'
if !has('win32')
    Plug 'powerman/vim-plugin-viewdoc'
endif
Plug 'airblade/vim-rooter'
Plug 'Ron89/thesaurus_query.vim'
Plug 'vim-scripts/argtextobj.vim'
Plug 'airblade/vim-matchquote'
Plug 'dhruvasagar/vim-table-mode'
Plug 'wellle/visual-split.vim'
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }

" Other
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'junegunn/fzf.vim' | Plug 'junegunn/fzf', {
    \ 'dir': '~/.fzf',
    \ 'do': './install --all' }
if executable('ctags')
    if !has('win32')
        Plug 'ludovicchabant/vim-gutentags'
    endif
else
    echo 'Download ctags.'
endif
Plug 'vimwiki/vimwiki'
Plug 'neomake/neomake', { 'do': ':UpdateRemotePluginsAndKnuckles <Bar>
    \ !pip3 install vim-vint --user; pip3 install pylint --user;
    \ sudo npm install -g eslint; sudo npm install -g write-good' }
Plug 'dojoteef/neomake-autolint'
Plug 'simnalamburt/vim-mundo', { 'on': 'Mundo' }

" Aesthetic
Plug 'lifepillar/vim-solarized8',
    \ { 'dir': '~/.config/nvim/colors/vim-solarized8' }
Plug 'sickill/vim-monokai', { 'dir': '~/.config/nvim/colors/vim-monokai' }
Plug 'mhinz/vim-startify'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'mikewest/vimroom', { 'on': 'VimroomToggle' }

" Neovim
if has('nvim')
    source ~/.config/nvim/extra/nvim/plugins.vim
endif


call plug#end()


if !empty(glob('~/.config/nvim_plugged'))
    source ~/.config/nvim/extra/plugged/functions.vim
    source ~/.config/nvim/extra/plugged/settings.vim
    source ~/.config/nvim/extra/plugged/mappings.vim
    source ~/.config/nvim/extra/plugged/commands.vim
    source ~/.config/nvim/extra/plugged/autocmds.vim
else
    augroup plugins
        autocmd!
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    augroup END
endif
