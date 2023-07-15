#!/bin/sh
# List explicitly installed packages and enabled systemd services.

pacman -Qeqt | less
systemctl list-unit-files --state enabled
systemctl --user list-unit-files --state enabled
