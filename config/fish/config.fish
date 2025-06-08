# Bootstrap fundle: https://github.com/danhper/fundle#automatic-install
if not functions -q fundle
    eval (curl -sfL https://git.io/fundle-install)
end

# Fundle plugins.
# See: https://github.com/danhper/fundle#usage

# Send a notification when long-running commands exit.
fundle plugin franciscolourenco/done
# See: https://github.com/franciscolourenco/done#settings
set -g __done_exclude 'vi|man|less|journalctl|nix-shell|git (?!push|pull)'

# Find files efficiently.
# Ctrl-o to find a file and insert into the command line.
# Ctrl-r to search history.
# Alt-c to cd into a sub-directory.
# Alt-o to open a file in $EDITOR.
# Alt-Shift-o to open a file.
fundle plugin jethrokuan/fzf
# Uses fd as default command showing also hidden files
set -gx FZF_DEFAULT_COMMAND "fd --hidden"
set -gx FZF_LEGACY_KEYBINDINGS 0

# Source bash files in fish.
fundle plugin edc/bass
abbr --add --global replay bass

# Prompt.
fundle plugin IlanCosman/tide

# Directory jumping.
fundle plugin jethrokuan/z

# Automatically complete pairs of brackets/quotes.
fundle plugin jorgebucaran/autopair.fish

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

set -gx MANPAGER 'nvim +Man!'
set -gx PYTHONSTARTUP ~/.pythonrc
set -gx RIPGREP_CONFIG_PATH ~/.ripgreprc

abbr --add --global c. 'cd ..'
abbr --add --global c2 'cd ../..'
abbr --add --global c3 'cd ../../..'
abbr --add --global c4 'cd ../../../..'
abbr --add --global c5 'cd ../../../../..'

abbr --add --global gco 'git checkout'
abbr --add --global gd 'git diff HEAD'
abbr --add --global gdm 'git diff --merge-base'
abbr --add --global gg 'git graph'
abbr --add --global gp 'git pull'
abbr --add --global gpu 'git push'
abbr --add --global gle 'git leash'
abbr --add --global gst 'git status'
abbr --add --global gsw 'git switch'

abbr --add --global v nvim
abbr --add --global s 'sudo systemctl'
abbr --add --global tz timedatectl
abbr --add --global x 'chmod +x'
abbr --add --global tree 'eza --tree --level 2'

# Fish still seems to overwrite user-defined functions for `ls` and `ll`, so these live here.

function ls --wraps eza -d 'List files'
    if command -q eza
        eza -l $argv
    else
        command ls -l $argv
    end
end

function ll --wraps eza -d 'List files, including hidden files'
    if command -q eza
        eza -la $argv
    else
        command ls -la $argv
    end
end

# Add extra `$PATH` variables.
fish_add_path \
    /opt/homebrew/bin \
    ~/.ghcup/bin \
    ~/.cabal/bin \
    ~/.cargo/bin

# Nix support.
set -l nix_daemon /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
if test -e $nix_daemon
    if type -q bass
        bass . $nix_daemon
    else
        echo 'Found `nix-daemon.sh` but `bass` not installed; nix will not be available in this shell.' >&2
    end
    set -g --append fish_complete_path \
        ~/.nix-profile/share/fish/vendor_completions.d \
        ~/.nix-profile/share/fish/completions
    set -g --append fish_function_path \
        ~/.nix-profile/share/fish/vendor_functions.d \
        ~/.nix-profile/share/fish/functions
    # https://github.com/fish-shell/fish-shell/issues/10078#issuecomment-1786490675
    for file in ~/.nix-profile/share/fish/vendor_conf.d/*.fish
        source $file
    end
end

if command -q nix-your-shell
    nix-your-shell fish | source
end

if command -q nvim
    set --global --export EDITOR nvim
end

prepend-nix-store-paths
