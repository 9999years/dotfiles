# Defined in /tmp/fish.2prPEp/needs-help.fish @ line 2
function needs-help
	for arg in $argv
		switch $arg
			case --help -h
				return 0
		end
	end
	return 1
end
