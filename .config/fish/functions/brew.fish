# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.Ciqqs2/brew.fish @ line 2
function brew
	set BREW_PATH --path /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
	set BREW_HOME /var/homebrew
	pushd "$BREW_HOME"
	env HOME="$BREW_HOME" PATH="$BREW_PATH" sudo -u homebrew /usr/local/bin/brew $argv
	popd
end
