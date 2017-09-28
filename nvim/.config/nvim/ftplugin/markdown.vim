" ftplugin/markdown.vim: defines Markdown-specific settings

syntax match StrikeoutMatch /\~\~.*\~\~/
highlight def StrikeoutColour
    \ ctermbg=darkblue ctermfg=black guibg=darkblue guifg=blue
highlight link StrikeoutMatch StrikeoutColour

