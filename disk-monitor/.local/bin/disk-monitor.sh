#!/bin/sh
# Notify if root disk space is low.

threshold=90

status=$(df / | tail -n 1 | tr -s ' ')
size=$(echo "$status" | cut -f2)
used=$(echo "$status" | cut -f3)
percentage=$(echo "$status" | cut -f5 | tr -d %)

if [ "$percentage" -gt "$threshold" ]; then
    notify-send "Low disk space" \
        "Filesystem root is $percentage% full ($used/$size)." \
        -a "$0" -u critical -i drive-harddisk
fi
