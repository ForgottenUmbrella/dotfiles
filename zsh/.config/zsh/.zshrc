#!/usr/bin/zsh

# Vi key bindings
bindkey -v
KEYTIMEOUT=1  # Don't wait for key bindings beginning with ESC.

# Completion
autoload -Uz compinit
# Speed up zsh compinit by only checking completion cache once a day.
comp_path="$(xdg-base-dir cache)/zsh/zcompdump"
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

# History
HISTFILE=${ZDOTDIR:-$HOME}/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt share_history  # Share history across sessions.
setopt append_history  # Append instead of overwriting sessions' histories.
setopt inc_append_history  # Update history immediately.
setopt hist_ignore_dups  # Don't store duplicates.
setopt hist_reduce_blanks  # Don't store blank lines.

# Typos
setopt correct  # Correct command names.
setopt correct_all  # Correct arguments.

# Prompt
autoload -Uz promptinit && promptinit
setopt prompt_subst  # Evaluate certain expressions in prompt.
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

# Colours
autoload -Uz colors && colors
if type wal > /dev/null; then
  (cat "$(xdg-base-dir cache)/wal/sequences" &)
  . "$(xdg-base-dir cache)/wal/colors-tty.sh"
fi

# Auto `cd`
setopt auto_cd  # Don't require explicit `cd`.
setopt auto_pushd  # Always record directory history for `popd`.

# Word movement
autoload -Uz select-word-style
select-word-style bash
WORDCHARS=''

# Zsh help
unalias run-help 2>/dev/null
autoload run-help

# Beeps
unsetopt beep  # Disable beeps.

# Aliases
# Open files in a new GUI Emacs frame.
alias mx='emacsclient -nc'
# Run wine in Japanese locale.
alias sake='LC_ALL=ja_JP.UTF-8 wine'
# Find broken symlinks.
alias findbroken='find . -xtype l | grep -v "cache\|virtualenvs\|Trash"'
# Replace CAPS LOCK key with Ctrl (on X(Wayland)).
alias capsctrl='setxkbmap -option ctrl:nocaps; xmodmap ~/.Xmodmap'
# Merge PDFs given as input into a single compressed merged.pdf.
alias pdfmerge='gs -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -o merged.pdf'
# Open files.
alias open='xdg-open'
# Get GPU info.
alias gpuinfo='lspci | grep " VGA " | cut -d " " -f 1 | xargs lspci -v -s'
# Update the GRUB configuration.
alias grub-update='sudo grub-mkconfig -o /boot/grub/grub.cfg'
# View zsh help (with the same name as in bash).
alias help='run-help'
# View images with sensible defaults.
alias fe='feh -Tsensible'

# Work config (macOS). Modifies PATH.
if [ "$(uname)" = 'Darwin' ]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  export PGHOST='localhost'

  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"

  eval "$(/opt/homebrew/bin/brew shellenv)"

  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH"
  export PATH="$PATH:/Applications/Emacs.app/Contents/MacOS/bin"
fi

# Load plugins declared in $ZDOTDIR/.zsh_plugins.txt.
. "${ZDOTDIR:-$HOME}/.zsh_plugins.sh"
# NOTE: To update plugins, run `antibody update`.

# Plugin settings

# trystan2k/zsh-tab-title
ZSH_TAB_TITLE_CONCAT_FOLDER_PROCESS=true

# zpm-zsh/colorize
# Fix for differences between BSD and GNU utils.
if [ "$(uname)" = 'Darwin' ]; then
    alias colourify='grc -es --colour=auto'
    alias diff='colourify /usr/bin/diff'
fi

# zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1
bindkey '^F' autosuggest-accept

# zsh-users/zsh-history-substring-search
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# softmoth/zsh-vim-mode
MODE_CURSOR_VIINS='blinking bar'  # Blink to show window focus.
MODE_CURSOR_VISUAL='steady block'
#MODE_INDICATOR_VIINS='%F{15}%F{8}[I]%f'
#MODE_INDICATOR_VICMD='%F{10}%F{2}[N]%f'
#MODE_INDICATOR_REPLACE='%F{9}%F{1}[R]%f'
#MODE_INDICATOR_SEARCH='%F{13}%F{5}[S]%f'
#MODE_INDICATOR_VISUAL='%F{12}%F{4}[V]%f'
#MODE_INDICATOR_VLINE='%F{12}%F{4}[V]%f'

# Key bindings
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
if [ "$(uname)" = 'Linux' ]; then
  . /usr/share/fzf/key-bindings.zsh  # C-T for files, C-R for history, M-C for cd.
  . /usr/share/fzf/completion.zsh  # **<TAB>
else
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi
