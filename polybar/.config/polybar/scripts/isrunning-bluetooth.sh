#!/bin/sh
# Report whether Bluetooth is enabled.
# All scripts based on https://github.com/polybar/polybar-scripts.

. "$(xdg-base-dir cache)"/wal/colors.sh
fg_alt=$color6
inactive=$color1

if ! command -v bluetoothctl > /dev/null
then
    exit
fi

power=$(bluetoothctl show | awk '/Powered/ {print $2}')

if [ "$1" = --toggle ]
then
    if [ "$power" = "on" ]
    then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
fi

if [ "$power" = "on" ]
then
    echo "%{F$fg_alt}%{F-}"
else
    echo "%{F$inactive}%{F-}"
fi
