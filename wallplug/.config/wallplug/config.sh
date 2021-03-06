#!/bin/sh
# wallplug.sh configuration variables.
# shellcheck disable=SC2034,SC1090,SC2154

# Import definitions ($cache, $config, log).
. "$HOME/.local/lib/wallplug/defs.sh"

# Wallpaper file.
image=$cache/wallplug/image

# Command that modifies wallpaper file and optionally image URL.
#command='safebooru_plug touhou pool:scenery_porn'
#command='safebooru_plug "touhou aoha_(twintail)"'
#command='safebooru_plug "touhou akyuun"'
command='safebooru_plug "touhou outdoors"'
#command='safebooru_plug "touhou landscape"'
#command='safebooru_plug "touhou scenery"'
#command='safebooru_plug "touhou highres"'
#command='safebooru_plug "touhou alcxome"'
#command='safebooru_plug "touhou mikado_(winters)"'
#command='safebooru_plug "touhou asakura_masatoki"'
#command='safebooru_plug "touhou mifuru"'
#command='safebooru_plug "touhou risutaru"'
#command='safebooru_plug "touhou motsuba"'
#command='safebooru_plug "touhou ultimate_asuka"'
#command='safebooru_plug "touhou yoshioka_yoshiko"'
#command='safebooru_plug "touhou berabou"'
#command='safebooru_plug "touhou furahata_gen"'
#command='safebooru_plug "touhou dise"'
#command='safebooru_plug "touhou yasato"'
#command='safebooru_plug "touhou rei_(sanbonzakura)"'
#command='safebooru_plug "touhou cui_(jidanhaidaitang)"'
#command='safebooru_plug "touhou kukka"'
#command='safebooru_plug "touhou kaatoso"'
#command='safebooru_plug "touhou sasaj"'
#command='safebooru_plug "scenery benitama"'
#command='safebooru_plug "touhou miso_pan"'
#command='safebooru_plug "touhou seeker"'
#command='safebooru_plug "touhou wiriam07"'
#command='safebooru_plug "touhou lfacras"'
#command='safebooru_plug "touhou ouka_musci"'
#command='safebooru_plug "touhou michi_l_(streetlamp)"'

# Alpha of colour scheme.
alpha=80

# Commands to run after setting with wal.
post_commands() {
    # Dependencies:
    # - mantablockscreen
    # - emacs
    # - python-pywalfox
    # - oomox
    log 'Setting mantablockscreen...'
    mantablockscreen -i "$image"
    log 'Reloading Emacs ewal theme...'
    emacsclient -e "(load-theme 'ewal-spacemacs-modern t)"
    log 'Reloading Firefox pywalfox theme...'
    pywalfox update
    #log 'Generating termite config...'
    #cat "$config/termite/config" "$cache/wal/colors-termite" > "$cache/wal/termite-config"
    # XXX: Looks like dunst doesn't like its file disappearing while it runs.
    # Maybe need to restart it here?
    log 'Generating dunst config...'
    cat "$config/dunst/dunstrc" "$cache/wal/colors-dunst" > "$cache/wal/dunstrc"
    log 'Generating mako config...'
    cat "$cache/wal/mako-global" "$config/mako/config" \
        "$cache/wal/mako-criteria" > "$cache/wal/mako-config"
    log 'Generating oomox GTK theme...'
    # Only xresources2 and xresources3 have decent readability.
    oomox_theme="/opt/oomox/scripted_colors/xresources/xresources2"
    # XXX: libsass 3.6.3 is broken, leading to infinite memory consumption on
    # certain GTK themes.
    #/opt/oomox/plugins/theme_materia/materia-theme/change_color.sh "$oomox_theme"
    oomox-cli "$oomox_theme"
    log 'Generating oomox icons...'
    /opt/oomox/plugins/icons_papirus/change_color.sh "$oomox_theme"
    # XXX: Is this necessary?
    # log 'Reloading GTK theme...'
    # gtk-reload
}
