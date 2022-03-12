#!/bin/sh
# Report whether Bluetooth is enabled in JSON.
# All scripts based on https://github.com/polybar/polybar-scripts.

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
    text='On'
    class='active'
else
    text='Off'
    class='inactive'
fi

alt="$class"
tooltip="$power"

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}' \
       "$text" "$alt" "$tooltip" "$class"
