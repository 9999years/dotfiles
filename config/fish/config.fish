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

# `cd ..`.
abbr --add c. 'cd ..'
abbr --add c2 'cd ../..'
abbr --add c3 'cd ../../..'
abbr --add c4 'cd ../../../..'
abbr --add c5 'cd ../../../../..'

# Git.
abbr --add gco 'git checkout'
abbr --add gd 'git diff HEAD'
abbr --add gdm 'git diff --merge-base'
abbr --add gg 'git graph'
abbr --add gp 'git pull'
abbr --add gpu 'git push'
abbr --add gle 'git leash'
abbr --add gst 'git status'
abbr --add gsw 'git switch'

# Jujutsu.
abbr --add jc 'jj commit'
abbr --add jco 'jj restore'
abbr --add jd 'jj diff'
abbr --add je 'jj edit'
abbr --add jf 'jj git fetch'
abbr --add jg 'jj log --revisions ::@'
abbr --add jn 'jj new'
abbr --add jpu 'jj git push'
abbr --add jr 'jj rebase'
abbr --add js 'jj split'
abbr --add jsp 'jj split'
abbr --add jsq 'jj squash'
abbr --add jst 'jj status'
abbr --add jt 'jj tug'

# Nix.
abbr --add nb 'nix build'
abbr --add nd 'nix develop'
abbr --add nf 'nix flake update'
abbr --add nr 'nix run'
abbr --add ns 'nix shell'
abbr --add np 'nix path-info'
abbr --add nd 'nix derivation show'

abbr --add v nvim
abbr --add s 'sudo systemctl'
abbr --add tz timedatectl
abbr --add x 'chmod +x'
abbr --add tree 'eza --tree --level 2'

abbr --add ffprobe 'ffprobe -hide_banner'
abbr --add ffmpeg 'ffmpeg -hide_banner'
abbr --add yt-dlp 'yt-dlp --extract-audio --audio-quality 0'

bind ctrl-w backward-kill-word

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
fish_add_path --global \
    /opt/homebrew/bin \
    ~/.ghcup/bin \
    ~/.cabal/bin \
    ~/.cargo/bin

# Why does Nix use space-delimited profiles??
# These are already in the `$PATH`, but we want them at the front.
for profile in (string split " " "$NIX_PROFILES")
    fish_add_path --global "$profile/bin"
end


# Nix support.
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

if command -q nix-your-shell
    nix-your-shell fish | source
end

if command -q nvim
    set --global --export EDITOR nvim
end

prepend-nix-store-paths
