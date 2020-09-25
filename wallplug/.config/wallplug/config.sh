#!/bin/sh
# wallplug.sh configuration variables.
# shellcheck disable=SC2034,SC1090,SC2154

# Import definitions ($cache, $config, log).
. "$HOME/.local/lib/wallplug/defs.sh"

# Wallpaper file.
image=$cache/wallplug/image

# Command that modifies wallpaper file and optionally image URL.
command='safebooru_plug touhou pool:scenery_porn'
#command='safebooru_plug "touhou aoha_(twintail)"'
#command='safebooru_plug "touhou akyuun"'
#command='safebooru_plug "touhou landscape"'
#command='safebooru_plug "touhou alcxome"'
#command='safebooru_plug "touhou mikado_(winters)"'
#command='safebooru_plug "touhou asakura_masatoki"'
#command='safebooru_plug "touhou mifuru"'
#command='safebooru_plug "touhou risutaru"'
#command='safebooru_plug "touhou motsuba"'
#command='safebooru_plug "touhou ultimate_asuka"'

# Alpha of colour scheme.
alpha=80

# Commands to run after setting with wal.
post_commands() {
    # Dependencies:
    # - wpgtk-git
    # - mantablockscreen
    # - emacs
    # - python-pywalfox
    log 'Setting via wpg...'
    # python-pillow-simd is a drop-in replacement for pillow that isn't a
    # drop-in replacement, so anything depending on pillow is broken.
    wpg='python -m wpgtk'
    name=$(basename "$image")
    rm "$config/wpg/schemes/"*"$name"* 2>/dev/null; $wpg -a "$image"
    $wpg -n --alpha "$alpha" -s "$name"
    log 'Setting mantablockscreen...'
    mantablockscreen -i "$image"
    log 'Reloading Emacs ewal theme...'
    emacsclient -e "(load-theme 'ewal-spacemacs-modern t)"
    log 'Reloading Firefox pywalfox theme...'
    pywalfox update
    log 'Generating termite config...'
    cat "$config/termite/config" "$cache/wal/colors-termite" > "$cache/wal/termite-config"
    # XXX: Looks like dunst doesn't like its file disappearing while it runs.
    # Maybe need to restart it here?
    log 'Generating dunst config...'
    cat "$config/dunst/dunstrc" "$cache/wal/colors-dunst" > "$cache/wal/dunstrc"
    log 'Generating mako config...'
    cat "$cache/wal/mako-global" "$config/mako/config" \
        "$cache/wal/mako-criteria" > "$cache/wal/mako-config"
}
