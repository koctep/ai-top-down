# Top-Down AI Development Pipeline

This repository provides reusable skills for the Top-Down development workflow,
language-specific guidance, and common Makefile operations.

## Sharing Skills with AI Tools

The canonical skill set lives in `agents/skills`. Link it into the selected
tool's configuration in the current directory:

```bash
./scripts/ai-init.sh claude
./scripts/ai-init.sh cursor gemini
./scripts/ai-init.sh --all
```

Use another source directory with `AI_SKILLS_DIR=/path/to/skills`, or preview the
changes with `--dry-run`. Existing files and directories are never replaced; use
`--force` only to replace a conflicting symlink.

The `codex` target also links the repository's synchronous `Stop` hook. Codex requires you to
review and trust a new or changed project hook with `/hooks` before it can run. If the target
already has `.codex/hooks.json`, the installer leaves it unchanged and reports a conflict so
the hook configuration can be merged deliberately.

## Core Workflows

- `top-down-workflow` — the eight-step Top-Down process.
- `td-roadmap` — roadmap template, status legend, and who marks a step done.
- `td-review` — how to run a review subagent: prompt, verdict, integrity check, fix loop.
- `sprint-task-runner` and `sprint-runner` — Jira sprint execution.
- `_shared/autonomous-run.md` — when a long run may end the turn, plus its state registry.
- `_shared/codex/hooks.json` (source; installs to `.codex/hooks.json`) — blocks Codex from ending
  a turn while an autonomous sprint state is still running; trust the project hook with `/hooks`
  before use.
- `_shared/failing-tests-triage.md` — classifying a red suite, filing pre-existing failures,
  and why they never stop a run.
- `td-*` — individual Top-Down steps.
- `lsr-*`, `do-testing`, and `run-*` — language, testing, and Makefile guidance.
