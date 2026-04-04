---
name: analyze-pr-comments
description: Use when reviewing unresolved PR comments, analyzing code review feedback, or prioritizing review items to address. Fetches comments via gh CLI and produces prioritized analysis table.
user-invocable: true
---

# Analyze PR Comments

Fetches unresolved PR review comments and analyzes each for legitimacy, priority, and impact.

## When to Use

- User asks to review/analyze PR comments
- User wants to understand which review feedback to prioritize
- User asks "what PR comments should I address first?"
- User wants to check if reviewer feedback is valid

## Script

All GitHub API calls are handled by the wrapper script at:

```
.claude/skills/analyze-pr-comments/pr-comments.sh
```

Commands:

| Command | Description |
|---|---|
| `./pr-comments.sh fetch [--pr <N>]` | Fetch unresolved threads as JSON (auto-detects PR from branch) |
| `./pr-comments.sh resolve <thread-id>` | Resolve a single thread by ID |
| `./pr-comments.sh resolve-all [--pr <N>]` | Resolve all unresolved threads |
| `./pr-comments.sh verify [--pr <N>]` | Show resolution state summary |

Run the script from the repo root. If `--pr` is omitted, the script detects the PR from the current branch.

## Workflow

### Step 1: Fetch unresolved threads

```bash
.claude/skills/analyze-pr-comments/pr-comments.sh fetch [--pr <N>]
```

Returns JSON with `title`, `url`, and `threads[]` (each with `id`, `path`, `line`, `comments[]`).

### Step 2: Analyze each thread

For each unresolved thread:

1. **Read the affected code** using the `path` and `line` fields
2. **Understand the reviewer's concern** from comment body
3. **Determine legitimacy:**
   - **Legit**: Valid concern, should be addressed
   - **Partially Legit**: Has merit but overstated or edge case
   - **Not Legit**: Reviewer misunderstood or incorrect
4. **Assign priority** (P0-P3):
   - **P0 Critical**: Security, data loss, crashes
   - **P1 High**: Bugs, incorrect behavior, performance issues
   - **P2 Medium**: Code quality, maintainability, minor issues
   - **P3 Low**: Style, preferences, nitpicks

### Step 3: Output analysis table

Sort by priority (P0 first), then by legitimacy (Legit first).

| # | Priority | Legit? | Summary | File:Line | Impact | Recommendation |
|---|----------|--------|---------|-----------|--------|----------------|
| 1 | P0 | Yes | Missing auth check | api/users.ts:45 | Security vuln | Add auth middleware |
| 2 | P1 | Partial | Race condition | lib/sync.ts:120 | Edge case bug | Add mutex if high traffic |
| 3 | P2 | Yes | Magic number | utils/calc.ts:33 | Maintainability | Extract to constant |
| 4 | P3 | No | Naming preference | models/user.ts:12 | Style only | Keep (consistent with codebase) |

### Step 4: Resolve threads after fixes

After implementing and verifying fixes:

```bash
# Resolve a single thread
.claude/skills/analyze-pr-comments/pr-comments.sh resolve <thread-id>

# Resolve all unresolved threads
.claude/skills/analyze-pr-comments/pr-comments.sh resolve-all [--pr <N>]

# Verify resolution state
.claude/skills/analyze-pr-comments/pr-comments.sh verify [--pr <N>]
```

Only resolve threads when the fix is present in the branch (or intentionally dismissed with rationale).

## Analysis Guidelines

### Legitimacy Assessment

**Legit indicators:**
- Points to actual bug or incorrect behavior
- Security concern with real attack vector
- Performance issue with measurable impact
- Violates documented project conventions

**Not Legit indicators:**
- Reviewer unfamiliar with codebase patterns
- Suggestion contradicts project conventions
- Hypothetical concern with no realistic scenario
- Personal preference presented as requirement

### Priority Assignment

- **P0 Critical**: Security vulnerabilities, data loss/corruption, crashes, breaking API changes
- **P1 High**: Functional bugs, performance regressions, missing error handling, logic errors
- **P2 Medium**: Code quality, missing tests, documentation gaps, minor perf optimizations
- **P3 Low**: Style/formatting, alternative approaches, speculative improvements, nitpicks
