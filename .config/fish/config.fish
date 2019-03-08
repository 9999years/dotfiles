function is_darwin
	test (uname) = "Darwin"
end

if is_darwin
	set LOCAL "$HOME/.local/.darwin"
else
	set LOCAL "$HOME/.local"
end

set -gx FISHRC "$HOME/.config/fish/config.fish"
set -gx LS_OPTIONS "--color=auto"
set -gx EDITOR vim
set -gx NODE_PATH "$LOCAL/lib/node_modules"
set -gx PYTHONSTARTUP "$HOME/.pythonrc"
set -gx GOPATH "$HOME/.go"

set -gx PATH $LOCAL/bin $HOME/.cabal/bin $HOME/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
set -gx --path LD_LIBRARY_PATH $LOCAL/lib /usr/local/lib
set -gx --path LD_RUN_PATH $LOCAL/lib /usr/local/lib
set -gx --path MANPATH $LOCAL/share/man $LOCAL/man /usr/share/man
set -gx --path C_INCLUDE_PATH $LOCAL/include /usr/local/include
set -gx LDFLAGS "-L$LOCAL/lib -L/usr/local/lib"
set -gx CFLAGS "-I$LOCAL/include -I/usr/local/include"

if is_darwin
	set -gx MANPATH "/Applications/Xcode.app/Contents/Developer/usr/share/man" $MANPATH
else
	set -gx --path LD_LIBRARY_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64 $LD_LIBRARY_PATH
	set -gx --path LD_RUN_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64
	set -gx LDFLAGS "-L$LOCAL/lib64 -L/usr/local/lib64 -L/lib64 -L/usr/lib64 $LDFLAGS"
end

set -gx --path LIBRARY_PATH "$LD_LIBRARY_PATH"  # python build uses this
set -gx --path DYLD_LIBRARY_PATH  "$LD_LIBRARY_PATH"
set -gx CPPFLAGS  "$CFLAGS"

abbr ll 'ls -la'
abbr l. 'ls -A'

abbr xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'
abbr build './configure --prefix="$LOCAL"; and make; and make install'
abbr diff colordiff
abbr diadem 'ssh guru@diadem.cs.brandeis.edu'
abbr funced 'funced --save'
abbr req 'pip3 install --user -r ./requirements.txt'
abbr pipi 'pip3 install --user'
abbr x 'chmod +x'

if not which wget
	abbr wget 'curl -OL'
end
