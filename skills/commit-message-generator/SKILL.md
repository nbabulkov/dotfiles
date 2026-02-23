---
name: commit-message-generator
description: Generates conventional commit messages by analyzing git changes. Use when the user asks to generate, create, or suggest commit messages, or when they ask "what should I commit?" or mention committing changes.
allowed-tools: Bash(git:*), Read, Grep
user-invocable: true
---

# Commit Message Generator

Generates high-quality conventional commit messages by analyzing staged or uncommitted changes.

## When to Use

Use this skill when the user:
- Asks to generate, create, or suggest commit messages
- Says "what should I commit?" or "help me write a commit message"
- Mentions committing changes and needs a message
- Wants to review what will be committed

## Workflow

1. **ALWAYS examine the changes first** using the commands below
2. Analyze the changes to determine type, scope, and impact
3. Generate 3 distinct versions (or the number explicitly requested)
4. Present all versions in quote blocks for easy selection

## Commands to Run

```bash
# Check what will be committed (default)
echo "Staged changes:"
git --no-pager diff --cached --stat
git --no-pager diff --cached

# OR check all uncommitted changes (if user requests)
# git --no-pager diff HEAD --stat
# git --no-pager diff HEAD

# Review recent commit style for consistency
echo "Last 5 commit messages:"
git --no-pager log --oneline -n 5
```

## Format

Each message must follow this structure:
```
<type>(<scope>): <short-message>

- <specific-change-1>
- <specific-change-2>
- <specific-change-3>
```

## Commit Types

- `feat` - New feature or capability
- `fix` - Bug fix or error correction
- `refactor` - Code restructuring without behavior change
- `style` - Formatting, whitespace, styling (no logic change)
- `test` - Adding or updating tests
- `chore` - Maintenance (deps, build config, tooling)
- `docs` - Documentation only

## Scope Guidelines

Use the most specific affected area. Check the actual file paths in the diff.

Common scopes in this project:
- `auth`, `trpc`, `database`, `api` - Backend/infrastructure
- `forms`, `charts`, `dashboard`, `ui` - Frontend features
- `dictation`, `questionnaire`, `deals`, `documents` - Domain features
- `hooks`, `utils`, `types` - Shared code
- `worker`, `llm` - Background services
- `storage` - File management and storage operations

**If changes span multiple scopes:** use the primary scope or use a broader parent scope.
**If changes are truly cross-cutting:** consider splitting into multiple commits.

## Writing Guidelines

- **Short message:** 50 chars max, imperative mood ("add" not "added"), no period
- **Bullet points:** Be specific about what changed and why (when non-obvious)
- **Focus on why:** Not just what was changed, but the purpose/benefit
- **One logical change:** If you see unrelated changes, suggest splitting commits

## Examples

### Good ✓
```
feat(dictation): add pause/resume controls

- Add pause button to dictation interface
- Implement resume functionality with state persistence
- Update UI to show recording status
```

### Bad ✗
```
Updated some stuff in the dictation component

- Changed the dictation button
- Fixed a thing
- Updated files
```
(Too vague, past tense, doesn't explain what or why)

## Output Format

Present all 3 versions in quote blocks, each offering a different perspective or level of detail on the same changes. For example:

**Option 1** (Detailed):
> feat(storage): add comprehensive path validation
>
> - Add path traversal validation to prevent directory escape attacks
> - Implement validation across all file operations (upload, delete, get)
> - Add unit tests for edge cases and malicious patterns

**Option 2** (Concise):
> feat(storage): add path traversal validation
>
> - Prevent directory escape attacks in file operations
> - Add validation to upload, delete, and get endpoints

**Option 3** (Alternative framing):
> refactor(storage): enhance security with path validation
>
> - Validate file paths to prevent traversal attacks
> - Apply consistent validation across storage operations
