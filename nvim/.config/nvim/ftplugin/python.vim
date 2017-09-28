" ftplugin/python.vim: defines settings for Python files

setlocal colorcolumn+=73
setlocal tabstop=4

augroup plugins
    autocmd User NeomakeAutolint call PylintSetup()
augroup END
