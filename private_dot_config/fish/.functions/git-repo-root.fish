# Defined in /var/folders/dm/2kd_hgp51qx5v41_4ct5c8tw001d24/T//fish.JN2zeF/git-repo-root.fish @ line 1
function git-repo-root --description 'Prints the root directory of the current git repository'
    git rev-parse --show-toplevel
end
