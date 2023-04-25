#!/bin/sh
# Clock in and out to print how many hours you've worked today.

timestamp=$(xdg-base-dir cache)/clock/clock-in

case "$1" in
    in)
        date +%s > "$timestamp"
        ;;
    out)
        clock_in=$(cat "$timestamp")
        clock_out=$(date +%s)
        echo "scale = 2; ($clock_out - $clock_in) / 3600" | bc
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
