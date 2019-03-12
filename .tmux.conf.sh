#!/bin/bash

if which fish > /dev/null
then
	tmux set -g default-shell "$(which fish)"
fi

if [[ `uname` == "Darwin" ]]
then
	tmux bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"
fi
