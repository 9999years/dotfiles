# .bashrc is executed for interactive, login shells

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

eval "$(dircolors)"
export LS_OPTIONS="--color=auto"

## Colorize the ls output ##
alias ls='ls --color=auto'

## Use a long listing format ##
alias ll='ls -la'

## Show hidden files ##
alias l.='ls -A'

alias xrdb_merge='xrdb -merge -I$HOME ~/.Xresources'

PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
export PATH
