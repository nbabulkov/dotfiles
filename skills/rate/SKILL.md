---
name: rate
description: Rate and analyze the quality of a recently completed implementation. Use after finishing an implementation task to self-assess code quality, identify strengths and weaknesses, and propose improvements.
allowed-tools: Read, Grep, Glob
user-invocable: true
---

# Rate Implementation

Analyze and rate a recently completed implementation on a scale of 1-10.

## When to Use

- After completing an implementation task
- When the user asks to review or rate recent changes
- When invoking `/rate`

## Workflow

1. **Identify changes**: Use the conversation context to find all files created or modified during the current session
2. **Re-read modified files** in full to evaluate the final state
3. **Evaluate** against the criteria below
4. **Output** the rating in the specified format

## Evaluation Criteria

- **Correctness** - Does it solve the stated problem?
- **Simplicity** - Is it the simplest reasonable approach?
- **Readability** - Is the code clear and self-documenting?
- **Consistency** - Does it follow existing codebase patterns?
- **Edge cases** - Are failure modes handled appropriately?
- **Security** - Are there any vulnerabilities introduced?

## Output Format

### Rating: X/10

> One-sentence summary of the overall quality.

### Good

- (list concrete strengths, reference specific files/patterns)

### Bad

- (list concrete weaknesses, reference specific files/lines)

### Improvements

| # | Issue | Fix | Complexity | Priority |
|---|-------|-----|------------|----------|
| 1 | (brief issue) | (proposed fix) | Low/Medium/High | P0-P3 |

**Complexity**: Low = a few lines, Medium = moderate refactor, High = significant rework.
**Priority**: P0 = must fix now, P1 = fix before merge, P2 = fix soon, P3 = nice to have.
