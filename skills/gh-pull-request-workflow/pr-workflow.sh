#!/usr/bin/env bash
# pr-workflow.sh — Wrapper for common GitHub PR CLI operations.
# Keeps jq pipelines and API details out of LLM context.
#
# Usage:
#   pr-workflow.sh comments [--pr <N>]                   Human-readable comments
#   pr-workflow.sh review-comments [--pr <N>]            Inline code review comments (JSON)
#   pr-workflow.sh track [--pr <N>]                      Generate markdown tracking checklist
#   pr-workflow.sh diff [--base <branch>]                Show what will be in the PR
#   pr-workflow.sh status                                Check if PR exists for current branch
#   pr-workflow.sh create --title <T> --body <B> [--base <branch>]  Create PR

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────

get_repo_info() {
  gh repo view --json owner,name -q '"\(.owner.login)/\(.name)"'
}

get_pr_number() {
  local pr="$1"
  if [ -n "$pr" ]; then
    echo "$pr"
  else
    gh pr view --json number -q '.number' 2>/dev/null \
      || { echo "Error: No PR found for current branch. Use --pr <number>." >&2; exit 1; }
  fi
}

# ── Commands ─────────────────────────────────────────────────────────

cmd_comments() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  gh pr view "$pr_num" --comments
}

cmd_review_comments() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  local repo
  repo=$(get_repo_info)

  gh api "repos/$repo/pulls/$pr_num/comments" \
    --jq '.[] | {path: .path, line: .line, body: .body, author: .user.login, created_at: .created_at, in_reply_to_id: .in_reply_to_id}'
}

cmd_track() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  local repo
  repo=$(get_repo_info)

  local pr_title
  pr_title=$(gh pr view "$pr_num" --json title -q '.title')

  echo "# PR #${pr_num}: ${pr_title}"
  echo ""

  gh api "repos/$repo/pulls/$pr_num/comments" \
    --jq '.[] | select(.in_reply_to_id == null)' \
    | jq -r --argjson i 0 '
      "## Comment \(input_line_number): \(.body | split("\n")[0] | .[0:80])\n\n- [ ] Fixed\n- **File:** `\(.path):\(.line // "N/A")`\n- **Author:** @\(.user.login)\n- **Comment:** \(.body | split("\n")[0] | .[0:120])\n- **Action:** TODO\n"
    ' 2>/dev/null || \
  gh api "repos/$repo/pulls/$pr_num/comments" \
    --jq '.[] | select(.in_reply_to_id == null)' \
    | jq -rs 'to_entries[] | "## Comment \(.key + 1): \(.value.body | split("\n")[0] | .[0:80])\n\n- [ ] Fixed\n- **File:** `\(.value.path):\(.value.line // "N/A")`\n- **Author:** @\(.value.user.login)\n- **Comment:** \(.value.body | split("\n")[0] | .[0:120])\n- **Action:** TODO\n"'
}

cmd_diff() {
  local base="${1:-main}"
  echo "=== Commits ==="
  git log "$base"..HEAD --oneline
  echo ""
  echo "=== Diff stat ==="
  git diff "$base"...HEAD --stat
}

cmd_status() {
  gh pr status
}

cmd_create() {
  local title="" body="" base="main"
  while [ $# -gt 0 ]; do
    case "$1" in
      --title) title="$2"; shift 2 ;;
      --body)  body="$2"; shift 2 ;;
      --base)  base="$2"; shift 2 ;;
      *)       shift ;;
    esac
  done

  if [ -z "$title" ]; then
    echo "Error: --title is required." >&2
    exit 1
  fi

  if [ -n "$body" ]; then
    gh pr create --base "$base" --title "$title" --body "$body"
  else
    gh pr create --base "$base" --title "$title"
  fi
}

# ── Dispatch ─────────────────────────────────────────────────────────

CMD="${1:-}"
shift || true

PR_NUM=""
BASE=""
TITLE=""
BODY=""
PASSTHROUGH_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --pr)    PR_NUM="$2"; shift 2 ;;
    --base)  BASE="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --body)  BODY="$2"; shift 2 ;;
    *)       PASSTHROUGH_ARGS+=("$1"); shift ;;
  esac
done

case "$CMD" in
  comments)        cmd_comments "$PR_NUM" ;;
  review-comments) cmd_review_comments "$PR_NUM" ;;
  track)           cmd_track "$PR_NUM" ;;
  diff)            cmd_diff "${BASE:-main}" ;;
  status)          cmd_status ;;
  create)          cmd_create --title "$TITLE" --body "$BODY" --base "${BASE:-main}" ;;
  *)
    cat >&2 <<'USAGE'
Usage: pr-workflow.sh <command> [options]

Commands:
  comments [--pr <N>]                          Human-readable PR comments
  review-comments [--pr <N>]                   Inline code review comments (JSON)
  track [--pr <N>]                             Generate markdown tracking checklist
  diff [--base <branch>]                       Show commits and diff stat for PR
  status                                       Check PR status for current branch
  create --title <T> [--body <B>] [--base <B>] Create a new PR
USAGE
    exit 1
    ;;
esac
