#!/bin/sh
# Notify if the battery is low or full.

low=10

status=$(cat /sys/class/power_supply/BAT0/status)
capacity=$(cat /sys/class/power_supply/BAT0/capacity)
if [ "$status" = "Discharging" ] && [ "$capacity" -le "$low" ]; then
    notify-send "Low battery ($low%)" "Consider charging it and saving your work." -u critical -i battery-caution
elif [ "$status" = "Full" ]; then
    notify-send "Battery fully charged" "Consider unplugging the charger." -u critical -i battery-full-charged
fi
