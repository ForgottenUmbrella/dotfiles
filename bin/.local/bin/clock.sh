#!/bin/sh
# Clock in and out to print how many hours you've worked today.

cache=$(xdg-base-dir cache)/clock
mkdir -p "$cache"
timestamp=$cache/clock-in

case "$1" in
    in)
        date +%s > "$timestamp"
        ;;
    out)
        clock_in=$(cat "$timestamp")
        clock_out=$(date +%s)
        printf %.2f $(echo "scale = 3; ($clock_out - $clock_in) / 3600" | bc)
        ;;
    *)
        echo \
"Usage: $(basename "$0") (in|out) [-h]

clock.sh - Clock in and out to print how many hours you've worked today.

Options:
  -h --help  show this help message and exit
"
        exit 1
esac
