#!/bin/sh
# Notify if the battery is low or full.
# Depends on notify-send.sh (AUR).

low=10

status=$(cat /sys/class/power_supply/BAT0/status)
capacity=$(cat /sys/class/power_supply/BAT0/capacity)

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo \
"Usage: $(basename "$0") [-g] [-h]

battery-monitor.sh - Notify when your battery is low or full.

Options:
  -g, --get   print current battery status and capacity
  -h, --help  show this help message and exit
"
    exit
fi

if [ "$1" = "-g" ] || [ "$1" = "--get" ]; then
    echo "Status: $status"
    echo "Capacity: $capacity%"
fi

notify_id_dir="${XDG_DATA_HOME:-$HOME/.local/share}/battery-monitor"
mkdir -p "$notify_id_dir"
notify_id_file="$notify_id_dir/notify-id"

if [ "$status" = "Discharging" ] && [ "$capacity" -le "$low" ]; then
    notify-send.sh "Low battery ($low%)" \
        "Plug in the charger and save your work." \
        -a "$0" -u critical -i battery-caution -R "$notify_id_file"
elif [ "$status" = "Full" ]; then
    notify-send.sh "Battery fully charged" "Unplug the charger." \
        -a "$0" -i battery-full-charged -R "$notify_id_file"
fi
