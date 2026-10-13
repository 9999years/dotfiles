---
name: jj-hunk
description: Splits Jujutsu commits apart by hunk.
---

# Split commits with jj hunk

Prefer `jj hunk` for noninteractive hunk selection.
Target the requested revision directly with `-r`; no `jj edit` is needed.
Follow the user's requested split boundaries and existing authorization for history changes.

## Inspect and select

```sh
jj hunk list -r REV --files
jj hunk list -r REV
jj hunk list -r REV --spec-template > /tmp/...
```

The default output is JSON: file paths, hunk IDs, added/removed text, line ranges, and context. Use `-i 'glob'` / `-x 'glob'` to narrow inspection.

Edit the generated spec to retain only the files and hunk IDs for the next logical commit. Keep `"default": "reset"` so unselected changes remain for the later commit. For example (replace the illustrative ID with one from the listing):

```json
{
  "files": {
    "src/example.ts": { "ids": ["hunk-ID-FROM-LISTING"] }
  },
  "default": "reset"
}
```

Keep the spec outside the repository so it cannot enter the split. JSON and YAML specs are supported. Preview the exact selection before applying it:

```sh
jj hunk list -r REV -f /tmp/jj-hunk-selection.json --format text
jj hunk split -r REV -f /tmp/jj-hunk-selection.json 'Message for selected changes'
```

## Verify and repeat

- Selected hunks become the earlier commit and retain the original change ID.
- Remaining changes become a new child commit with a new change ID and the original description.
- Descendants are rebased. When splitting a parent, the working-copy change remains the working-copy change.
- Read the reported **Remaining changes** ID before splitting again. Do not reuse the original ID expecting it to identify the remainder. Regenerate the hunk listing/spec against the remainder.

Inspect the resulting commits with `jj show` / `jj log`. Check that each contains the intended logical change and that the combined tree is unchanged; compare the final remainder against the original commit hash recorded before splitting, using `jj diff --from ORIGINAL_HASH --to REMAINDER`.

For other operations, consult `jj hunk COMMAND --help`: `commit` commits selected working-copy hunks; `squash` moves selected changes into a parent. The `select` subcommand is the internal diff-editor entry point. `--query` and `--alias` offer a hunkset language; use the explicit spec workflow above unless its syntax is known.
