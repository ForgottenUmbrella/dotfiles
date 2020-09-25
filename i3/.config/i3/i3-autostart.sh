#!/usr/bin/env bash
# Launch i3-specific autostart programs.

if [[ "$XDG_SESSION_DESKTOP" == i3* ]]
then
    pgrep xautolock || xautolock -time 30 -locker 'lock && systemctl suspend-then-hibernate' &
    xmodmap ~/.Xmodmap
    killall -q picom; picom -b --experimental-backends
    killall -q polybar; ~/.config/polybar/launch.sh
    killall -q dunst; millfeed &
    # wal does not remember the alpha.
    wal -R -a 80
fi
