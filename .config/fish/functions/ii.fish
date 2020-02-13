# Defined in - @ line 2
function ii --argument path
	if test -z "$path"
        set -l path "$PWD"
    end
    if command -v explorer.exe >/dev/null
        explorer.exe (wslpath -w "$path")
    else if command -v xdg-open >/dev/null
        xdg-open "$path"
    end
end
