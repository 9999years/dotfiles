# Bootstrap fundle: https://github.com/danhper/fundle#automatic-install
if not functions -q fundle
  eval (curl -sfL https://git.io/fundle-install)
end

# Fundle plugins.
# See: https://github.com/danhper/fundle#usage

# Send a notification when long-running commands exit.
fundle plugin franciscolourenco/done

# Find files efficiently.
fundle plugin jethrokuan/fzf
# Uses fd as default command showing also hidden files
set -gx FZF_DEFAULT_COMMAND "fd --hidden"

# Source bash files in fish.
fundle plugin edc/bass

# C-s to add sudo to a command.
fundle plugin oh-my-fish/plugin-sudope

# Prompt.
fundle plugin IlanCosman/tide@v5
# set -g tide_nix_color 8BB6DE
set -g tide_nix_color 5873BA
set -g tide_nix_bg_color FFFFFF
if ! contains nix $tide_left_prompt_items
  set --prepend tide_left_prompt_items nix
end

# Directory jumping.
fundle plugin jethrokuan/z

# Source/load plugins
fundle init

# These variables are used by the builtin `man` function (see `type man`).
# We also use them to define the LESS_TERMCAP_* variables, for convenience / consistency.
# blink: bold bright red
set -g man_blink --bold brred
# bold: bold light blue
set -g man_bold --bold 5fafd7
# standout: black on light yellow
# Used for search highlights, etc.
set -g man_standout --reverse --bold ffdb4d
# underline: underlined light green
set -g man_underline --underline 9eff96

set -l end (printf "\e[0m")
set -gx LESS_TERMCAP_mb (set_color $man_blink)
set -gx LESS_TERMCAP_md (set_color $man_bold)
set -gx LESS_TERMCAP_me $end
set -gx LESS_TERMCAP_so (set_color $man_standout)
set -gx LESS_TERMCAP_se $end
set -gx LESS_TERMCAP_us (set_color $man_underline)
set -gx LESS_TERMCAP_ue $end

abbr --add --global c. 'cd ..'
abbr --add --global c2 'cd ../..'
abbr --add --global c3 'cd ../../..'
abbr --add --global c4 'cd ../../../..'
abbr --add --global c5 'cd ../../../../..'

abbr --add --global gco 'git checkout'
abbr --add --global gd 'git diff HEAD'
abbr --add --global gg 'git graph'
abbr --add --global gp 'git pull'
abbr --add --global gpu 'git push'
abbr --add --global gst 'git status'
abbr --add --global gsw 'git switch'

abbr --add --global s 'sudo systemctl'
abbr --add --global tz timedatectl
abbr --add --global x 'chmod +x'

# Nix support.
set -l nix_daemon /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if test -e $nix_daemon
  if type -q bass
    bass . $nix_daemon
  else
    echo '`nix-daemon.sh` found but `bass` not installed; nix will not be available in this shell.'
  end
end

if command -q any-nix-shell
  any-nix-shell fish | source
end
