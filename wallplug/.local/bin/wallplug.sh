#!/bin/sh
# Set the wallpaper to something from safebooru.donmai.us using wal and co.
# Dependencies:
# - python-pywal
# - wpgtk-git
# - mantablockscreen
# - jq
# shellcheck disable=SC1090,SC2154

# Import definitions ($cache, $config, $lib, $url_file, log, die and wait_display).
. "$HOME/.local/lib/wallplug/defs.sh"

# Import configuration variables.
# $image is the path to the wallpaper.
# $command is a command that will modify the $image
# and optionally store the URL at $url_file.
# $alpha is the alpha for the colour scheme, from 0 to 100.
. "$config/wallplug/config.sh"
# Default values.
image=${image:-$cache/wallplug/image}
command=${command:-'safebooru_plug "touhou pool:scenery_porn"'}
alpha=${alpha:-80}

# Import plugins.
# Plugins should be named in the form ${name}_plug.sh and any global definitions
# within should be prefixed with $name to avoid conflicts.
# (Note that this $name is unrelated to the $name variable within this script.)
# (At this point I should use a real programming language...)
. "$lib"/wallplug/*_plug.sh

# Echo help message.
usage() {
    echo \
"Usage: $(basename "$0") [-u] [-i path] [-c command] [-a alpha] [-h]

wallplug.sh - Set the wallpaper using \`wal' and your choice of image source.

Options:
  -u          print the current wallpaper's URL and exit
  -i path     set the wallpaper to a local file (oneshot)
  -c command  set the command to run to fetch the wallpaper (oneshot)
  -a alpha    set the alpha (oneshot)
  -h          show this help message and exit

To permanently change the source for images, modify the script's \`command'
variable.
To permanently change the alpha, modify the script's \`alpha' variable.

The frequency of wallpaper changes is controlled by the systemd timer. Enable
\`wallplug.timer' to set the wallpaper periodically.

Commands are expected to write an image to \$XDG_CACHE_HOME/wallplug/image
and optionally write a source URL to \$XDG_CACHE_HOME/wallplug/current-url.
"
}

# Set the wallpaper, colour scheme and notify change.
set_wallpaper() {
    image=$1
    alpha=$2
    wait_display
    log 'Setting via wal...'
    # XXX: script/feh only fails to set wallpaper when run through systemd
    # (colorscheme is successfully changed), but works fine when run from
    # terminal.
    # Further note that this only happens occasionally. Currently working.
    wal -c; wal -i "$image" -a "$alpha" -e
    # python-pillow-simd is a drop-in replacement for pillow that isn't a
    # drop-in replacement, so anything depending on pillow is broken.
    log 'Setting via wpg...'
    wpg='python -m wpgtk'
    name=$(basename "$image")
    rm "$config/wpg/schemes/"*"$name"* 2>/dev/null; $wpg -a "$image"
    $wpg -n --alpha "$alpha" -s "$name"
    # log 'Setting betterlockscreen...'
    # betterlockscreen -u "$image"
    log 'Setting mantablockscreen...'
    mantablockscreen -i "$image"
    url=$(cat "$url_file" 2>/dev/null || printf '')
    notify-send 'New wallpaper' "$url" -i "$image" -u low
}

while getopts ':ui:c:a:h?' option; do
    case "$option" in
        u)
            cat "$url_file"
            exit
            ;;
        i)
            image="$OPTARG"
            command=''
            ;;
        c)
            command="$OPTARG"
            ;;
        a)
            alpha="$OPTARG"
            ;;
        \? | h | *)
            usage
            exit
            ;;
    esac
done
eval "$command"
set_wallpaper "$image" "$alpha"
