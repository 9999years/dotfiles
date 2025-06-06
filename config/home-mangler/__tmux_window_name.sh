# shellcheck shell=bash

# `tmux` lets me set the window name to `#{b:pane_current_path}`, the basename
# of the current path. However, if I'm using Git worktrees, I'll often be in a
# directory named after a branch, like `main` or `master`. This is
# uninformative.
#
# Therefore, this script prints the basename of a Git remote URL, with a
# trailing `.git` removed, so that windows are named after the repositories
# they're in.
#
# TODO:
# - Include a relative path within the repository?
# - Include a branch name, or the name of the worktree?

set -o pipefail
set -x

# `tmux` doesn't execute this script in the `pane_current_path`, so we pass it
# as an argument and `cd` to it explicitly.
if [[ -n "${1:-}" ]]; then
    cd "$1" || exit 1
fi

function repo_name_from_remote {
    local remote="$1"
    local url
    if url=$(git remote get-url "$remote" 2>/dev/null) \
        && url=$(basename "$url"); then
        # Strip a trailing `.git`.
        echo "${url%%.git}"
    else
        false
    fi
}

function repo_name {
    if repo_name_from_remote origin; then
        return
    fi

    local remote
    if remote=$(git remote 2>/dev/null | head -n1); then
        repo_name_from_remote "$remote"
    else
        false
    fi
}

function repo_name_and_dirname {
    basename=$(basename "$(pwd)")
    if repo_name=$(repo_name); then
        if [[ "$basename" != "$repo_name" ]]; then
            echo "$repo_name ($basename)"
        else
            echo "$repo_name"
        fi
    else
        echo "$basename"
    fi
}

repo_name_and_dirname \
    | sed 's/mercury-web-backend/mwb/g'
