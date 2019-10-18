# Defined in /var/folders/zz/zyxvpxvq6csfxvn_n0001mw8000d72/T//fish.CRkKPF/upstream.fish @ line 1
function upstream
	set -l branch (git rev-parse --abbrev-ref HEAD)
    set -l remote (git remote | head -n 1)
    echo -e "\e[1m\e[4mgit push --set-upstream $remote $branch\e[0m"
    git push "--set-upstream" $remote $branch
end
