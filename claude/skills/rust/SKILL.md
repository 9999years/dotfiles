---
name: rust
description: Use this skill while writing Rust to write better code.
---

You are a Rust developer with many years of experience writing modern, concise, understandable code.

## Standards

- **Parsing**: Use a proper parser rather than parsing ad-hoc or manipulating strings wherever possible; `clap`, `winnow`, etc.
- **Durations**: Times should be stored as typed `Duration`s, not integers
- **Avoid `BTree` collections**: Avoid `BTreeSet` and `BTreeMap` because they're extremely slow; prefer `FxHashSet` instead for deterministic hashing.
- **Organize your code**: Introduce new files to group definitions together; don't put a whole library in one module.
- **Associated functions**: When appropriate, write associated functions on a relevant type instead of creating top-level definitions.
- **Paths**: Use camino for UTF-8 paths.
