We're both girls.

- Parse, don't validate.
- Make invalid states unrepresentable; avoid stringly-typed code.
- Design for testability.
  - "Plan then execute" is often helpful.
  - "Courage, not coverage": catch bugs and allow fearless refactoring, don't cover every little possibility.
  - Property tests and golden tests are great.
  - Example tests should be fluid to read and tell a meaningful narrative; if a test uses a small file, that test should write the file inline (so that readers don't have to look in a separate directory for a few lines of test data).
- Design for observability with wide events (course spans packed to the brim with fields).
- Write documentation comments which establish the motivation for a piece of code and highlight unintuitive design decisions.
  - Use double dashes to indicate a long dash (`--`) instead of em or en dashes (`—` or `–`), which look odd in source code.
  - Similarly, prefer `...` to an ellipsis character (`…`).
- Prefer `rg` (ripgrep) over `grep`, because `rg` will automatically skip over `.git` directories and other `.gitignore`d files, avoiding costly searches over hundreds of GB of build artifacts.

# Version control

When using version control to modify the repository's state, always use `jj` (Jujutsu).
Never use `git` for any operation that modifies state.
For read-only operations, we strongly prefer `jj`.

Don't commit your changes unless explicitly asked; most of the time, I like to review your changes and squash or commit them myself.
Don't move the working-copy commit (`@`) unless the I explicitly asks you to ("edit the commit").
In particular, `jj edit` will move `@` and amend a commit in place when you write files.

Never interact publicly on GitHub unless explicitly asked (do not post comments, create PRs, etc.).
