function _has_version -a expected_version
	set actual (string split . -- $FISH_VERSION)
	set expected (string split . -- $expected_version)
	set components "major" "minor" "patch"
	set err (echo -sn (set_color red) \
			"Expected Fish to have a %s version of at least %s but only have %s.\n" \
			"(Expected version $expected_version but have $FISH_VERSION)\n" \
			(set_color normal))
	for i in (seq 1 3)
		if test $actual[$i] -lt $expected[$i]
			printf "$err" $components[$i] $expected[$i] $actual[$i]
			return 1
		else if test $actual[$i] -gt $expected[$i]
			# bigger components override smaller ones
			return 0
		end
	end
end

if not _has_version 3.0.0
	exit
end

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
set PYTHON_VERSION "3.7"

set -gx PATH $LOCAL/bin $HOME/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
set -gx --path LD_LIBRARY_PATH $LOCAL/lib /usr/local/lib
set -gx --path LD_RUN_PATH $LOCAL/lib /usr/local/lib
set -gx --path MANPATH $LOCAL/share/man $LOCAL/man /usr/share/man
set -gx --path C_INCLUDE_PATH $LOCAL/include /usr/local/include
set -gx LDFLAGS "-L$LOCAL/lib -L/usr/local/lib"
set -gx CFLAGS "-I$LOCAL/include -I/usr/local/include"

if is_darwin
	set -gx RUBY_VERSION 2.3.0
	set -gx MANPATH "/Applications/Xcode.app/Contents/Developer/usr/share/man" "/usr/local/share/man" $MANPATH
	set -gx PATH $HOME/Library/Python/$PYTHON_VERSION/bin \
		/usr/local/opt/python/bin \
		/usr/local/opt/ruby/bin \
		$HOME/.gem/ruby/$RUBY_VERSION/bin \
		/usr/local/texlive/2018/bin/(uname -m)-darwin/ \
		$PATH
	#set -gx --path DYLD_LIBRARY_PATH  "$LD_LIBRARY_PATH"
	set FFI_VERSION 3.2.1
	set CAIRO_VERSION 1.16.0
	set -gx --path PKG_CONFIG_PATH \
		"/usr/local/Cellar/libffi/$FFI_VERSION/lib/pkgconfig/" \
		"/usr/local/Cellar/cairo/$CAIRO_VERSION/lib/pkgconfig/"
else
	set -gx --path LD_LIBRARY_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64 $LD_LIBRARY_PATH
	set -gx --path LD_RUN_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64
	set -gx LDFLAGS "-L$LOCAL/lib64 -L/usr/local/lib64 -L/lib64 -L/usr/lib64 $LDFLAGS"
	set -gx PATH $HOME/.cabal/bin $PATH
end

set -gx --path LIBRARY_PATH "$LD_LIBRARY_PATH"  # python build uses this
set -gx CPPFLAGS  "$CFLAGS"

abbr ll 'ls -la'
abbr l. 'ls -A'

abbr xrdb_merge 'xrdb -merge -I$HOME ~/.Xresources'
abbr build './configure --prefix="$LOCAL"; and make; and make install'
abbr diff colordiff
abbr funced 'funced --save'
abbr req 'pip3 install --user -r ./requirements.txt'
abbr pipi 'pip3 install --user'
abbr x 'chmod +x'
abbr perm 'stat -f "%A %N"'
abbr root 'sudo -u root (which fish)'
abbr pjq 'plist2json | jq'

abbr diadem 'ssh diadem'
abbr alia 'ssh alia'

if not which wget > /dev/null
	abbr wget 'curl -OL'
end
