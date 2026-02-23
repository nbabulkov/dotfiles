---
name: create-branch
description: Use when the user asks to create a new branch, start a feature, or begin work on a Jira task.
allowed-tools: Bash(git:*), Bash(acli:*)
user-invocable: true
---

# Create Branch

Creates a new feature branch based on the latest `dev` branch, using the Jira task ID and summary for the branch name.

## When to Use

- User says "create a branch", "new branch", "start working on PL-XXX"
- User mentions a Jira task ID (PL-number) and wants to begin work

## Input

Ask the user for the **Jira task ID** (e.g. `PL-142`) if not provided.

## Workflow

1. **Fetch the Jira issue summary**:
```bash
acli jira workitem view PL-<number> --fields "summary" --json
```

2. **Derive branch name** from the summary — convert to kebab-case, keep it short (3-5 words max)

3. **Create the branch** from latest `origin/dev`:
```bash
git fetch origin
git checkout -b PL-<number>-<short-description> origin/dev
```

## Branch Format

```
PL-<number>-<short-description>
```

Examples: `PL-142-fix-login-redirect`, `PL-200-add-export-csv`

**Important:** Always branch from `origin/dev` (not local `dev`) to ensure the branch is based on the most recent remote state.

## Output

Confirm to the user:
- Branch name created
- Jira issue summary it was derived from
- That it's based on latest `dev`
