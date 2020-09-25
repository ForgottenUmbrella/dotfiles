export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}"/zsh
# Zsh does not source .profile (environment variable definitions) by default.
emulate sh -c '. ~/.profile'

