#!/bin/sh
# Based on https://github.com/polybar/polybar-scripts.
# Report Dropbox status in JSON.

if ! command -v dropbox-cli > /dev/null; then
    exit
fi

if [ "$1" = '--toggle' ]; then
    if dropbox-cli running; then
        dropbox-cli stop
    else
        dropbox-cli start
    fi
fi

status=$(dropbox-cli status)
if [ "$status" = "Dropbox isn't running!" ]; then
    text="$status"
    class='alert'
elif [ "$status" = 'Up to date' ]; then
    text="$status"
    class='fg-alt'
else
    class='transient'
    if echo "$status" | grep -q 'Downloading'; then
        text='Downloading'
    elif echo "$status" | grep -q 'Uploading'; then
        text='Uploading'
    else
        text='Syncing'
    fi
fi

alt="$text"
tooltip="$status"
printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s"}' \
       "$text" "$alt" "$tooltip" "$class"
