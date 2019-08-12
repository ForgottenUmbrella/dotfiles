#!/bin/sh
# All scripts based on https://github.com/polybar/polybar-scripts.

. ~/.cache/wal/colors.sh
fg_alt=$color6
inactive=$color1

if ! command -v bluetooth > /dev/null; then
    exit
fi

if [ "$1" = --toggle ]; then
    bluetooth toggle
fi

if [ "$(bluetooth)" = "bluetooth = on" ]; then
	  echo "%{F$fg_alt}%{F-}"
else
    echo "%{F$inactive}%{F-}"
fi
