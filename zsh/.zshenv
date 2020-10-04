# Needs to be set in ~/.zshenv because it's a chicken-and-egg problem.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}"/zsh

# Zsh does not source .profile (environment variable definitions) by default.
emulate sh -c '. ~/.profile'

# Stupid login/non-login BS means sometimes system-wide PATH isn't set.
. /etc/zsh/zprofile
