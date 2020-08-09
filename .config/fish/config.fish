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

if not is_nixos
    # Do we have a local Nix profile?
    set nix_profile ~/.nix-profile/etc/profile.d/nix.sh
    if test -e $nix_profile && type -q bass
        bass . $nix_profile
    end

    __add_to_path_if_exists PATH \
        /usr/local/linkedin/bin \
        /export/content/linkedin/bin \
        ~/.nix-profile/bin \
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

abbr cl clear
abbr lt 'll -snew'  # exa sorted by date; newest last
abbr df 'df -h'
abbr mdv mdcat
abbr cloc tokei
abbr xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'
abbr funced 'funced --save'
abbr x 'chmod +x'
abbr perm 'stat -f "%A %N"'
abbr root 'sudo -u root (which fish)'
abbr c 'cd ..'
abbr c. 'cd ..'
abbr c1 'cd ..'
abbr c2 'cd ../..'
abbr c3 'cd ../../..'
abbr c4 'cd ../../../..'
abbr c5 'cd ../../../../..'
abbr c6 'cd ../../../../../..'

# miktex stuff
abbr mpm 'sudo mpm --admin --verbose'
abbr initexmf 'sudo initexmf --admin --verbose'

abbr gr 'cd (git rev-parse --show-toplevel)' # git root
abbr gst 'git status'
abbr gp 'git pull'
abbr gpu 'git push'
abbr gd 'git diff HEAD'
abbr gco 'git checkout'
abbr gcl 'git clone'
abbr gc 'git commit'
abbr gg 'git graph'
abbr gl 'git log --stat --graph'
