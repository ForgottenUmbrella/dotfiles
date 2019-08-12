#!/bin/sh
# Indicate status of redshift.

. ~/.cache/wal/colors.sh
fg_alt=$color6
inactive=$color1

status=$(systemctl --user is-active redshift)

if [ "$1" = --toggle ]; then
    if [ "$status" = active ]; then
        systemctl --user stop redshift
        status=inactive
    else
        systemctl --user start redshift
        status=active
    fi
fi

if [ "$status" = "active" ]; then
    echo "%{F$fg_alt}%{F-}"
else
    echo "%{F$inactive}%{F-}"
fi
