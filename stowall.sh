#!/bin/sh
# Stow all dotfiles in HOME directory.

farm=$(dirname "$0")
"$farm"/stow.sh $(find "$farm" -maxdepth 1 -type d)
