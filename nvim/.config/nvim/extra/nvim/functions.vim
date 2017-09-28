" extra/nvim/functions.vim: defines functions for neovim

function! TermOpen(args, count, vertical, insert)
    " Open a terminal if not already open.
    let term_windows = WindowMatchList('term')
    if !len(term_windows)
        let command = a:vertical ? 'VTerm ' : 'Term '
        execute a:count command a:args
        if !a:insert
            stopinsert
            wincmd p
        endif
    else
        execute bufwinnr(term_windows[-1]) 'wincmd w'
    endif
endfunction

function! TermClose()
    " Close all terminals.
    let term_windows = WindowMatchList('term')
    for window in term_windows
        execute 'bdelete' window
    endfor
endfunction

function! TermToggle(args, count, vertical, insert)
    " Open a terminal if there are none, otherwise close all terminals.
    let term_windows = WindowMatchList('term')
    if len(term_windows)
        call TermClose()
    else
        call TermOpen(args, count, vertical, insert)
    endif
endfunction

function! NIDEOpen()
    call IDEOpen()
    call TermOpen('", 5, 0, 0)
endfunction

function! NIDEClose()
    call IDEClose()
    call TermClose()
endfunction

