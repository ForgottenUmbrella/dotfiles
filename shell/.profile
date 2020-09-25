# Ensure systemd environment variables are available on Xorg.
# Note that GDM loads systemd environment variables on Wayland.
set -a
. ~/.config/environment.d/*
set +a

# Start keyring.
if [ -n "$DESKTOP_SESSION" ]
then
    eval "$(gnome-keyring-daemon --start)"
    export SSH_AUTH_SOCK
fi
