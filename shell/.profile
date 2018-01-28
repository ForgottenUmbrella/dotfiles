export PATH="$PATH:$HOME/bin:$HOME/.local/bin"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg

# export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export XINITRC="$XDG_CONFIG_HOME/X11/xinitrc"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export LESSKEY="$XDG_CONFIG_HOME/less/lesskey"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export ICEAUTHORITY="$XDG_RUNTIME_DIR/ICEauthority"

export GTK_THEME=Adwaita
# export QT_STYLE_OVERRIDE=GTK+
# export QT_STYLE_OVERRIDE=adwaita
export QT_STYLE_OVERRIDE=gtk2
# export QT_QPA_PLATFORMTHEME=gtk2
export ANKI_BASE="$XDG_DATA_HOME/anki"
export GIMP2_DIRECTORY="$XDG_CONFIG_HOME/gimp"
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
