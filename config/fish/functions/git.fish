# Defined in /tmp/fish.bId4r0/git.fish @ line 2
function git --wraps=hub
    if command -v hub >/dev/null
        hub $argv
    else
        command git $argv
    end
end
