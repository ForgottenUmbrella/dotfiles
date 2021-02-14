#!/usr/bin/zsh

# Use vi key bindings.
bindkey -v
KEYTIMEOUT=1  # Don't wait for key bindings beginning with ESC.

# Enable completion (efficiently).
autoload -Uz compinit
comp_path="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
if [[ -n $comp_path(#qN.mh+24) ]]
then
    compinit -d "$comp_path"
else
    compinit -C -d "$comp_path"
fi
unset comp_path
zstyle ':completion:*'  matcher-list 'm:{a-z}={A-Z}'  # Smart case.
zstyle ':completion:*' list-colors  # Colourised completion.
autoload -Uz bashcompinit && bashcompinit

# Set up history.
HISTFILE=${ZDOTDIR:-$HOME}/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt share_history  # Share history across sessions.
setopt append_history  # Append instead of overwriting sessions' histories.
setopt inc_append_history  # Update history immediately.
setopt hist_ignore_dups  # Don't store duplicates.
setopt hist_reduce_blanks  # Don't store blank lines.

# Enable correction.
setopt correct
setopt correct_all

# Enable prompt.
autoload -Uz promptinit && promptinit
setopt prompt_subst
_prompt_symbol='%(!,#,❯)'
_prompt_colour='%(?,%F{blue},%F{red})'
_prompt_return_code='%(?,,%F{red}%? )'
_user_host='%F{blue}%n%F{default}@%F{blue}%m'
if [ -n "$SSH_CLIENT$SSH_TTY" ]
then
    _ssh_user_host="$_user_host "
else
    _ssh_user_host=''
fi
_current_directory='%F{magenta}%~'
# Default, left: error?return-code ssh?user@host root?#:>
PS1="$_prompt_colour$_prompt_return_code$_ssh_user_host$_prompt_symbol %F{default}"
PS2='%_>'  # Continuation
PS3='#?'  # Select (for the `select` input command)
PS4='+%N:%i>'  # Debug
RPS1="$_current_directory"  # Default, right

# Enable colours.
autoload -Uz colors && colors
(cat "${XDG_CACHE_HOME:-$HOME/.cache}/wal/sequences" &)
. "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors-tty.sh"

# Configure `cd`.
setopt auto_cd  # Don't require explicit `cd`.
setopt auto_pushd  # Always record directory history for `popd`.

# Configure word movement.
autoload -Uz select-word-style
select-word-style bash
WORDCHARS=''

# Aliases.
# Open files in a new GUI Emacs frame.
alias mx='emacsclient -nc'
# Run wine in Japanese locale.
alias sake='LC_ALL=ja_JP.UTF-8 wine'
# Find broken symlinks.
alias findbroken='find . -xtype l | grep -v "cache\|virtualenvs\|Trash"'
# Replace CAPS LOCK key with Ctrl (on X(Wayland)).
alias capsctrl='setxkbmap -option ctrl:nocaps'
# Switch to QWERTY layout (on X(Wayland)).
alias qwerty='setxkbmap us'
# Switch to colemak layout (on X(Wayland)).
alias colemak='setxkbmap us colemak'
# Merge PDFs given as input into a single merged.pdf.
alias pdfmerge='gs -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -o merged.pdf'

# Load plugins declared in $ZDOTDIR/.zsh_plugins.txt.
. "${ZDOTDIR:-$HOME}/.zsh_plugins.sh"
# NOTE: To update plugins, run `antibody update`.

# softmoth/zsh-vim-mode configuration.
MODE_CURSOR_VIINS='blinking bar'  # Blink to show window focus.
MODE_CURSOR_VISUAL='steady block'
#MODE_INDICATOR_VIINS='%F{15}%F{8}[I]%f'
#MODE_INDICATOR_VICMD='%F{10}%F{2}[N]%f'
#MODE_INDICATOR_REPLACE='%F{9}%F{1}[R]%f'
#MODE_INDICATOR_SEARCH='%F{13}%F{5}[S]%f'
#MODE_INDICATOR_VISUAL='%F{12}%F{4}[V]%f'
#MODE_INDICATOR_VLINE='%F{12}%F{4}[V]%f'

# trystan2k/zsh-tab-title configuration.
ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS=true

# zsh-users/zsh-autosuggestions configuration.
ZSH_AUTOSUGGEST_USE_ASYNC=1
bindkey '^F' autosuggest-accept

# Plugin overrides.

# Key bindings.
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search
. /usr/share/fzf/key-bindings.zsh  # C-T for files, C-R for history, M-C for cd.
. /usr/share/fzf/completion.zsh  # **<TAB>
