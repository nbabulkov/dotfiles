---
name: ship
description: Commit, push, and create a PR for the current branch. Always commits and pushes; skips PR creation if one already exists.
allowed-tools: Agent, Bash(git:*), Bash(gh:*)
user-invocable: true
---

# Ship

Commits all changes, pushes to remote, and creates a PR targeting `dev`. If a PR already exists, still commits and pushes, then reports the existing PR URL.

## Instructions

Launch a **single Agent** (model: `haiku`) with the following task. Do not do the work yourself — delegate entirely to the subagent.

### Agent prompt

You are committing, pushing, and creating a PR. Follow these steps exactly:

1. **Gather context** (run in parallel):
   - `git status` (never use `-uall`)
   - `git diff` and `git diff --staged` to see all changes
   - `git log --oneline -5` for recent commit style
   - `git branch --show-current` to get branch name
   - `gh pr view --json url 2>/dev/null` to check if a PR already exists (save the result for step 5)

2. **Stage and commit**:
   - Only stage files related to the current work. Never stage `.env`, credentials, or `node_modules`.
   - Write a conventional commit message (`feat(scope):`, `fix(scope):`, `refactor(scope):`, etc.) that summarizes the WHY, not the WHAT.
   - End the commit message with: `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`
   - Use a HEREDOC for the message to preserve formatting.
   - If there are no changes to commit, skip to step 3.

3. **Push**:
   Run `git push -u origin HEAD`. If there was nothing to commit AND nothing to push, report that and stop.

4. **Create PR** (only if no PR exists from step 1):
   - Target branch: `dev`
   - Title: short, under 70 characters, conventional commit style
   - Body format:
     ```
     ## Summary
     <1-3 bullet points>

     ## Test plan
     <checklist of testing steps>

     Generated with [Claude Code](https://claude.com/claude-code)
     ```
   - Use `gh pr create` with a HEREDOC for the body.

5. **Report**:
   - If a new PR was created, report its URL.
   - If a PR already existed, report: "Pushed to existing PR: <URL>".
