" extra/plugged/functions.vim: defines functions for plugins

function! ToggleColours()
    if exists('g:colors_name') && g:colors_name ==# 'monokai'
        set background=dark
        colorscheme solarized8_dark
        AirlineTheme solarized
    else
        colorscheme monokai
        AirlineTheme molokai
    endif
endfunction


function! IDEOpen()
    ScratchOpen
    Minimap
    NERDTree
    TagbarOpen
endfunction

function! IDEClose()
    ScratchClose
    MinimapClose
    NERDTreeClose
    TagbarClose
endfunction

function! IDEToggle()
    let open_ide_windows = 0
    let ide_windows =
        \ ['NERDTree', 'Minimap', 'Tagbar', 'term']
    for window in ide_windows
        if len(WindowMatchList(window))
            let open_ide_windows += 1
        endif
    endfor
    if open_ide_windows >= len(ide_windows)
        call IDEClose()
    else
        call IDEOpen()
    endif
endfunction

function! PRefresh()
    AirlineRefresh
    call Refresh()
endfunction

function! GetDocCommand(bang)
    let commands = {
        \ 'go': 'Go',
        \ 'godoc': 'Go',
        \ 'vim': 'Help',
        \ 'help': 'Help',
        \ 'limbo': 'Infman',
        \ 'infman': 'Infman',
        \ 'info': 'Info',
        \ 'awk': 'Info',
        \ 'make': 'Info',
        \ 'm4': 'Info',
        \ 'automake': 'Info',
        \ 'perl': 'Perl',
        \ 'perldoc': 'Perl',
        \ 'php': 'Pman',
        \ 'pman': 'Pman',
        \ 'python': 'Pydoc',
        \ 'pydoc': 'Pydoc',
        \ 'ruby': 'Ri',
        \ 'rdoc': 'Ri',
        \ 'man': 'Man',
        \ 'sh': 'BashHelp',
        \ }
    return 'ViewDoc' . get(commands, &filetype, 'Help') . (a:bang ? '!' : '')
endfunction


function! ClosePopup()
    if pumvisible()
        return deoplete#mappings#close_popup() . "\<CR>"
    else
        return "\<CR>"
    endif
endfunction


function! PylintSetup()
    " Store off the original PYTHONPATH since it will be modified prior to
    " doing a lint pass.
    let s:python_path = exists('s:python_path') ? s:python_path : $PYTHONPATH
    let l:path = s:python_path
    if match(l:path, getcwd()) >= 0
        " If the current PYTHONPATH already includes the working directory
        " then there is nothing left to do.
        return
    endif
    if !empty(l:path)
        " Uses the same path separator that the OS uses, so ':' on Unix and ';'
        " on Windows. Only consider Unix for now.
        if has('win32')
            let l:path .= ';'
        else
            let l:path .= ':'
        endif
    endif
    let $PYTHONPATH = l:path . getcwd()
endfunction
