# Defined in /tmp/fish.tLKluO/upstream.fish @ line 1
function upstream --description 'set the git branch upstream to first remote'
    set -l branch (git rev-parse --abbrev-ref HEAD)
    set -l remote (git remote | head -n 1)
    echo (set_color --bold --underline white)"git push --set-upstream $remote $branch"(set_color normal)
    git push --set-upstream $remote $branch
end
