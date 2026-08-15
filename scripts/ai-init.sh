#!/usr/bin/env bash

# Link this repository's shared skills and rules into an AI tool configuration
# in the current directory. The source is overrideable so one shared set can
# serve multiple repositories.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEFAULT_SKILLS_DIR="$SCRIPT_DIR/../.agents/skills"
SKILLS_DIR=${AI_SKILLS_DIR:-$DEFAULT_SKILLS_DIR}
DEFAULT_RULES_DIR="$SCRIPT_DIR/../.agents/rules"
RULES_DIR=${AI_RULES_DIR:-$DEFAULT_RULES_DIR}
TARGET_DIR=${AI_TARGET_DIR:-$(pwd)}
DRY_RUN=false
FORCE=false

usage() {
  cat <<'EOF'
Usage: scripts/ai-init.sh [--all] [--dry-run] [--force] <claude|cursor|codex|gemini>...

Creates symlinks for every skill in AI_SKILLS_DIR and a shared `.agents/rules`
directory under the current directory. Cursor also receives `.cursor/rules`.

Environment:
  AI_SKILLS_DIR  Skill directory to link from (default: <repo>/.agents/skills)
  AI_RULES_DIR   Rules directory to link from (default: <repo>/.agents/rules)
  AI_TARGET_DIR  Directory to initialize (default: current directory)

Targets:
  claude  .claude/skills
  cursor  .cursor/skills
  codex   .agents/skills
  gemini  .gemini/skills

Options:
  --all      Initialize all supported tools.
  --dry-run  Print planned changes without writing them.
  --force    Replace conflicting symlinks only; never replaces real files or directories.
EOF
}

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  if "$DRY_RUN"; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

canonical_dir() {
  CDPATH= cd -- "$1" && pwd
}

if [ ! -d "$SKILLS_DIR" ]; then
  fail "skills directory does not exist: $SKILLS_DIR"
fi
if [ ! -d "$RULES_DIR" ]; then
  fail "rules directory does not exist: $RULES_DIR"
fi

SKILLS_DIR=$(canonical_dir "$SKILLS_DIR")
RULES_DIR=$(canonical_dir "$RULES_DIR")
TARGET_DIR=$(canonical_dir "$TARGET_DIR")

systems=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --all)
      systems="$systems claude cursor codex gemini"
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --force)
      FORCE=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    claude|cursor|codex|gemini)
      systems="$systems $1"
      ;;
    *)
      usage >&2
      fail "unsupported option or system: $1"
      ;;
  esac
  shift
done

[ -n "$systems" ] || {
  usage >&2
  exit 1
}

skill_count=0
for skill_path in "$SKILLS_DIR"/*; do
  [ -e "$skill_path" ] || continue
  [ -d "$skill_path" ] || continue
  skill_count=$((skill_count + 1))
done
[ "$skill_count" -gt 0 ] || fail "no skill directories found in: $SKILLS_DIR"

link_directory() {
  source_path=$1
  target_path=$2
  label=$3

  if [ "$target_path" = "$source_path" ]; then
    printf '%s: source already is %s; skipped\n' "$label" "$target_path"
    return
  fi

  if [ -L "$target_path" ]; then
    link_target=$(readlink "$target_path")
    if [ "$link_target" = "$source_path" ]; then
      printf '%s: already linked\n' "$label"
      return
    fi
    if "$FORCE"; then
      run rm "$target_path"
    else
      printf '%s: conflicting symlink left unchanged: %s -> %s\n' \
        "$label" "$target_path" "$link_target" >&2
      return 1
    fi
  elif [ -e "$target_path" ]; then
    printf '%s: existing path left unchanged: %s\n' "$label" "$target_path" >&2
    return 1
  fi

  run mkdir -p "$(dirname "$target_path")"
  run ln -s "$source_path" "$target_path"
  printf '%s: linked\n' "$label"
}

link_shared_rules() {
  link_directory "$RULES_DIR" "$TARGET_DIR/.agents/rules" 'shared rules'
}

link_cursor_rules() {
  link_directory "$RULES_DIR" "$TARGET_DIR/.cursor/rules" 'cursor rules'
}

link_system() {
  system=$1
  case "$system" in
    claude) target_skills_dir="$TARGET_DIR/.claude/skills" ;;
    cursor) target_skills_dir="$TARGET_DIR/.cursor/skills" ;;
    codex) target_skills_dir="$TARGET_DIR/.agents/skills" ;;
    gemini) target_skills_dir="$TARGET_DIR/.gemini/skills" ;;
  esac

  if [ "$target_skills_dir" = "$SKILLS_DIR" ]; then
    printf '%s: source already is %s; skipped\n' "$system" "$target_skills_dir"
    return
  fi

  run mkdir -p "$target_skills_dir"
  linked=0
  skipped=0
  conflicts=0

  for skill_path in "$SKILLS_DIR"/*; do
    [ -d "$skill_path" ] || continue
    skill_name=$(basename "$skill_path")
    link_path="$target_skills_dir/$skill_name"

    if [ -L "$link_path" ]; then
      link_target=$(readlink "$link_path")
      if [ "$link_target" = "$skill_path" ]; then
        skipped=$((skipped + 1))
        continue
      fi
      if "$FORCE"; then
        run rm "$link_path"
      else
        printf '%s: conflicting symlink left unchanged: %s -> %s\n' \
          "$system" "$link_path" "$link_target" >&2
        conflicts=$((conflicts + 1))
        continue
      fi
    elif [ -e "$link_path" ]; then
      printf '%s: existing path left unchanged: %s\n' "$system" "$link_path" >&2
      conflicts=$((conflicts + 1))
      continue
    fi

    run ln -s "$skill_path" "$link_path"
    linked=$((linked + 1))
  done

  printf '%s: %d linked, %d already linked, %d conflicts\n' \
    "$system" "$linked" "$skipped" "$conflicts"
  [ "$conflicts" -eq 0 ]
}

result=0
link_shared_rules || result=1
for system in $systems; do
  if [ "$system" = cursor ]; then
    link_cursor_rules || result=1
  fi
  link_system "$system" || result=1
done

exit "$result"
