# Defined in /tmp/fish.aRlgQv/pathsed.fish @ line 2
function pathsed --argument find replace
    cd (pwd | sed "s~$find~$replace~")
end
