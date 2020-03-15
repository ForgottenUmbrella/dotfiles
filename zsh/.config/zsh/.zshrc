#!/usr/bin/zsh
# Set up history.
HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Drop down to fish if not in TTY.
# Set DEAD_FISH to avoid drop.
if ! tty | grep -q tty && [[ ! -v DEAD_FISH ]]; then
    exec fish
fi

# Change directory without `cd`.
setopt autocd
# Enable directory history traversal automatically.
setopt autopushd

# Set prompt.
autoload -Uz promptinit
promptinit
prompt suse

# Use vi key bindings.
bindkey -v

# Configure completion.
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Enable colours.
autoload -Uz colors && colors

# Load zcalc.
autoload -Uz zcalc
