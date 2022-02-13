#!/bin/sh
# Indicate status of gammastep.

. "$(xdg-base-dir cache)"/wal/colors.sh
fg_alt=$color6
inactive=$color1

status=$(systemctl --user is-active gammastep)

if [ "$1" = --toggle ]; then
    if [ "$status" = active ]; then
        systemctl --user stop gammastep
        status=inactive
    else
        systemctl --user start gammastep
        status=active
    fi
fi

if [ "$status" = "active" ]; then
    echo "%{F$fg_alt}%{F-}"
else
    echo "%{F$inactive}%{F-}"
fi
