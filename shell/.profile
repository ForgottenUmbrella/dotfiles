# Ensure systemd environment variables are available on Xorg.
# Note that GDM loads systemd environment variables on Wayland.
set -a
# Chicken-and-egg?
. "${XDG_CONFIG_HOME:+$HOME/.config}"/environment.d/*
set +a
