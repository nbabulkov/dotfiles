---
name: jira
description: Use when the user asks to interact with Jira — fetch tasks, update status, add comments, edit descriptions, search issues, or create work items.
allowed-tools: Bash(acli:*)
user-invocable: true
---

# Jira

Interact with Jira issues for the PL project via the `acli` CLI.

## Common Operations

### Search issues
```bash
acli jira workitem search --jql "project = PL AND assignee = currentUser() AND status != Done" --fields "key,summary,status,priority"
```
Useful JQL filters:
- `assignee = currentUser()` — my tasks
- `status = "To Do"` / `status = "In Progress"` / `status = "Backlog"`
- `sprint in openSprints()` — current sprint
- `updated >= -7d` — recently updated

### View an issue
```bash
acli jira workitem view PL-142
# With specific fields:
acli jira workitem view PL-142 --fields "summary,description,status,comment"
# As JSON:
acli jira workitem view PL-142 --json
```

### Change status
```bash
acli jira workitem transition --key "PL-142" --status "In Progress"
```

### Add a comment
```bash
acli jira workitem comment create --key "PL-142" --body "Comment text here"
```

### Edit issue fields
```bash
acli jira workitem edit --key "PL-142" --summary "New title"
acli jira workitem edit --key "PL-142" --description "New description"
acli jira workitem edit --key "PL-142" --assignee "user@email.com"
# Self-assign:
acli jira workitem edit --key "PL-142" --assignee "@me"
```

### Create an issue
```bash
acli jira workitem create --project "PL" --type "Task" --summary "Title" --description "Details"
```

### Bulk operations (via JQL)
```bash
acli jira workitem transition --jql "project = PL AND status = 'To Do'" --status "In Progress" --yes
acli jira workitem edit --jql "project = PL AND sprint in openSprints()" --labels "sprint-1" --yes
```

## Notes

- Use `--json` on any command for machine-readable output
- Use `--web` on `view` or `search` to open in browser
- Bulk operations with `--jql` require `--yes` to skip confirmation
