" ginit.vim: defines settings for graphical (N)Vim instances
if has('win32') && has('nvim')
    GuiFont! InconsolataForPowerline\ NF:h12
else
    set guifont=InconsolataForPowerline\ NF:h12
endif

set guioptions=ac
if has('win32')
    set renderoptions=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,
        \renmode:4,taamode:1
endif

