#!/bin/bash

if which fish
then
	tmux set -g default-shell "$(which fish)"
fi
