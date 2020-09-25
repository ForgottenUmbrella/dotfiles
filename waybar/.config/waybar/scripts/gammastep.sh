#!/bin/sh
# Indicate status of gammastep in JSON.

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

out=$(gammastep -vp 2>&1 | sed 's/Notice: //')
text="$status"
alt=$(echo "$out" | grep 'Period:')
tooltip=$(gammastep -p 2>&1 | sed 's/Notice: //' | sed -z 's/\n/\\n/g')
class="$status"
day=$(echo "$out" | awk '/Temperatures:/ {print $2}' | tr -d 'K')
now=$(echo "$out" | awk '/Color temperature:/ {print $3}' | tr -d 'K')
percentage=$(echo "scale=2; $now/$day * 100" | bc)

printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "%s", "percentage": %s}' \
       "$text" "$alt" "$tooltip" "$class" "$percentage"
