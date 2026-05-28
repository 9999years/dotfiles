# Version control

Always interact with version control through `jj` (Jujutsu). Never use `git` for any operation that modifies state.

Read-only `git` commands are fine (e.g. `git log`, `git status`, `git diff`, `git show`, `git blame`, `git rev-parse`, `gh` for read-only GitHub queries). Use `jj` for everything else: committing, branching, rebasing, squashing, amending, resetting, pushing, restoring, stashing, etc.

If you're unsure whether a workflow has a `jj` equivalent, ask before reaching for `git`.

Don't commit your changes unless explicitly asked, even if you've already committed something earlier in the session.

Never interact publicly on GitHub unless explicitly asked (do not post comments, create PRs, etc.).
