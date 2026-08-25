---
name: td-roadmap
description: Maintain ai-tasks/<JIRA-TASK-ID>/00-roadmap.md — the single progress journal of a Top-Down task. Defines the status legend, who writes which mark and when, and the step-to-artifact mapping. Use whenever a Top-Down step starts, finishes, or records progress.
---

# Roadmap Maintenance

`ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` is the **single progress journal** of a Top-Down task:
which step is running, what each step produced, and the task-level facts other steps depend on
(implementation language). Every `td-*` step reads and updates it; this skill owns the rules for
doing so.

## File and Template

- **Path**: `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` (one per task).
- **Template**: [assets/roadmap.md](assets/roadmap.md).
- **Created**: at Step 1 by [td-10-requirements](../td-10-requirements/SKILL.md) — copy the
  template and replace every `<JIRA-TASK-ID>` with the real task ID.
- **MANDATORY**: the file exists before any other step starts. A step that finds no roadmap
  creates it from the template rather than proceeding without one.

## Status Legend

- `[ ]` — step not started
- `[/]` — step in progress
- `[x]` — step completed **and accepted** (see the gate below)

Never use any other marker. `[x]` is not "I finished writing" — it is "the acceptance gate for
this step passed".

## Who Writes What

| Mark | Written by | When |
| ---- | ---------- | ---- |
| `[/]` | Agent executing the step | First action of the step |
| Sub-items (paths, summaries, notes) | Agent executing the step | As the work happens |
| Task metadata (language, branch) | Step that determines it | When determined |
| `[x]` | Owner of the acceptance gate | Only after the gate passes |

A step-execution subagent **never** marks its own step `[x]` — it leaves the step `[/]` with its
sub-items filled in, and reports back. Marking `[x]` is the gate owner's act of accepting the step.

## The `[x]` Gate

`[x]` means the step passed its acceptance gate. What the gate is depends on how the workflow
runs, but the rule is one:

> **`[x]` is written by the agent that owns the acceptance gate, and only after that gate
> returns a pass.**

| Run mode | Gate owner | Gate passes when |
| -------- | ---------- | ---------------- |
| Interactive (user-driven) | Agent talking to the user | User reviewed artifacts and approved |
| Autonomous (runner / batch) | Orchestrator | Review subagent returned PASS |

Interactive mode is [top-down-workflow](../top-down-workflow/SKILL.md) run by a user; autonomous
mode is [sprint-task-runner](../sprint-task-runner/SKILL.md) or an explicit batch run. The PASS
verdict comes from a review subagent run per [td-review](../td-review/SKILL.md).

Both modes are equally valid; neither is an exception to the other. When a run is interactive and
also uses review subagents, both gates apply: review PASS **then** user approval, and `[x]` goes
in last.

The gate owner is also the agent that writes `[x]` — it never delegates the mark to the subagent
that did the work, because that subagent cannot observe its own gate.

## Per-Step Protocol

1. **Start** — mark the step `[/]`. If the roadmap does not exist, create it from the template.
2. **During** — record what the step produces as sub-items under that step: artifact paths, test
   paths, iteration summaries, `N/A` notes with the reason.
3. **Report** — hand the step artifacts to the gate owner (return from the subagent, or present
   to the user).
4. **Accept** — the gate owner marks `[x]` after the gate passes.

If a completed step is reopened (review found gaps, requirements changed), set it back to `[/]`
and re-run the gate. Do not leave `[x]` on a step whose artifacts are being changed.

## Steps, Skills, and Artifacts

The workflow has eight numbered steps plus a closing commit procedure. **Step numbers do not
match skill-file prefixes** — this table is the source of truth for the mapping:

| Step | Skill | Roadmap entry | Main artifacts |
| ---- | ----- | ------------- | -------------- |
| 1 | `td-10-requirements` | STEP 1 | `00-roadmap.md`, `10-requirements.md` |
| 2 | `td-20-architecture` | STEP 2 | `20-architecture.md` |
| 3 | `td-25-failing-repro` | STEP 3 | red test(s), or an `N/A` note |
| 4 | `td-30-development` | STEP 4 | source code, green tests, iteration sub-items |
| 5 | `td-40-code-cleanup` | STEP 5 | `40-code-cleanup.md` |
| 6 | `td-50-observability` | STEP 6 | `50-observability.md` |
| 7 | `td-60-tech-debt` | STEP 7 | `60-tech-debt.md` |
| 8 | `td-70-dev-docs` | STEP 8 | `doc/dev/` |
| — | `td-99-commit` | COMMIT | `[x]` mark only; branch name and commit hash are reported in chat, never written to a file |

Each skill lives at `../<skill-name>/SKILL.md`.

All `NN-*.md` artifacts live in `ai-tasks/<JIRA-TASK-ID>/`.

## Task Metadata

Besides step status, the roadmap carries facts the rest of the workflow reads back:

- **Implementation language** — determined at Step 1 (**MANDATORY**), read by steps 2–8 to pick
  the matching `../lsr-<language>/SKILL.md`.

It lives in the `Task Metadata` section of the template and is filled in place, not appended as
free text elsewhere. The branch name is never written here (or anywhere) — it's a chat-only
report from `td-99-commit`.

## Anti-Patterns

- **Do not** mark `[x]` because the work feels done — only a passed gate justifies it.
- **Do not** let an execution subagent mark its own step `[x]`.
- **Do not** skip `[/]` and jump straight from `[ ]` to `[x]` — an unmarked in-progress step
  makes an interrupted run unrecoverable.
- **Do not** invent statuses (`[~]`, `[?]`, strikethrough) or reorder the step list.
- **Do not** keep step notes outside the roadmap (chat only, separate scratch files) — the
  roadmap is the journal.
- **Do not** delete or rewrite earlier sub-items when a step is reopened — append the correction.

## Related Skills

- Workflow entry point: [top-down-workflow](../top-down-workflow/SKILL.md)
- Review subagent that produces the PASS verdict: [td-review](../td-review/SKILL.md)
- Shared working rules and legend usage: [td-00-rules](../td-00-rules/SKILL.md)
- Autonomous execution and its gate: [sprint-task-runner](../sprint-task-runner/SKILL.md)
