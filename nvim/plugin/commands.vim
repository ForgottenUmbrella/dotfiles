" plugin/commands.vim: defines various commands


" See edits since last write
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis |
    \ wincmd p | diffthis

" Wrap
command! Wrap %normal gwip
command! Unwrap global/./,-/\n$/join

" Delete newlines
command! DeleteNewlines global/^\n/delete
" sudo
command! W w !sudo tee % >/dev/null

" Scratch
command! ScratchToggle call ScratchToggle()

" Refresh
silent! command call Refresh()

" Allow joining commands
command! -bar UpdateRemotePluginsAndKnuckles UpdateRemotePlugins

" Export to a word processor
command! -range=% ToMSWord call PrepareForMSWord(<count>)
