#!/bin/sh

# Keep Codex running while a Top-Down sprint registry has unfinished work.

set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

field_value() {
  field_name=$1
  state_file=$2
  sed -n "s/^${field_name}:[[:space:]]*//p" "$state_file" | sed -n '1p'
}

lowercase() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

is_none() {
  normalized=$(lowercase "$1")
  [ -z "$normalized" ] || [ "$normalized" = "none" ]
}

block_stop() {
  state_file=$1
  next_action=$2
  relative_file=${state_file#"$repo_root"/}

  if is_none "$next_action"; then
    continuation="Read $relative_file, repair its active run state, and execute the next operation."
  else
    continuation="Read $relative_file and execute next_action now: $next_action"
  fi

  # State fields are single-line by contract. Escape the characters that can occur in JSON strings.
  escaped=$(printf '%s' "$continuation" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"decision":"block","reason":"%s"}\n' "$escaped"
  exit 0
}

block_cleanup() {
  state_file=$1
  relative_file=${state_file#"$repo_root"/}
  continuation="Remove $relative_file and its sprint directory if empty, then finish."
  escaped=$(printf '%s' "$continuation" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"decision":"block","reason":"%s"}\n' "$escaped"
  exit 0
}

for state_file in "$repo_root"/ai-tasks/sprint-*/00-sprint-state.md; do
  [ -f "$state_file" ] || continue

  run_state=$(lowercase "$(field_value run_state "$state_file")")
  sprint=$(lowercase "$(field_value sprint "$state_file")")
  next_action=$(field_value next_action "$state_file")
  blockers=$(field_value blockers "$state_file")
  terminal_reason=$(lowercase "$(field_value terminal_reason "$state_file")")

  case "$run_state" in
    closed)
      is_none "$next_action" || block_stop "$state_file" "$next_action"
      block_cleanup "$state_file"
      ;;
    blocked)
      if ! is_none "$terminal_reason" || ! is_none "$blockers"; then
        continue
      fi
      block_stop "$state_file" "$next_action"
      ;;
    running)
      block_stop "$state_file" "$next_action"
      ;;
    '')
      # Backward compatibility with registries created before run_state was introduced.
      case "$sprint" in
        *"(closed)"*) block_cleanup "$state_file" ;;
      esac
      if ! is_none "$terminal_reason" || ! is_none "$blockers"; then
        continue
      fi
      block_stop "$state_file" "$next_action"
      ;;
    *)
      block_stop "$state_file" "$next_action"
      ;;
  esac
done

# Stop hooks require valid JSON when exiting successfully.
printf '{}\n'
