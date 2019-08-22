#!/bin/bash
set -e

if command -v fish > /dev/null
then
	tmux set -g default-shell "$(command -v fish)"
fi

uname="$(uname)"

bind_copy=(bind-key -T copy-mode-vi MouseDragEnd1Pane)

function tmux_bind_copy {
	tmux "${bind_copy[@]}" send-keys -X copy-pipe-and-cancel "$@"
}

function is_wsl {
	[[ ! -z "$WSL_DISTRO_NAME" ]]
}

if [[ "$uname" == "Darwin" ]]
then
	tmux_bind_copy pbcopy
fi

if is_wsl
then
	tmux_bind_copy /mnt/c/Windows/System32/clip.exe
fi
