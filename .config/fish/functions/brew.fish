# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.8QNH8s/brew.fish @ line 2
function brew
	switch (hostname -f)
	case "*.brandeis.edu"
		# Check if the command can be run without sudo.
		set -l homebrew_no_perms_cmds \
			--cache --cellar --env --prefix --repository --version \
			analytics \
			'cask --cache' 'cask audit' 'cask cat' 'cask home' 'cask info' \
			'cask list' 'cask outdated' \
			cat command commands config dep desc gist-logs help home info leaves \
			list missing outdated search shellenv tap-info unpack uses formula

		# If $argv begins with any of the elements in $homebrew_no_perms_cmds,
		# run it without sudo.
		switch "$argv"
		case $homebrew_no_perms_cmds"*"
			command brew $argv
			return
		end

		# Set up a custom environment and run brew as user homebrew.
		set BREW_PATH --path /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin
		set BREW_HOME /var/homebrew
		pushd "$BREW_HOME"
		env HOME="$BREW_HOME" PATH="$BREW_PATH" sudo -u homebrew /usr/local/bin/brew $argv
		popd
	case "*"
		# On other hosts, always use the brew command without sudo.
		command brew $argv
	end
end
