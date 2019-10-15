# Defined in /tmp/fish.CVp8Ic/ii.fish @ line 1
function ii --argument path
	if test -z "$path"
        set -l path .
    end
    explorer.exe (wslpath -w "$path")
end
