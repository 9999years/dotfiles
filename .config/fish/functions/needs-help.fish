# Defined in /tmp/fish.Bvh5KX/needs-help.fish @ line 6
function needs-help
	for arg in $argv
		switch $arg
			case --help -h
				return 1
		end
	end
end
