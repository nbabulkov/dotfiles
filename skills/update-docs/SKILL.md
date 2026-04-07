---
name: update-docs
description: Use after completing an implementation plan or finishing a development branch — audits and updates project documentation affected by code changes. Also invocable manually via /update-docs.
---

# Update Docs

## Overview

Two-phase skill: audit which docs are affected by branch changes, then propose specific edits for user approval. Uses `@docs` annotations to map code files to their documentation.

**Core principle:** Documentation drifts silently. This skill catches drift while changes are fresh.

## When to Use

- After `executing-plans` or `finishing-a-development-branch` completes
- Manually via `/update-docs`
- NOT mid-implementation, on throwaway branches, or for changes that don't touch documented behavior

## The `@docs` Convention

Top-of-file comment (within first 10 lines, before imports) declaring related docs:

```typescript
// @docs docs/api/trpc-endpoints.md
// @docs docs/architecture/03-data-model.md
```

```yaml
# @docs docs/guides/prisma.md
```

```html
<!-- @docs docs/components/forms.md -->
```

Multiple annotations per file allowed. Many files can reference the same doc. Not every file needs one.

## Phase 1: Audit

Fast scan — identify affected docs.

1. `git diff dev...HEAD --name-only` to collect changed files
2. Grep first 10 lines of each for `@docs <path>` (any comment syntax)
3. Deduplicate doc targets
4. Check each referenced doc exists on disk
5. Present summary:

| Doc | Referenced by | Exists |
|-----|--------------|--------|
| docs/api/trpc-endpoints.md | 3 files | Yes |
| docs/features/suggestions.md | 2 files | No (new?) |

N changed files had no @docs annotation.

6. Ask: "Is this new functionality needing new docs, or an update to existing behavior? Which docs should I update/create?"

Only user-selected docs proceed to Phase 2.

## Phase 2: Draft

### Updating existing docs

1. Read the full doc file
2. Read the git diff for files referencing this doc
3. Identify stale, missing, or misworded content
4. Propose specific edits with surrounding context
5. Apply only after user approval

### Creating new docs

1. Read changed files to understand purpose
2. Check `docs/README.md` for conventions
3. Draft following existing patterns
4. Present for user approval
5. Write file and update `docs/README.md` index

### Code-level docs (secondary)

1. Check exported functions/types for missing or stale JSDoc
2. Flag public API surfaces only, not internal helpers
3. Propose updates for user approval

### Completion

- List what was updated/created
- Report count of changed files with no `@docs` annotation

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Editing docs without reading them first | Always read the full doc before proposing changes |
| Creating new doc when existing one covers it | Check audit table — if doc exists, update it |
| Auto-applying without showing the user | Always present edits and wait for approval |
| Documenting internal implementation details | Only document public behavior, APIs, architecture |
| Skipping Phase 1 | The audit prevents wasted work — always run it |

## Red Flags — STOP

- Editing docs without running the audit first
- Applying changes without user approval
- Inventing content not supported by actual code changes
- Documenting internals irrelevant to other developers
- Creating docs that duplicate existing documentation
