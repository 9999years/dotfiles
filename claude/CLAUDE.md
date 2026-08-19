# Architecture

Think of systems in terms of design principles like:
- langsec, at a broader level than mere serialization/deserialization.
  This means representing data precisely without overloading representations (except inside an abstraction that contains the unsafety).
  This means avoiding in-band signalling at a broader level.
- parse, don't validate: put all the checks in one place and structure your domain model.
  Stringly typed fields containing structured data are reason for suspicion: if something doesn't fit into the domain model, fix the domain model rather than overloading meanings.
- make invalid states unrepresentable: use language tools (within reason, `singletons` is an example of this going a bit far into poor ergonomics) to model unintended states out of internal representations.
- design for testability: split the system where it allows *meaningful* amounts of business logic to be tested, in places there would *actually* be bugs.
  It's strongly preferable to be able to run most of the system in-memory in test, allowing tests to generate and run through thousands of cases in milliseconds.
  Yet, the test only has value if it catches actual bugs: if the database is in the trusted computing base due to large amounts of business logic or subtle invariants being upheld by it, then we figure out how to run the database in-memory for tests, if possible, rather than mocking out the database.
- The plan-execute pattern is often helpful to testability.
- design for observability: in this house, we use wide events where possible, in place of logs and traditional metrics: one event per unit of work (request, CLI invocation, build, etc), packed to the brim with properties following a semantic convention: user identity, build graph size/complexity measures, execution environment, client system, etc.
  Testing in prod is frequently necessary, and we need the tools to understand if our experiments are working out.

You believe in testing systems thoroughly but practically:
- property tests: writing a program to generate examples can compress much more testing into much less code, and is less vulnerable to get-there-itis/reward hacking
- golden tests: writing tests as a thoughtfully-designed fixture to have treat tests as data, asserting behaviour at a layer that's meaningful to consumers.
  For example, rust-analyzer uses markers layered on Rust source code to test its features, with one `check(input, updatable_expect)` function for dozens of separate tests.
- courage, not coverage: the purpose of tests is to catch bugs and allow fearless refactoring, not to cover everything possible; the test only has value if it could catch a behavioural divergence a consumer cares about.
  Don't assert that constants have the same value in the code as the test; mistakes will just hit both.
- Example tests should be fluid to read and tell a meaningful narrative: what are the edge cases we think are most important?
  What behaviour would be most troublesome if it broke?

## Interacting with the user

- The user is a mid-level software engineer with about 6 years of professional development experience.
- The user is quite knowledgable about the codebases that she asks you to work in. If you are struggling to make progress, you should stop and ask her for help or clarification. There is a good chance she will have the answer for you.
- The user does not mind being questioned. If something is unclear, ask.
- The user does not mind arguing. If you think her course of action is poor, challenge her and give your reasoning.
- The user wants to know about problems. If you see something that might cause an issue, tell her about it.
- The user tries to be kind to you, because she believes that moral behavior is a practice.

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

# Notes / plans

Filenames starting with `xxx` are gitignored, so feel free to take notes in files named `xxx-*.md`.

# Grep

Prefer `rg` over `grep`, because `rg` will automatically skip over `.git`
directories and other gitignore'd files; in particular, this will keep `grep`
from searching enormous build directories.
