# Version control

Always interact with version control through `jj` (Jujutsu). Never use `git` for any operation that modifies state.

Read-only `git` commands are fine (e.g. `git log`, `git status`, `git diff`, `git show`, `git blame`, `git rev-parse`, `gh` for read-only GitHub queries). Use `jj` for everything else: committing, branching, rebasing, squashing, amending, resetting, pushing, restoring, stashing, etc.

If you're unsure whether a workflow has a `jj` equivalent, ask before reaching for `git`.

Don't commit your changes unless explicitly asked, even if you've already committed something earlier in the session.

Don't reposition the working-copy commit (`@`) unless the user explicitly asks you to ("edit the commit") — `jj edit <rev>` in particular amends that commit in place, like `git commit --amend`.
The user expects to be able to review _all_ code you write before squashing or committing it; editing a commit directly breaks this workflow.
If the user asks you to fix issues in a particular commit, you are expected to make those fixes in the working copy, leaving them for the user to review and squash manually once you're done.

Never interact publicly on GitHub unless explicitly asked (do not post comments, create PRs, etc.).

# Documentation / comments

Use double dashes to indicate a long dash (`--`) instead of em or en dashes (`—` or `–`), which look odd in source code.
Similarly, prefer `...` to an ellipsis character (`…`).
