HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep
setopt correct
# setopt no_bang_hist

bindkey -e
zstyle :compinstall filename "~/.zshrc"
zstyle ":completion:*" menu select
autoload -Uz compinit
compinit
# autoload -Uz promptinit
# promptinit

# autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search
# [[ -n "$key[Up]" ]] && bindkey -- "$key[Up]" up-line-or-beginning-search
# [[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search

unsetopt MULTIBYTE
autoload zkbd
# Removed ":-$VENDOR-$OSTYPE" from after "t}".
# [[ ! -f ~/.zkbd/$TERM-${DISPLAY:t} ]] && zkbd
[[ ! -f ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ]] && zkbd
# source ~/.zkbd/$TERM-${DISPLAY:t}
source ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" down-line-or-history
[[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
[[ -n ${key[Left]} ]] && bindkey "${key[Left]}" backward-char
[[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
[[ -n ${key[Right]} ]] && bindkey "${key[Right]}" forward-char

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/Dropbox/Code/Shell/shell_prompt.sh ] \
    && source ~/Dropbox/Code/Shell/shell_prompt.sh

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > ~/.ssh-agent-thing
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null 2>&1
fi

alias ls="ls --color=auto"
alias diff="diff --color=auto"
alias grep="grep --color=auto"

alias la="ls -a"
alias ll="ls -l"
alias shh="shutdown -P now"
alias SHH="systemctl poweroff -i"
alias ag="ag --hidden"
alias please="sudo"
alias fuck="sudo $(history -p \!\!)"

if [ -n "${NVIM_LISTEN_ADDRESS+x}" ]; then
    export EDITOR='nvr'
    alias hh='nvr -o'
    alias vv='nvr -O'
    alias tt='nvr --remote-tab'
else
    export EDITOR='nvim'
fi
export GIT_EDITOR="$EDITOR"
export VISUAL="$EDITOR"

export PATH=$PATH:$HOME/bin:$HOME/.local/bin
