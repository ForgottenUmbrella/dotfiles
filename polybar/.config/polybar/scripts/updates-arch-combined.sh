#!/bin/sh
# All scripts based on https://github.com/polybar/polybar-scripts.

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
    updates_arch=0
fi

if ! updates_aur=$(paru -Qum 2> /dev/null | wc -l); then
#if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
#if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
#if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
#if ! updates_aur=$(pikaur -Qua 2> /dev/null | wc -l); then
    updates_aur=0
fi

updates=$(("$updates_arch" + "$updates_aur"))

. "$(xdg-base-dir cache)"/wal/colors.sh
bg=$color0
alert=$color5

if [ "$updates" -gt 0 ]; then
    echo "%{B$alert}%{F$bg}🔄 $updates%{B- F-}"
else
    echo
fi
