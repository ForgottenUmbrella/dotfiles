#!/bin/sh
# Show the status of the Pomodoro timer via `pomo`.

. ~/.cache/wal/colors.sh
inactive=$color1
bg=$color0
fg_alt=$color6
alert=$color5


popup() {
    if [ "$(xdotool getwindowfocus getwindowname)" != "dropdown" ]; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
        i3-msg scratchpad show
    fi
}

if ! command -v pomo > /dev/null; then
    exit
fi

status=$(pomo status)
if echo $status | grep -q "?"; then
    echo
elif echo $status | grep -q "B\|C"; then
    echo "%{B$alert}%{F$bg}🍅 $status%{B- F-}"
    popup
elif echo $status | grep -q "P"; then
    echo "%{F$inactive}🍅%{F-} $status"
else
    echo "%{F$fg_alt}🍅%{F-} $status"
fi
