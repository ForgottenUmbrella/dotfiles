" extra/plugged/settings.vim: sets plugin settings

" Indent guides
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes = [
    \ 'startify', 'terminal', 'help', 'minimap']

" Airline
let g:airline_extensions = [
    \ 'tagbar', 'tabline', 'quickfix', 'wordcount', 'neomake']
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#wordcount#filetype =
    \ 'markdown\|rst\|org\|text\|asciidoc\|tex\|mail\|vimwiki'
let g:airline_powerline_fonts = 1
let g:airline_skip_empty_sections = 0
let g:airline_theme = 'solarized'
let g:airline_detect_paste = 0
let g:airline_detect_spell = 0
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ }
let g:airline_section_b = '%{TruncatedCWD()}'
let g:airline_section_y = '%{LineNoIndicator()}'
let g:airline_section_z = '%2c'
let g:airline#extensions#default#section_truncate_width = {
    \ 'b': 45,
    \ 'x': 79,
    \ 'z': 70,
    \ }

" Neomake Autolint
let g:neomake_autolint_events = {
    \ 'InsertLeave': {},
    \ 'TextChanged': {},
    \ 'BufWinEnter': {},
    \ }
let g:neomake_autolint_sign_column_always = 1

" Neomake
let g:neomake_help_enabled_makers = []

" Vimwiki
let g:vimwiki_list = [{ 'path': glob('~/Dropbox/Wiki'), 'syntax': 'markdown',
    \ 'path_html': glob('~/Dropbox/Wiki/export'), 'ext': '.md' }]
let g:vimwiki_global_ext = 0

" Solarized
let g:solarized_termtrans = 1
let g:solarized_term_italics = 1

" Startify
let g:startify_fortune_use_unicode = 1
let g:ascii = [
    \ '                          _         ',
    \ '   ____  ___  ____ _   __(_)___ ___ ',
    \ '  / __ \/ _ \/ __ \ | / / / __ `__ \',
    \ ' / / / /  __/ /_/ / |/ / / / / / / /',
    \ '/_/ /_/\___/\____/|___/_/_/ /_/ /_/ ',
    \ '                                    ',
    \ ]
let g:startify_custom_header =
    \ 'map(g:ascii + startify#fortune#boxed(), "\"   \" . v:val")'

" NERDTree
let g:NERDTreeMapUpdir = '..'
let g:NERDTreeMapToggleHidden = 'h'

" Trailing Whitespace
let g:extra_whitespace_ignored_filetypes = ['startify', 'terminal', 'help']

" Vimroom
let g:vimroom_sidebar_height = 0
let g:vimroom_width = 79

" Gutentags
let g:gutentags_exclude_project_root = [
    \ '/usr/local', glob('~/.config/nvim/plugged'),
    \ glob('~/.config/nvim/colors')]

" Deoplete
let g:deoplete#enable_at_startup = 1

" ViewDoc
let g:viewdoc_open = 'rightbelow new'
let g:viewdoc_openempty = 0
let g:no_viewdoc_abbrev = 1
let g:ViewDoc_DEFAULT = 'ViewDoc_help'

" Ack
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
else
    echo 'Install ag.'
endif
let g:ackhighlight = 1

" Rooter
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_use_lcd = 1
let g:rooter_silent_chdir = 1

" Mundo
let g:mundo_right = 1

" FZF
let g:fzf_command_prefix = 'FZF'

" Table Mode
let g:table_mode_corner = '|'

" Quickfix
let g:qf_window_bottom = 0
let g:qf_loclist_window_bottom = 0
