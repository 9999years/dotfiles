# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.DpRO5B/git-tracking-branch.fish @ line 1
function git-tracking-branch --description 'Prints the name of the branch the current branch is tracking'
    git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
end
