#!/bin/sh
# From https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
# Usage: import-gsettings <gsettings key>:<settings.ini key> <gsettings key>:<settings.ini key> ...

expressions=""
for pair in "$@"; do
    IFS=:; set -- $pair
    expressions="$expressions -e 's:^$2=(.*)$:gsettings set org.gnome.desktop.interface $1 \1:e'"
done
IFS=
eval exec sed -E $expressions "$(xdg-base-dir config)"/gtk-3.0/settings.ini >/dev/null
