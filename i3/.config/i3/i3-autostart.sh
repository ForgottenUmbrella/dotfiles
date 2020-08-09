#!/usr/bin/env bash
# Launch the i3-session.target if running in i3.

if [[ $XDG_SESSION_DESKTOP == i3* ]]
then
    xautolock -tim 30 -locker 'lock && systemctl suspend-then-hibernate' &
    xmodmap ~/.Xmodmap
    killall picom; picom -b --experimental-backends
    killall polybar; ~/.config/polybar/launch.sh
    killall dunst; dunst &
fi
