" extra/nvim/commands.vim: defines commands for Neovim

" Split Term Toggle
command! -count -nargs=* TermOpen call TermOpen(<q-args>, <count>, 0, 1)
command! -count -nargs=* VTermOpen call TermOpen(<q-args>, <count>, 1, 1)
command! TermClose call TermClose()
command! -count -nargs=* TermToggle call TermToggle(<q-args>, <count>, 0, 0)
command! -count -nargs=* VTermToggle call TermToggle(<q-args>, <count>, 1, 0)
command! IDE call NIDEOpen()<Bar>command! IDE call IDEToggle()
