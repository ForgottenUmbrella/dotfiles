#!/bin/sh
# Notify if the battery is low or full.

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

if [ "$status" = "Discharging" ] && [ "$capacity" -le "$low" ]; then
    notify-send "Low battery ($low%)" "Plug in the charger and save your work." \
                -a "$0" -u critical -i battery-caution
elif [ "$status" = "Full" ]; then
    notify-send "Battery fully charged" "Unplug the charger." \
                -a "$0" -i battery-full-charged
fi
