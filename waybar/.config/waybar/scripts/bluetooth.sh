#!/bin/sh
# Report whether Bluetooth is enabled in JSON.
# All scripts based on https://github.com/polybar/polybar-scripts.

if ! command -v bluetooth > /dev/null; then
    exit
fi

if [ "$1" = --toggle ]; then
    bluetooth toggle
fi

out=$(bluetooth)
if [ "$out" = "bluetooth = on" ]; then
    text='On'
    class='active'
else
    text='Off'
    class='inactive'
fi

alt="$class"
tooltip="$out"

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}' \
       "$text" "$alt" "$tooltip" "$class"
