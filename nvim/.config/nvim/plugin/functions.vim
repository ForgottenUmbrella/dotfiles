" plugin/functions.vim: defines functions

function! FHelp()
    for l:i in range(1,12)
        execute 'map <F' . l:i . '>'
    endfor
endfunction


function! WindowList()
    " Return a list of names of open windows.
    let l:windows = []
    windo call add(windows, bufname('%'))
    return l:windows
endfunction


function! WindowMatchList(pattern)
    " Return a list of names of open windows that matches `pattern`.
    let l:matches = []
    for l:window in WindowList()
        if l:window =~ a:pattern
            call add(l:matches, l:window)
            break
        endif
    endfor
    return l:matches
endfunction


function! ScratchOpen()
    let l:scratch_windows = WindowMatchList('Scratch')
    if !len(l:scratch_windows)
        " Now using todo.txt.
        topleft 5split ~/Dropbox/Wiki/todo.txt
    else
        execute bufwinnr(l:scratch_windows[-1]) 'wincmd w'
    endif
endfunction


function! ScratchClose()
    let l:scratch_windows = WindowMatchList('Scratch')
    for l:window in l:scratch_windows
        execute bufwinnr(l:window) 'wincmd w'
        update
        quit
    endfor
endfunction


function! ScratchToggle()
    let l:scratch_windows = WindowMatchList('Scratch')
    if len(l:scratch_windows)
        call ScratchClose()
    else
        call ScratchOpen()
    endif
endfunction


function! Refresh()
    let @/ = ''
    execute "normal! \<C-l>"
endfunction


function! PWD()
    redir => s:pwd
    pwd
    redir END
    return s:pwd
endfunction


function! SimplifyHome(path)
    " Return a path with the user directory replaced with a tilde (and
    " username).
    let l:path = a:path
    let l:home = glob('$HOME')
    let l:home_parts = split(l:home, '/')
    if l:path =~ join(l:home_parts[:-2], '/') && l:path !~ l:home_parts[-1]
        let l:new_home = '~' + l:home_parts[-1]
    else
        let l:new_home = '~'
    endif
    return substitute(l:path, l:home, l:new_home, '')
endfunction


function! TruncatedCWD()
    let l:cwd = SimplifyHome(getcwd())
    let l:dirs = split(l:cwd, '/')
    " When CWD starts with /, splitting it strips the /, so the final join
    " won't be equal to the original string. Add a null string to make it
    " equal.
    if strpart(l:cwd, 0, 1) ==# '/'
        let l:shortened_dirs = ['']
    else
        let l:shortened_dirs = []
    endif
    " Don't shorten the last directory.
    for l:dir in l:dirs[:-2]
        call add(l:shortened_dirs, strpart(l:dir, 0, 1))
    endfor
    " Add the last directory as it is, if it exists.
    if len(l:dirs)
        call add(l:shortened_dirs, l:dirs[-1])
    endif
    return join(l:shortened_dirs, '/')
endfunction


function! GetPythonTextWidth()
    " By https://stackoverflow.com/a/4028423.
    if !exists('g:python_normal_text_width')
        let l:normal_text_width = 79
    else
        let l:normal_text_width = g:python_normal_text_width
    endif
    if !exists('g:python_comment_text_width')
        let l:comment_text_width = 72
    else
        let l:comment_text_width = g:python_comment_text_width
    endif

    let l:cur_syntax = synIDattr(
        \ synIDtrans(synID(line('.'), col('.'), 0)), 'name')
    if l:cur_syntax ==? 'Comment'
        return l:comment_text_width
    elseif l:cur_syntax ==? 'String'
        " Check to see if we're in a docstring.
        let l:lnum = line('.')
        let l:lcol = col([l:lnum, '$']) - 1
        let l:is_string = (synIDattr(
            \ synIDtrans(synID(l:lnum, l:lcol, 0)), 'name') ==? 'String')
        let l:regex_is_matched = (match(getline(l:lnum), '\v^\s*$') > -1)
        while l:lnum >= 1 && l:is_string || l:regex_is_matched
            if match(getline(l:lnum), "\\('''\\|\"\"\"\\)") > -1
                " Assume that any longstring is a docstring.
                return l:comment_text_width
            endif
            let l:lnum -= 1
        endwhile
    endif

    return l:normal_text_width
endfunction


function! PrepareForMSWord(count)
    execute a:count 'yank'
    vnew
    put
    " Add newlines before bullets.
    %substitute/\(^\s\{-}\([0-9]\{-}\.\|[*-+]\)\s\)/\1/e
    Unwrap
    global/^\n[^\n]/delete
    %yank +
    %yank *
    quit!
    echo 'Yanked to system clipboard.'
endfunction


function! Reload()
    source ~/.config/nvim/init.vim
    for l:file in split(glob('~/.config/nvim/plugin/*.vim'), '\n')
        execute 'source' l:file
    endfor
    if has('gui_running')
        source ~/.config/nvim/ginit.vim
    endif
endfunction


function! RemoveEmptyIndentOrClosePopup()
    let l:line_to_cursor_length = col('.') - 2
    let l:line_to_cursor = getline('.')[:l:line_to_cursor_length]
    let l:empty_line_indented = l:line_to_cursor =~# '^\s\+$'
    if l:empty_line_indented
        let l:remove_indent_and_indent_next = "\<CR>\<Esc>k0\"_DjA"
            \ "\<Space>" * l:line_to_cursor_length
        return l:remove_indent_and_indent_next
    else
        return ClosePopup()
    endif
endfunction

