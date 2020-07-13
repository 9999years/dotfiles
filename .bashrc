#! /bin/bash
# .bashrc is executed for interactive, login shells

if [[ "$SHELL" != *fish && -x "$HOME/.nix-profile/bin/fish" ]]
then
    exec "$HOME/.nix-profile/bin/fish"
elif [[ "$SHELL" != *fish ]] && command -v fish > /dev/null
then
    exec fish
fi

# Source global definitions
if [ -f /etc/bashrc ]
then
	. /etc/bashrc
fi

if [[ $(uname) == "Darwin" ]]
then
	alias ls='ls -G'
else
	export LS_OPTIONS="--color=auto"
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

if command -v dircolors > /dev/null
then
	eval "$(dircolors)"
fi

export LC_CTYPE=en_US.UTF-8
export EDITOR=nvim

alias ls=exa
alias cat=bat

## Use a long listing format ##
alias ll='ls -la'

## Show hidden files ##
alias l.='ls -A'
alias xrdb_merge='xrdb -merge -I$HOME ~/.Xresources'
alias root='sudo -u root $(which fish)'
alias alia_shell='sudo bash -c "source ~/ssh-agent-data && $(which fish)"'

complete -C /usr/local/bin/vault vault

function show_args() {
    local i=1
    local reset="$(echo -en "\033[0m")"
    local gray="$(echo -en "\033[90m")"
    local green="$(echo -en "\033[92m")"
    for arg in "$@"
    do
        echo "$gray\$$i:$reset $green$arg$reset"
        (( i++ ))
    done
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]
then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
