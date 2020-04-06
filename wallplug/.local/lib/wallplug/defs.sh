#!/bin/sh
# Global definitions.
# shellcheck disable=SC2034

# Cache directory.
cache=${XDG_CACHE_HOME:-$HOME/.cache}
# Config directory.
config=${XDG_CONFIG_HOME:-$HOME/.config}
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

# Wait until X DISPLAY is available.
wait_display() {
    while [ -z "$DISPLAY" ]; do
        log 'DISPLAY temporarily unavailable, sleeping...'
        sleep 10
    done
}
