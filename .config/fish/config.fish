__init_fisher
__preserve_origs PATH LD_LIBRARY_PATH LD_RUN_PATH LDFLAGS CFLAGS

set -g pisces_only_insert_at_eol 1
set -g __done_min_cmd_duration 30000

set -gx GOPATH ~/.go
set -gx VOLTA_HOME ~/.volta

__add_to_path_if_exists PATH \
    ~/.cargo/bin \
    $VOLTA_HOME/bin \
    ~/.rvm/bin \
    $GOPATH/bin \
    ~/.cabal/bin

if test -n "$IN_NIX_SHELL"
    if test -z "$NIX_SHELL_DEPTH"
        set -gx NIX_SHELL_DEPTH 1
    else
        set -gx NIX_SHELL_DEPTH (math "$NIX_SHELL_DEPTH + 1")
    end
end

if not is_nixos
    # Do we have a local Nix profile?
    set nix_profile ~/.nix-profile/etc/profile.d/nix.sh
    if test -e $nix_profile
        if type -q bass
            bass . $nix_profile
        else
            echo -s (set_color --bold brred) "bass function not found; make sure to run fisher to make Nix functions available (or source $nix_profile in a parent shell...)" (set_color normal)
        end
    end

    __add_to_path_if_exists PATH \
        ~/.nix-profile/bin \
        /usr/local/linkedin/bin \
        /export/content/linkedin/bin \
        (if is_wsl; echo ~linuxbrew/.linuxbrew/bin; end) \
        /usr/local/bin \
        /usr/local/sbin \
        /usr/bin \
        /usr/sbin \
        /bin \
        /sbin

    for lib_path in LD_LIBRARY_PATH LD_RUN_PATH
        __add_to_path_if_exists $lib_path \
            /usr/local/lib64 \
            /usr/local/lib \
            /usr/lib64 \
            /lib64
    end

    __add_to_path_if_exists C_INCLUDE_PATH \
        /usr/local/include

    __add_to_path_if_exists MANPATH \
        (if is_darwin; echo /Applications/Xcode.app/Contents/Developer/usr/share/man; end) \
        (if is_wsl; echo ~linuxbrew/.linuxbrew/share/man; end) \
        /usr/local/share/man \
        /usr/share/man

    __add_to_path_if_exists PKG_CONFIG_PATH \
        ~linuxbrew/.linuxbrew/lib/pkgconfig \
        ~linuxbrew/.linuxbrew/opt/openssl@1.1/lib/pkgconfig

    if is_linkedin
        set fish_complete_path $fish_complete_path /usr/local/linkedin/fish
        set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/jdk1.8.0_172-zulu.jdk/Contents/Home/
    end

    if is_darwin || is_wsl
        set -gx LDFLAGS "-L/usr/local/lib $__orig_LDFLAGS"
        set -gx CFLAGS "-I/usr/local/include $__orig_CFLAGS"
    end

    if is_darwin
        set -gx RUBY_VERSION 2.6.0
        #set -gx --path DYLD_LIBRARY_PATH  "$LD_LIBRARY_PATH"
        set sdk (xcrun --show-sdk-path)
        if test ! -z "$sdk"
            set -gx --path C_INCLUDE_PATH $sdk/usr/include $C_INCLUDE_PATH
            set -gx --path LD_LIBRARY_PATH $sdk/usr/lib $LD_LIBRARY_PATH
        end
        set FFI_VERSION 3.2.1
        set CAIRO_VERSION 1.16.0
        set -gx --path PKG_CONFIG_PATH \
            "/usr/local/Cellar/libffi/$FFI_VERSION/lib/pkgconfig/" \
            "/usr/local/Cellar/cairo/$CAIRO_VERSION/lib/pkgconfig/"

        # Interferes with left- and right-word keyboard shortcuts for some reason.
        bind --erase \e\e

    else if is_wsl
        umask 022
        set fish_complete_path /home/linuxbrew/.linuxbrew/share/fish/vendor_completions.d $fish_complete_path
        set -gx LDFLAGS "-L/usr/local/lib64 -L/lib64 -L/usr/lib64 $LDFLAGS"
        set -gx TEXMFS $HOME/.miktex/texmfs/install/
        set -gx WINHOME "/mnt/c/Users/$USER"
    end
end

if command -v nvim >/dev/null
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end

set -gx FISHRC "$HOME/.config/fish/config.fish"
set -gx PYTHONSTARTUP "$HOME/.pythonrc"
set PYTHON_VERSION "3.7"
set -gx --path LIBRARY_PATH "$LD_LIBRARY_PATH"  # python build uses this
set -gx CPPFLAGS  "$CFLAGS"

# Fish seems to overwrite these if the'yre regular functions in `./functions`,
# so we keep them here.
function ls --description 'list files' --wraps exa
    if command -v exa >/dev/null
        command exa -la $argv
    else
        command ls -la $argv
    end
end

function ll --description 'list files' --wraps exa
    ls -la $argv
end

# Programs I forget:
abbr -g mdv mdcat
abbr -g cloc tokei

# Abbreviations
abbr -g cl clear
abbr -g ca cargo

# cd
abbr -g c1 'cd ..'
abbr -g c2 'cd ../..'
abbr -g c3 'cd ../../..'
abbr -g c4 'cd ../../../..'
abbr -g c5 'cd ../../../../..'
abbr -g c6 'cd ../../../../../..'
abbr -g c 'cd ..'
abbr -g c. 'cd ..'

# Adding arguments
abbr -g df 'df -h'
abbr -g funced 'funced --save'
abbr -g lt 'll -snew'  # exa sorted by date; newest last
abbr -g perm 'stat -f "%A %N"'
abbr -g root 'sudo -u root (which fish)'
abbr -g s 'sudo systemctl restart'
abbr -g x 'chmod +x'
abbr -g xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'

# miktex stuff
abbr -g mpm 'sudo mpm --admin --verbose'
abbr -g initexmf 'sudo initexmf --admin --verbose'

# Git
abbr -g gr 'cd (git-repo-root)' # git root
abbr -g gst 'git status'
abbr -g gp 'git pull'
abbr -g gpu 'git push'
abbr -g gd 'git diff HEAD'
abbr -g gdt 'git diff (git-tracking-branch) HEAD'
abbr -g gco 'git checkout'
abbr -g gc 'git commit'
abbr -g gg 'git graph'
abbr -g gl 'git log --stat --graph'
abbr -g gsw 'git switch'
