# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.N0mvlV/brew_sudo.fish @ line 2
function brew_sudo
	set BREW_PATH --path /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
    set BREW_HOME /var/homebrew
    pushd "$BREW_HOME"
    env HOME="$BREW_HOME" PATH="$BREW_PATH" sudo -u homebrew $argv
    popd
end
