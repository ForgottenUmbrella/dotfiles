#!/bin/sh
# Forcefully stow in HOME directory, deleting files somehow not owned.

stow -t ~ "$@" 2>&1 |
    awk '/existing target is not owned by stow:/ {print ENVIRON["HOME"] "/" $9}' |
    xargs -o rm -i && stow -t ~ "$@"
