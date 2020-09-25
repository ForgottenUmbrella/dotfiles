#!/bin/sh
# opacity.sh VALUE
# Set opacity of current window in X11, or toggle global transparency in Wayland.
# VALUE shall be a between 0 and 100, where
# a value of 0 means full transparency, and a value of 100 means full opacity.

if [ "$XDG_SESSION_TYPE" = wayland ]
then
    if pgrep inactive-windows-transparency.py
    then
        killall inactive-windows-transparency.py
    else
        /usr/share/sway/scripts/inactive-windows-transparency.py
    fi
else
    picom-trans -c "$1"
fi
