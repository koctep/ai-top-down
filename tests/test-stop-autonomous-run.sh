#!/bin/sh

set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
hook="$repo_root/agents/skills/_shared/codex/hooks/stop-autonomous-run.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/stop-autonomous-run.XXXXXX")
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

new_repo() {
  case_name=$1
  case_root="$test_root/$case_name"
  mkdir -p "$case_root"
  git -C "$case_root" init -q
  printf '%s\n' "$case_root"
}

run_hook() {
  case_root=$1
  printf '{"hook_event_name":"Stop"}\n' | (cd "$case_root" && /bin/sh "$hook")
}

assert_allows() {
  case_root=$1
  output=$(run_hook "$case_root")
  [ "$output" = '{}' ] || {
    printf 'expected Stop to be allowed, got: %s\n' "$output" >&2
    exit 1
  }
}

assert_blocks() {
  case_root=$1
  expected=$2
  output=$(run_hook "$case_root")
  printf '%s' "$output" | grep -F '"decision":"block"' >/dev/null
  printf '%s' "$output" | grep -F "$expected" >/dev/null
}

write_state() {
  case_root=$1
  shift
  state_dir="$case_root/ai-tasks/sprint-42"
  mkdir -p "$state_dir"
  printf '%s\n' "$@" >"$state_dir/00-sprint-state.md"
}

case_root=$(new_repo no_registry)
assert_allows "$case_root"

case_root=$(new_repo step_two_review_pending)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'sprint: 42 Example (active)' \
  'phase: Phase 5 / PYPOST-1066 / Step 2' \
  'current: PYPOST-1066 — Step 2 execution finished' \
  'next_action: launch PYPOST-1066 Step 2 independent read-only review' \
  'blockers: none'
assert_blocks "$case_root" 'launch PYPOST-1066 Step 2 independent read-only review'

case_root=$(new_repo running_without_next_action)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'run_state: running' \
  'next_action: none' \
  'blockers: none' \
  'terminal_reason: none'
assert_blocks "$case_root" 'repair its active run state'

case_root=$(new_repo closed)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'run_state: closed' \
  'next_action: none' \
  'blockers: none' \
  'terminal_reason: completed'
assert_blocks "$case_root" 'and its sprint directory if empty'

printf 'preserve me\n' >"$case_root/ai-tasks/sprint-42/notes.md"
unlink "$case_root/ai-tasks/sprint-42/00-sprint-state.md"
if rmdir "$case_root/ai-tasks/sprint-42" 2>/dev/null; then
  printf 'expected non-empty sprint directory to be preserved\n' >&2
  exit 1
fi
[ -f "$case_root/ai-tasks/sprint-42/notes.md" ]
assert_allows "$case_root"

case_root=$(new_repo legacy_closed)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'sprint: 42 Example (closed)' \
  'next_action: none' \
  'blockers: none'
assert_blocks "$case_root" 'and its sprint directory if empty'

case_root=$(new_repo hard_blocker)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'run_state: blocked' \
  'next_action: none' \
  'blockers: PYPOST-1066: missing Jira authentication' \
  'terminal_reason: auth_missing'
assert_allows "$case_root"

case_root=$(new_repo inconsistent_closed)
write_state "$case_root" \
  '# Sprint 42 — run state' \
  'run_state: closed' \
  'next_action: launch another task' \
  'blockers: none' \
  'terminal_reason: completed'
assert_blocks "$case_root" 'launch another task'

printf 'stop-autonomous-run hook tests passed\n'
