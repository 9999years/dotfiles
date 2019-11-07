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

function is_wsl
	test ! -z "$WSL_DISTRO_NAME"
end

set -g fisher_path "$HOME/.config/fisher_local"

if not contains $fisher_path/functions $fish_function_path
	set fish_function_path \
		$fish_function_path[1] \
		$fisher_path/functions \
		$fish_function_path[2..-1]
end

if not contains $fisher_path/completions $fish_complete_path
	set fish_complete_path \
		$fish_complete_path[1] \
		$fisher_path/completions \
		$fish_complete_path[2..-1]
end

for file in $fisher_path/conf.d/*.fish
	builtin source $file 2> /dev/null
end

set -U pisces_only_insert_at_eol 1

if is_darwin
	set LOCAL "$HOME/.local/.darwin"
else
	set LOCAL "$HOME/.local"
end

umask 022

set -gx FISHRC "$HOME/.config/fish/config.fish"
set -gx WINHOME "/mnt/c/Users/$USER"
set -gx LS_OPTIONS "--color=auto"
set -gx EDITOR vim
set -gx NODE_PATH "$LOCAL/lib/node_modules"
set -gx PYTHONSTARTUP "$HOME/.pythonrc"
set -gx GOPATH "$HOME/.go"
set PYTHON_VERSION "3.7"
set -g set __done_min_cmd_duration 60000

set -gx PATH $LOCAL/bin $HOME/.cargo/bin $HOME/.rvm/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
set -gx --path LD_LIBRARY_PATH $LOCAL/lib /usr/local/lib
set -gx --path LD_RUN_PATH $LOCAL/lib /usr/local/lib
set -gx --path MANPATH $LOCAL/share/man $LOCAL/man /usr/share/man
set -gx --path C_INCLUDE_PATH $LOCAL/include /usr/local/include
set -gx LDFLAGS "-L$LOCAL/lib -L/usr/local/lib"
set -gx CFLAGS "-I$LOCAL/include -I/usr/local/include"
set -gx TEXMFS $HOME/.miktex/texmfs/install/

set -g pure_symbol_prompt "⟩"
set -g pure_symbol_reverse_prompt "⟨"

if is_darwin
	set -gx RUBY_VERSION 2.3.0
	set -gx MANPATH "/Applications/Xcode.app/Contents/Developer/usr/share/man" "/usr/local/share/man" $MANPATH
	set -gx PATH $HOME/Library/Python/$PYTHON_VERSION/bin \
		/usr/local/opt/ruby/bin \
		$HOME/.gem/ruby/$RUBY_VERSION/bin \
		/usr/local/texlive/2018/bin/(uname -m)-darwin/ \
		$PATH \
		/usr/local/opt/python/bin
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
else
	set -gx --path MANPATH /home/linuxbrew/.linuxbrew/share/man/ $MANPATH
	set -gx --path LD_LIBRARY_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64 $LD_LIBRARY_PATH
	set -gx --path LD_RUN_PATH $LOCAL/lib64 /usr/local/lib64 /lib64 /usr/lib64
	set -gx LDFLAGS "-L$LOCAL/lib64 -L/usr/local/lib64 -L/lib64 -L/usr/lib64 $LDFLAGS"
	if not contains $HOME/.cabal/bin $PATH
		set -gx PATH \
			$HOME/.cabal/bin \
			/home/linuxbrew/.linuxbrew/bin \
			$PATH \
			/mnt/c/Windows
	end
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
# git root
abbr gr 'cd (git rev-parse --show-toplevel)'
abbr c1 'cd ..'
abbr c2 'cd ../..'
abbr c3 'cd ../../..'
abbr c4 'cd ../../../..'
abbr c5 'cd ../../../../..'
abbr c6 'cd ../../../../../..'

# miktex stuff
abbr mpm 'sudo mpm --admin --verbose'
abbr initexmf 'sudo initexmf --admin --verbose'

abbr gst 'git status'
abbr gp 'git pull'
abbr gpu 'git push'

if not command -v wget > /dev/null
	abbr wget 'curl -OL'
end
