#!/bin/sh
# Report Dropbox status.
# All scripts based on https://github.com/polybar/polybar-scripts.

. ~/.cache/wal/colors.sh
fg_alt=$color6
inactive=$color1
transient=$color3

if ! command -v dropbox-cli > /dev/null; then
    exit
fi

if [ "$1" = "--toggle" ]; then
    # `dropbox-cli running` returns 1 if running instead of the conventional
    # truthy 0 (https://linux.die.net/man/1/dropbox).
    if dropbox-cli running; then
        dropbox-cli stop
    else
        dropbox-cli start
    fi
fi

status=$(dropbox-cli status)
if [ "$status" = "Dropbox isn't running!" ]; then
    echo "%{F$inactive}%{F-}"
elif [ "$status" = "Up to date" ]; then
    echo "%{F$fg_alt}%{F-}"
else
    printf "%%{F$transient}"
    if echo "$status" | grep -q "Downloading"; then
        printf 
    elif echo "$status" | grep -q "Uploading"; then
        printf 
    else
        printf " "
    fi
    echo "%{F-}"
fi
