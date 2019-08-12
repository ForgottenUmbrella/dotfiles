#!/usr/bin/zsh
# Set up history.
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Change directory without `cd`.
setopt autocd
# Enable directory history traversal automatically.
setopt autopushd

# Use vi key bindings.
bindkey -v

# Configure completion.
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Load zcalc.
autoload -Uz zcalc

# Drop down to fish if not in TTY.
if ! tty | grep -q tty; then
    exec fish
fi
