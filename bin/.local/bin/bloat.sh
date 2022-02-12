#!/bin/sh
# List explicitly installed packages and enabled systemd services.

pacman -Qeq | less
systemctl list-unit-files --state enabled
systemctl --user list-unit-files --state enabled
