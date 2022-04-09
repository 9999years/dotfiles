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

# Uses fd as default command showing also hidden files
set -Ux FZF_DEFAULT_COMMAND "fd --hidden"

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

abbr --add --global ll 'exa -la'
abbr --add --global ls 'exa -l'

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
