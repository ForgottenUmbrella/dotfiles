# Settings
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
unsetopt beep
setopt correct
#setopt nobanghist
bindkey -e
zstyle :compinstall filename "$ZDOTDIR/.zshrc"
zstyle ":completion:*" menu select
autoload -Uz compinit
compinit
# Disabled to use powerline instead.
#autoload -Uz promptinit
#promptinit

# Bindings
unsetopt MULTIBYTE
#autoload zkbd
#[[ ! -f "$ZDOTDIR/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}" ]] && zkbd
#source "$ZDOTDIR/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}"
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
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

# Applications
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#[ -f ~/Dropbox/Code/Shell/shell_prompt.sh ] \
#    && source ~/Dropbox/Code/Shell/shell_prompt.sh
if [ "$TERM" != "linux" ]; then
    powerline-daemon -q
    source ~/.local/lib/python3.6/site-packages/powerline/bindings/zsh/powerline.zsh
fi
#if [ -n "${NVIM_LISTEN_ADDRESS+x}" ]; then
#    export EDITOR="nvr"
#    alias hh="nvr -o"
#    alias vv="nvr -O"
#    alias tt="nvr --remote-tab"
#else
#    export EDITOR="nvim"
#fi
export SUDO_EDITOR="emacsclient -t"
export EDITOR="emacsclient -nc"
export GIT_EDITOR="$EDITOR"
export VISUAL="$EDITOR"
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    #ssh-agent > ~/.ssh-agent-thing
    ssh-agent > "$XDG_CONFIG_HOME/ssh-agent"
fi
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<$XDG_CONFIG_HOME/ssh-agent)" > /dev/null 2>&1
fi

# Aliases
alias ls="ls --color=auto"
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ag="ag --hidden --color"
alias less="less -R"
alias la="ls -a"
alias ll="ls -l"
alias shhh="shutdown -P now"
alias please="sudo"
alias fuck='sudo !!'
alias av="deactivate &> /dev/null; source venv/bin/activate"
alias dv="deactivate"
alias copy="xsel -ib"
alias sake="LC_ALL=ja_JP.UTF-8 wine"
alias wn="wine start"
alias pupdate="yay -Syu; yay -Sc --noconfirm"
alias pinstall="pupdate; yay -S"
alias updategrub="grub-mkconfig -o /boot/grub/grub.cfg"
alias mx="$EDITOR"
alias del="trash-put"
alias rm="echo 'Use del.'; false"
alias myip="ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}'"
alias gpuinfo="lspci  -v -s  $(lspci | grep ' VGA ' | cut -d" " -f 1)"
# Allow using aliases with `sudo`.
alias sudo="sudo "

# Functions
quietly () {
    nohup "$*" >/dev/null 2>&1 &
}
