---
name: gh-pull-request-workflow
description: Use when working with GitHub PRs via CLI - fetching review comments, tracking fixes, creating PRs, or viewing comment threads
---

# gh Pull Request Workflow

## Overview

The GitHub CLI (`gh`) provides efficient commands for PR workflows. This skill covers fetching review comments, tracking them locally, understanding comment resolution, and creating PRs with proper descriptions.

## When to Use

Use this skill when:

- Fetching review comments from a PR to work through systematically
- Creating a new PR from the command line
- Viewing specific comment threads or conversations
- Understanding how comment resolution works in gh CLI

Don't use this for:

- General git operations (use git commands)
- GitHub Actions or CI/CD workflows
- Repository administration tasks

## Quick Reference

| Task                    | Command                                           |
| ----------------------- | ------------------------------------------------- |
| View PR in browser      | `gh pr view --web` or `gh pr view 123 --web`      |
| View PR details         | `gh pr view` or `gh pr view 123`                  |
| List all comments       | `gh pr view 123 --json comments --jq '.comments'` |
| Fetch review comments   | `gh api repos/{owner}/{repo}/pulls/{pr}/comments` |
| Create PR               | `gh pr create --title "..." --body "..."`         |
| Create PR (interactive) | `gh pr create`                                    |
| View specific comment   | `gh pr view --web` then navigate to Files changed |

## Fetching and Saving Review Comments

### Option 1: Human-Readable Format

```bash
# View all comments on current PR
gh pr view --comments

# View comments for specific PR
gh pr view 123 --comments

# Save to file for tracking
gh pr view 123 --comments > PR-123-comments.txt
```

### Option 2: Structured JSON

```bash
# Fetch as JSON for programmatic processing
gh pr view 123 --json comments | jq '.comments[] | {author: .author.login, body: .body, createdAt: .createdAt}' > comments.json

# Or fetch review comments specifically (inline code comments)
gh api repos/{owner}/{repo}/pulls/123/comments --jq '.[] | {path: .path, line: .line, body: .body}' > review-comments.json
```

### Creating a Tracking File

Good pattern for working through comments:

```markdown
# PR 123 Review Comments

## Issue 1: Authentication Error Handling

- [ ] Fixed
- **File:** `src/auth.ts:45`
- **Comment:** "Need to handle 401 errors"
- **Action:** Add try-catch for auth failures

## Issue 2: Missing Type Annotations

- [ ] Fixed
- **File:** `src/utils.ts:12`
- **Comment:** "Function needs return type"
- **Action:** Add Promise<User> return type
```

## Understanding Comment Resolution

**CRITICAL DISTINCTION:**

- **Replying to comments** = Adding a response to notify reviewer (✅ possible via CLI)
- **Resolving conversations** = Marking thread as resolved (❌ NOT possible via CLI alone)

### How Comments Get Resolved

**The `gh` CLI does NOT have a command to resolve conversations.** Only two ways to resolve:

1. **Automatic resolution:** Push commits → GitHub auto-resolves IF the commenter enabled this setting
2. **Manual resolution:** Use web UI (`gh pr view --web` → Files changed → Resolve conversation button)

### What You CAN Do via CLI

```bash
# Reply to notify reviewer you fixed something
gh pr comment 456 --body "Fixed authentication bug in commit abc123"

# This does NOT resolve - it just adds a comment
```

### Don't Create False Workflows

**Common mistake:** Creating scripts that claim to "resolve" comments but only reply to them.

❌ **Don't** create bash scripts that claim to "resolve" - they can only reply, not resolve
❌ **Don't** use GraphQL API mutations (requires finding thread IDs, extremely tedious)
❌ **Don't** confuse "adding a reply" with "resolving the conversation"

✅ **Do** use `gh pr view --web` to quickly open and manually resolve in browser
✅ **Do** push fixes and let auto-resolution work (if enabled by commenter)
✅ **Do** use `gh pr comment` to notify reviewers, but understand it doesn't resolve

### When Auto-Resolution Works

GitHub auto-resolves conversations when:

- The conversation author enabled "Allow edits and access to push commits to this PR"
- You push commits that modify the lines mentioned in the comment
- The reviewer's GitHub settings allow auto-resolution

**This is unreliable** - don't depend on it. Plan to manually resolve via web UI.

## Creating Pull Requests

### Basic Workflow

```bash
# Ensure you're on the feature branch and have pushed commits
git push -u origin feature-branch

# Create PR with inline flags
gh pr create --base main --title "Add user authentication" --body "Implements JWT-based auth with Google OAuth"

# Or use interactive mode (prompts for title, body, etc.)
gh pr create

# Or create with heredoc for long descriptions
gh pr create --base main --title "Add user auth" --body "$(cat <<'EOF'
## Summary
- Implements JWT authentication
- Adds Google OAuth integration
- Updates user model with auth fields

## Test Plan
- [x] Unit tests for auth service
- [x] Integration tests for OAuth flow
- [ ] Manual testing with Google account
EOF
)"
```

### Best Practices

1. **Always check branch diff first:**

   ```bash
   git diff main...HEAD  # See what will be in the PR
   git log main..HEAD    # See commits that will be included
   ```

2. **Use descriptive titles:** Follow conventional commits or team conventions

3. **Include context in body:** What changed, why, testing done

4. **Verify before creating:**
   ```bash
   gh pr status  # Check if PR already exists for this branch
   ```

## Viewing and Navigating Comments

### List All PRs with Comments

```bash
# See all open PRs
gh pr list

# See your PRs
gh pr list --author @me

# Filter by state
gh pr list --state all
```

### View Specific Comment Thread

Since gh CLI doesn't navigate to specific comments:

```bash
# Quick: Open PR in browser and use GitHub's UI
gh pr view 123 --web

# Then navigate to Files changed → Find comment → Resolve
```

### Extract Comment Details

```bash
# Get all review comments with file context
gh api repos/{owner}/{repo}/pulls/123/comments --jq '.[] | "File: \(.path):\(.line)\nComment: \(.body)\n---"'

# Get just unresolved conversations (requires checking state)
gh pr view 123 --json comments --jq '.comments[] | select(.state == "OPEN")'
```

## Common Mistakes

| Mistake                                         | Fix                                                             |
| ----------------------------------------------- | --------------------------------------------------------------- |
| Creating scripts to "resolve" comments          | Don't - they can only reply. Use web UI to actually resolve     |
| Confusing reply with resolve                    | `gh pr comment` replies, doesn't resolve. Two different actions |
| Trying to resolve via gh CLI                    | Not possible. Use `gh pr view --web` + manual clicks            |
| Relying on auto-resolution                      | Unreliable - plan to manually resolve via web UI                |
| Creating PR without checking diff               | Run `git diff main...HEAD` first                                |
| Not verifying PR already exists                 | Check `gh pr status` before creating                            |
| Fetching comments then creating complex scripts | Save as markdown, track manually, resolve on web                |

## Real-World Workflow

**Scenario:** You have 10 review comments to address on PR #456

```bash
# 1. Fetch and save comments
gh pr view 456 --comments > PR-456-review.txt

# 2. Create tracking file (manually or with jq)
cat PR-456-review.txt  # Review comments
# Create markdown checklist based on comments

# 3. Work through each issue
# - Read comment
# - Make fix
# - Commit with descriptive message
# - Check off in tracking file

# 4. Push all fixes
git push

# 5. Open PR and resolve conversations
gh pr view 456 --web
# Navigate to Files changed → Resolve conversations

# 6. Notify reviewer
gh pr comment 456 --body "All review comments addressed, ready for re-review"
```

## Additional Commands

```bash
# Check out a PR locally for testing
gh pr checkout 123

# View PR checks/status
gh pr checks

# Review a PR (approve/comment/request changes)
gh pr review 123 --approve
gh pr review 123 --comment --body "LGTM with minor suggestions"
gh pr review 123 --request-changes --body "Please address X before merging"

# Merge a PR
gh pr merge 123 --squash  # or --merge, --rebase
```

## When to Open Browser

Open browser (`gh pr view --web`) when you need to:

- Resolve comment conversations
- Review file changes with GitHub's UI
- Use GitHub features not available in CLI (suggestions, reactions)
- Navigate complex diff views

The CLI is great for listing, fetching, and creating - the web UI is better for rich interactions.
