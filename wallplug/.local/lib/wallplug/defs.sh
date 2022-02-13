#!/bin/sh
# Global definitions.
# shellcheck disable=SC2034

# Cache directory.
cache=$(xdg-base-dir cache)
# Config directory.
config=$(xdg-base-dir config)
# Local libraries.
lib=$HOME/.local/lib
# Where image URL is stored.
url_file=$cache/wallplug/current-url

# Echo information for user; used to differentiate from pipeline.
log() {
    echo "$@"
}

# Echo error message and exit with last exit code.
die() {
    exit_code=$?
    echo 'Error:' "$@" 1>&2
    exit "$exit_code"
}

# Wait until X DISPLAY is available. XXX This doesn't work
wait_display() {
    # while ! env | grep -q 'DISPLAY='; do
    #     log 'DISPLAY temporarily unavailable, sleeping...'
    #     sleep 10
    # done
    [ -z "$DISPLAY" ] && log 'DISPLAY initially unavailable...'
}
