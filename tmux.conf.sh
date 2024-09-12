#!/usr/bin/env bash
set -e

if command -v fish > /dev/null
then
	tmux set -g default-shell "$(command -v fish)"
fi

bind_copy=(bind-key -T copy-mode-vi MouseDragEnd1Pane)

function tmux_bind_copy {
	tmux "${bind_copy[@]}" send-keys -X copy-pipe "$@"
}

if [[ "$(uname)" == "Darwin" ]]; then
	tmux_bind_copy pbcopy
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
	tmux_bind_copy /mnt/c/Windows/System32/clip.exe
fi

# See: `./config/home-mangler/__tmux_window_name.sh`
if command -v __tmux_window_name > /dev/null
then
    tmux set-option -g automatic-rename-format "#(__tmux_window_name #{q:pane_current_path})"
fi
