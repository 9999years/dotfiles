# Defined in /tmp/fish.s9LFla/ii.fish @ line 2
function ii --argument path
    if test -z "$path"
        set -l path "$PWD"
    end
    if command -v explorer.exe >/dev/null
        # Windows WSL
        explorer.exe (wslpath -w "$path")
    else if command -v xdg-open >/dev/null
        # Linux
        xdg-open "$path"
    else
        # MacOS
        open "$path"
    end
end
