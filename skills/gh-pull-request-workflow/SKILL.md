---
name: gh-pull-request-workflow
description: Use when working with GitHub PRs via CLI - fetching review comments, tracking fixes, creating PRs, or viewing comment threads
---

# gh Pull Request Workflow

## When to Use

- Fetching review comments from a PR to work through systematically
- Creating a new PR from the command line
- Viewing specific comment threads or conversations
- Generating a tracking checklist from PR comments

Don't use for general git operations, GitHub Actions, or repo administration.

## Script

All operations are handled by the wrapper script at:

```
~/.claude/skills/gh-pull-request-workflow/pr-workflow.sh
```

| Command | Description |
|---|---|
| `pr-workflow.sh comments [--pr <N>]` | Human-readable PR comments |
| `pr-workflow.sh review-comments [--pr <N>]` | Inline code review comments as JSON (`{path, line, body, author}`) |
| `pr-workflow.sh track [--pr <N>]` | Generate markdown checklist from review comments |
| `pr-workflow.sh diff [--base <branch>]` | Show commits + diff stat (default base: `main`) |
| `pr-workflow.sh status` | Check if PR exists for current branch |
| `pr-workflow.sh create --title <T> [--body <B>] [--base <B>]` | Create a new PR |

If `--pr` is omitted, the script auto-detects from the current branch.

## Quick gh Commands

These are simple enough to use directly (no script needed):

```bash
gh pr view --web              # Open PR in browser
gh pr view 123                # View PR details
gh pr checkout 123            # Check out PR locally
gh pr review 123 --approve    # Approve PR
gh pr review 123 --request-changes --body "..."
gh pr merge 123 --squash      # Merge PR
gh pr comment 123 --body "..."  # Reply to PR (does NOT resolve threads)
```

## Resolving Conversations

**The `gh` CLI cannot resolve review threads.** Two options:

1. **Web UI**: `gh pr view --web` → Files changed → Resolve conversation button
2. **GraphQL via `analyze-pr-comments` skill**: Use `pr-comments.sh resolve <thread-id>` or `pr-comments.sh resolve-all` from the sibling skill

Pushing commits may auto-resolve if the reviewer's settings allow it, but this is **unreliable**.

## Workflow: Addressing Review Comments

1. **Fetch** — `pr-workflow.sh track --pr 123` → generates checklist
2. **Fix** — Work through each item, commit with descriptive messages
3. **Push** — `git push`
4. **Resolve** — Use web UI (`gh pr view --web`) or `pr-comments.sh resolve-all --pr 123`
5. **Notify** — `gh pr comment 123 --body "All comments addressed, ready for re-review"`
