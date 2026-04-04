#!/usr/bin/env bash
# pr-comments.sh — Wrapper for GitHub PR review thread operations.
# Keeps GraphQL complexity out of the LLM context.
#
# Usage:
#   pr-comments.sh fetch [--pr <number>]            Fetch unresolved review threads (JSON)
#   pr-comments.sh resolve <thread-id>              Resolve a single review thread
#   pr-comments.sh resolve-all [--pr <number>]      Resolve all unresolved threads
#   pr-comments.sh verify [--pr <number>]           Show resolution state of all threads

set -euo pipefail

# ── Helpers ──────────────────────────────────────────────────────────

get_repo_info() {
  gh repo view --json owner,name -q '"\(.owner.login) \(.name)"'
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

cmd_fetch() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  local repo_info
  repo_info=$(get_repo_info)
  local owner="${repo_info%% *}"
  local repo="${repo_info##* }"

  gh api graphql -f query='
    query($owner: String!, $repo: String!, $pr: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $pr) {
          title
          url
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              isOutdated
              path
              line
              startLine
              comments(first: 10) {
                nodes {
                  body
                  author { login }
                  createdAt
                }
              }
            }
          }
        }
      }
    }' -f owner="$owner" -f repo="$repo" -F pr="$pr_num" \
    | jq '{
        title: .data.repository.pullRequest.title,
        url: .data.repository.pullRequest.url,
        threads: [
          .data.repository.pullRequest.reviewThreads.nodes[]
          | select(.isResolved == false)
          | {
              id,
              path,
              line,
              startLine,
              isOutdated,
              comments: [.comments.nodes[] | {author: .author.login, body, createdAt}]
            }
        ]
      }'
}

cmd_resolve() {
  local thread_id="$1"
  if [ -z "$thread_id" ]; then
    echo "Error: thread ID required. Usage: pr-comments.sh resolve <thread-id>" >&2
    exit 1
  fi

  gh api graphql -f query='
    mutation($threadId: ID!) {
      resolveReviewThread(input: { threadId: $threadId }) {
        thread { id isResolved }
      }
    }' -f threadId="$thread_id" \
    | jq '.data.resolveReviewThread.thread'
}

cmd_resolve_all() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  local repo_info
  repo_info=$(get_repo_info)
  local owner="${repo_info%% *}"
  local repo="${repo_info##* }"

  local end_cursor="null"
  local resolved=0

  while :; do
    local response
    response=$(gh api graphql -f query='
      query($owner: String!, $repo: String!, $pr: Int!, $after: String) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $pr) {
            reviewThreads(first: 100, after: $after) {
              pageInfo { hasNextPage endCursor }
              nodes { id isResolved }
            }
          }
        }
      }' -f owner="$owner" -f repo="$repo" -F pr="$pr_num" -F after="$end_cursor")

    local ids
    ids=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | .id')

    for tid in $ids; do
      cmd_resolve "$tid" > /dev/null
      resolved=$((resolved + 1))
    done

    local has_next
    has_next=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
    if [ "$has_next" != "true" ]; then
      break
    fi
    end_cursor=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')
  done

  echo "{\"resolved\": $resolved}"
}

cmd_verify() {
  local pr_num
  pr_num=$(get_pr_number "$1")
  local repo_info
  repo_info=$(get_repo_info)
  local owner="${repo_info%% *}"
  local repo="${repo_info##* }"

  local end_cursor="null"
  local all_threads="[]"

  while :; do
    local response
    response=$(gh api graphql -f query='
      query($owner: String!, $repo: String!, $pr: Int!, $after: String) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $pr) {
            reviewThreads(first: 100, after: $after) {
              pageInfo { hasNextPage endCursor }
              nodes { id isResolved path line }
            }
          }
        }
      }' -f owner="$owner" -f repo="$repo" -F pr="$pr_num" -F after="$end_cursor")

    local page_threads
    page_threads=$(echo "$response" | jq '[.data.repository.pullRequest.reviewThreads.nodes[]]')
    all_threads=$(echo "$all_threads $page_threads" | jq -s 'add')

    local has_next
    has_next=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
    if [ "$has_next" != "true" ]; then
      break
    fi
    end_cursor=$(echo "$response" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor')
  done

  echo "$all_threads" | jq '{
    total: length,
    resolved: [.[] | select(.isResolved == true)] | length,
    unresolved: [.[] | select(.isResolved == false)] | length,
    threads: [.[] | {id, isResolved, path, line}]
  }'
}

# ── Dispatch ─────────────────────────────────────────────────────────

CMD="${1:-}"
shift || true

PR_NUM=""
THREAD_ID=""

while [ $# -gt 0 ]; do
  case "$1" in
    --pr) PR_NUM="$2"; shift 2 ;;
    *)    THREAD_ID="$1"; shift ;;
  esac
done

case "$CMD" in
  fetch)       cmd_fetch "$PR_NUM" ;;
  resolve)     cmd_resolve "$THREAD_ID" ;;
  resolve-all) cmd_resolve_all "$PR_NUM" ;;
  verify)      cmd_verify "$PR_NUM" ;;
  *)
    echo "Usage: pr-comments.sh {fetch|resolve|resolve-all|verify} [--pr <number>] [<thread-id>]" >&2
    exit 1
    ;;
esac
