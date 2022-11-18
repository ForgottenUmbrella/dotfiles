#!/bin/sh
# Set the wallpaper from some source using wal and co.

# By default, wallpapers are sourced from safebooru.donmai.us, but this may be
# extended to any other source by creating a ~/.local/lib/wallplug/*_plug.sh
# script that provides a function to write to $image (see the example script for
# guidance), and setting $command to this command in
# $XDG_CONFIG_HOME/wallplug/config.sh.

# Additional commands to run after wal can be specified in the `post_commands`
# function defined in $XDG_CONFIG_HOME/wallplug/config.sh.

# Dependencies:
# - python-pywal

# shellcheck disable=SC1090,SC2154

# Import definitions ($cache, $config, $lib, $url_file, log, die and wait_display).
. "$HOME/.local/lib/wallplug/defs.sh"

# Import configuration variables.
# $image is the path to the wallpaper.
# $command is a command that will modify the $image
# and optionally store the URL at $url_file.
# post_command is a function that runs additional commands after wal.
. "$config/wallplug/config.sh"
# Default values.
image=${image:-$cache/wallplug/image}
command=${command:-'safebooru_plug "touhou pool:scenery_porn"'}

# Import plugins.
# Plugins should be named in the form ${plugin}_plug.sh and any global definitions
# within should be prefixed with $plugin to avoid conflicts.
# (At this point I should use a real programming language...)
. "$lib"/wallplug/*_plug.sh

# Echo help message.
usage() {
    echo \
"Usage: $(basename "$0") [-u] [-i path] [-c command] [-h]

wallplug.sh - Set the wallpaper using \`wal' and your choice of image source.

Options:
  -u          print the current wallpaper's URL and exit
  -i path     set the wallpaper to a local file (oneshot)
  -c command  set the command to run to fetch the wallpaper (oneshot)
  -h          show this help message and exit

To permanently change the source for images, modify the script's \`command'
variable.

The frequency of wallpaper changes is controlled by the systemd timer. Enable
\`wallplug.timer' to set the wallpaper periodically.

Commands are expected to write an image to \$XDG_CACHE_HOME/wallplug/image
and optionally write a source URL to \$XDG_CACHE_HOME/wallplug/current-url.
"
}

# Set the wallpaper, colour scheme and notify change.
set_wallpaper() {
    image=$1
    wait_display
    log 'Setting via wal...'
    # XXX: script/feh only fails to set wallpaper when run through systemd
    # (colorscheme is successfully changed), but works fine when run from
    # terminal.
    # Further note that this only happens occasionally. Currently working.
    wal -c; wal -i "$image"
    command -v post_commands >/dev/null 2>&1 && post_commands
    url=$(cat "$url_file" 2>/dev/null || printf '')
    notify-send.sh 'New wallpaper' "$url" -i "$image" -u low -R "$cache/wallplug/notify"
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
        \? | h | *)
            usage
            exit
            ;;
    esac
done
eval "$command"
set_wallpaper "$image"
cat "$url_file"
