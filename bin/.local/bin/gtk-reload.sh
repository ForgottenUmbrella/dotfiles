#!/bin/sh
# Reload the current GTK theme.
theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme ''
# sleep 0.1  # XXX: Is this necessary?
gsettings set org.gnome.desktop.interface gtk-theme "$theme"
