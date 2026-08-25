# AGENTS.md

Conventions for maintaining this skills repository itself (not the Top-Down workflow the skills
describe for downstream projects). Keep entries here terse — short bullets, no prose
explanations or worked examples.

## Skill scripts colocation

- A skill's scripts (hooks, helpers) live in a subdirectory of that skill (or `_shared/`), never
  a standalone top-level directory.
- Moving one: grep the repo for its old path first — installers/tests/docs hardcode it.

## Committing changes to this repo

Full procedure: [`agents/skills/td-99-commit/SKILL.md`](agents/skills/td-99-commit/SKILL.md).

- No file writes after `git commit` runs.
- Branch name and commit hash are chat-only, never written to a file.
- Commit body: bullet-point theses, not prose.
