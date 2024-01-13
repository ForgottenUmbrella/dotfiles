#!/bin/sh
# wallplug.sh configuration variables.
# shellcheck disable=SC2034,SC1090,SC2154

# Import definitions ($cache, $config, log).
. "$HOME/.local/lib/wallplug/defs.sh"

# Wallpaper file.
image=$cache/wallplug/image

# Command that modifies wallpaper file and optionally image URL.
plugin=gelbooru_plug
#command="$plugin touhou pool:scenery_porn"
#command="$plugin 'touhou aoha_(twintail)'"
#command="$plugin 'touhou akyuun'"
command="$plugin 'touhou outdoors'"
#command="$plugin 'touhou landscape'"
#command="$plugin 'touhou scenery'"
#command="$plugin 'touhou highres'"
#command="$plugin 'touhou alcxome'"
#command="$plugin 'touhou mikado_(winters)'"
#command="$plugin 'touhou asakura_masatoki'"
#command="$plugin 'touhou mifuru'"
#command="$plugin 'touhou risutaru'"
#command="$plugin 'touhou motsuba'"
#command="$plugin 'touhou ultimate_asuka'"
#command="$plugin 'touhou yoshioka_yoshiko'"
#command="$plugin 'touhou berabou'"
#command="$plugin 'touhou furahata_gen'"
#command="$plugin 'touhou dise'"
#command="$plugin 'touhou yasato'"
#command="$plugin 'touhou rei_(sanbonzakura)'"
#command="$plugin 'touhou cui_(jidanhaidaitang)'"
#command="$plugin 'touhou kukka'"
#command="$plugin 'touhou kaatoso'"
#command="$plugin 'touhou sasaj'"
#command="$plugin 'scenery benitama'"
#command="$plugin 'touhou miso_pan'"
#command="$plugin 'touhou seeker'"
#command="$plugin 'touhou wiriam07'"
#command="$plugin 'touhou lfacras'"
#command="$plugin 'touhou ouka_musci'"
#command="$plugin 'touhou michi_l_(streetlamp)'"
#command="$plugin 'touhou stu_dts'"
#command="$plugin 'touhou you_shimizu'"
#command="$plugin 'touhou 38_(sanjuuhachi)'"

# Commands to run after setting with wal.
post_commands() {
    # Dependencies:
    # - mantablockscreen (i3)
    # - emacs
    # - python-pywalfox
    # - oomox
    #log 'Setting mantablockscreen...'
    #mantablockscreen -i "$image"
    log 'Reloading Emacs ewal theme...'
    emacsclient -e "(load-theme 'ewal-spacemacs-modern t)"
    log 'Reloading Firefox pywalfox theme...'
    pywalfox update
    # XXX: Looks like dunst doesn't like its file disappearing while it runs.
    # Maybe need to restart it here?
    log 'Generating dunst config...'
    cat "$config/dunst/dunstrc" "$cache/wal/colors-dunst" > "$cache/wal/dunstrc"
    log 'Generating oomox GTK theme...'
    # Only xresources2 and xresources3 have decent readability.
    oomox_theme="/opt/oomox/scripted_colors/xresources/xresources2"
    # XXX: libsass 3.6.3 is intentionally broken, leading to infinite memory
    # consumption on certain GTK themes:
    # https://github.com/themix-project/oomox/issues/387#issuecomment-1000955729
    # https://github.com/nana-4/materia-theme/issues/407#issuecomment-510546138
    # https://github.com/sass/libsass/issues/3033#issuecomment-558643562
    #/opt/oomox/plugins/theme_materia/materia-theme/change_color.sh \
    #    "$oomox_theme" --inkscape false
    oomox-cli "$oomox_theme"
    log 'Generating oomox icons...'
    /opt/oomox/plugins/icons_papirus/change_color.sh "$oomox_theme"
    # Needs to be moved for dunst to find it.
    rm -r "$XDG_DATA_HOME/icons/oomox-xresources2"
    mv ~/.icons/oomox-xresources2 "$XDG_DATA_HOME/icons"
    # XXX: Is this necessary?
    #log 'Reloading GTK theme...'
    #gtk-reload
}
