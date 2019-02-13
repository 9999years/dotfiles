# .bashrc is executed for interactive, login shells

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

eval "$(dircolors)"
export LS_OPTIONS="--color=auto"
export EDITOR=vim

## Colorize the ls output ##
alias ls='ls --color=auto'

## Use a long listing format ##
alias ll='ls -la'

## Show hidden files ##
alias l.='ls -A'

alias xrdb_merge='xrdb -merge -I$HOME ~/.Xresources'

export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
export LD_LIBRARY_PATH="$HOME/.local/lib"
export LD_RUN_PATH="$HOME/.local/lib"
export LDFLAGS="-L$HOME/.local/lib"
export CFLAGS="-I$HOME/.local/include"
export MANPATH="$HOME/.local/share/man:$HOME/.local/man:/usr/share/man"
