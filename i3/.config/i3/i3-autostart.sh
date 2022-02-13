#!/bin/sh
# Launch i3-specific autostart programs.

if [ "$XDG_SESSION_DESKTOP" = 'i3' ]
then
    pgrep xautolock || xautolock -time 30 -locker 'lock && systemctl suspend-then-hibernate' &
    xmodmap ~/.Xmodmap
    killall -q picom; picom -b --experimental-backends
    killall -q polybar; "$(xdg-base-dir config)"/polybar/launch.sh
    wal -R
fi
