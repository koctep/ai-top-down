# AGENTS.md

Conventions for any agent (or human) maintaining this skills repository. These are rules about
the repo itself — how to structure and commit changes to it — not the Top-Down workflow the
skills describe for downstream projects.

## Skill scripts colocation

If a skill (or a shared doc under `agents/skills/_shared/`) requires a script — a hook, a
helper, anything executed on its behalf — put that script in a subdirectory of the same skill
folder. Never scatter it in a disconnected top-level directory.

Example: the Codex Stop-hook assets live at `agents/skills/_shared/codex/hooks.json` and
`agents/skills/_shared/codex/hooks/stop-autonomous-run.sh`, colocated with
[`_shared/autonomous-run.md`](agents/skills/_shared/autonomous-run.md), the doc that describes
and depends on them — not in a standalone top-level `codex/` directory.

When moving a script, grep the whole repo for its old path first — installers (`scripts/ai-init.sh`),
tests, and docs tend to hardcode it, and a stale reference breaks at runtime, not at commit time.

## Committing changes to this repo

Follow [`agents/skills/td-99-commit/SKILL.md`](agents/skills/td-99-commit/SKILL.md) for the full
procedure and message format. The two rules that are easy to get wrong:

- **No file writes after `git commit` runs.** Any file mutation tied to the commit step (e.g. a
  roadmap `[x]` mark, when working a Top-Down task) happens *before* staging, so it lands in the
  same commit — never as a separate edit afterward.
- **Branch name and commit hash are never written to any file, ever** — before or after the
  commit. They're chat-only output.
- The commit message body is a flat list of bullet-point theses, not prose "What/Why" paragraphs.
