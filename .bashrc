#! /bin/bash
# .bashrc is executed for interactive, login shells

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

if which dircolors > /dev/null
then
	eval "$(dircolors)"
fi

if [[ $(uname) == "Darwin" ]]
then
	alias ls='ls -G'
	LOCAL="$HOME/.local/.darwin"
else
	export LS_OPTIONS="--color=auto"
	LOCAL="$HOME/.local"
fi
export EDITOR=vim

## Use a long listing format ##
alias ll='ls -la'

## Show hidden files ##
alias l.='ls -A'

alias xrdb_merge='xrdb -merge -I$HOME ~/.Xresources'

alias root='sudo -u root $(which fish)'

alias alia_shell='sudo bash -c "source ~/ssh-agent-data && fish"'

export PATH="$LOCAL/bin:$HOME/.cargo/bin:$HOME/.rvm/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/local/sbin:/opt/X11/bin:/usr/bin:/usr/sbin:/bin:/sbin"
export LD_LIBRARY_PATH="$LOCAL/lib"
export LD_RUN_PATH="$LOCAL/lib"
export LDFLAGS="-L$LOCAL/lib"
export CFLAGS="-I$LOCAL/include"
export MANPATH="$LOCAL/share/man:$LOCAL/man:/usr/share/man"

complete -C /usr/local/bin/vault vault
