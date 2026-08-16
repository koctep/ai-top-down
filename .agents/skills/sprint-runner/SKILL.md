---
name: sprint-runner
description: >-
  Discover Jira sprints via Atlassian MCP, select one, estimate story points for each open
  issue via subagents, start the sprint, run sprint-task-runner for each open issue until
  the sprint is empty, then close inactive epics and close the sprint. Use when the user
  asks to run a sprint, execute all sprint tasks, start and finish a sprint, or automate
  a full sprint cycle.
---

# Sprint Runner

Orchestrates a **full sprint lifecycle**: discover sprints → select → estimate story points
→ start → run every open task via [sprint-task-runner](../sprint-task-runner/SKILL.md) →
close inactive epics → close sprint.

Uses **Atlassian MCP** (`<JIRA-MCP-SERVER>`). Board id: `<JIRA-BOARD-ID>`.

Configure placeholders — see [jira-sprint-planning](../jira-sprint-planning/SKILL.md).

## Autonomous Mode (mandatory)

Follow [_shared/autonomous-run.md](../_shared/autonomous-run.md) — it owns the terminal
conditions, the progress-reporting rule, the state registry, and context hygiene. The whole
sprint is **one continuous run**: from selection to `state: closed` the turn does not end.

- **Do not** ask "Shall I run the next task?" after each task completes.
- **Do not** wait for confirmation between Phase 1–6.
- **Do not** end the turn between tasks — a closed task is a checkpoint, not a result.
- Inherit autonomous rules from sprint-task-runner for each task run.
- Terminal conditions for a sprint run:
  - the sprint is **closed** (Phase 6.2 confirmed),
  - **sprint selection is ambiguous** (multiple equally valid candidates and no user hint),
  - a **hard blocker** stops sprint-task-runner and cannot be resolved,
  - **missing credentials / MCP auth** blocks Jira operations, or
  - the user **explicitly** asked to pause or approve.

At the **end**, provide one consolidated sprint summary — not per-task prompts.

## Quick Start Checklist

```
Sprint run:
- [ ] Phase 0: Resume check (state registry)
- [ ] Phase 1: Discover sprints (future + active)
- [ ] Phase 2: Select sprint
- [ ] Phase 3: Estimate story points (subagent per open issue)
- [ ] Phase 4: Start sprint (activate)
- [ ] Phase 5: Task loop (sprint-task-runner per open issue)
- [ ] Phase 6: Close inactive epics, close sprint, report
```

---

## Phase 0: Resume Check

Before any Jira call, look for an existing run state registry:
`ai-tasks/sprint-*/00-sprint-state.md`.

- **Found, sprint not closed** → read it, report the resume point in one line, and continue
  from its `next_action`. Skip Phases 1–4 — the sprint is already selected, estimated, and
  active.
- **Found, sprint closed** → ignore it and start a fresh run at Phase 1.
- **Not found** → start at Phase 1.

From here on, rewrite the registry per
[_shared/autonomous-run.md](../_shared/autonomous-run.md) at every phase boundary and after
every completed task.

---

## Phase 1: Discover Sprints

1. Read MCP tool schemas before calling.
2. Fetch sprints from board `<JIRA-BOARD-ID>`:
   - `jira_get_sprints_from_board` with `state: future` (paginate with `start_at` / `limit`)
   - `jira_get_sprints_from_board` with `state: active`
3. For each candidate sprint, count **open** issues:

```jql
Sprint = <sprint_id> AND statusCategory != Done
```

Use `jira_search` (paginate with `page_token` or `start_at` when needed). Prefer JQL over
`jira_get_sprint_issues` for counts — it is more reliable after recent assignments.

4. Build a candidate table: sprint id, name, state, goal, open count, date range.

Skip sprints with **zero** open issues unless the user named that sprint explicitly.

---

## Phase 2: Select Sprint

**User specified a sprint** (name, id, or key phrase) → match and use it.

**Otherwise**, pick automatically in this order:

1. **Active** sprint with the most open issues (continue in-progress work).
2. **Future** sprint with open issues — earliest `startDate` first; tie-break by highest
   open count.
3. If still tied, pick the sprint whose name/goal best matches recent repo context.

Announce the chosen sprint (id, name, goal, open count) and selection rationale in one
short line, then **immediately** create the state registry and continue into Phase 3 — the
announcement is preamble to the next tool call, never a standalone message.

---

## Phase 3: Estimate Story Points

Run **immediately after** sprint selection and **before** activation. Goal: every open
issue in the chosen sprint has a Fibonacci story-point estimate in Jira.

Follow [_shared/story-points.md](../_shared/story-points.md) **existing issue** mode
(estimate subagent → `jira_update_issue`). Issues already created via
[jira-create-issue](../jira-create-issue/SKILL.md) should already have points — skip them.

Story point field: `<JIRA-STORY-POINTS-FIELD-ID>` (discover via `jira_search_fields`
keyword `story point` if unset).

### 3.1 List issues needing estimates

```jql
Sprint = <sprint_id> AND statusCategory != Done ORDER BY priority DESC, rank ASC
```

Fetch `<JIRA-STORY-POINTS-FIELD-ID>` for each issue via `jira_search` or `jira_get_issue`.

**Skip** issues that already have a non-null, non-zero story point value unless the user
explicitly asked to re-estimate.

If every open issue already has points → log one line and proceed to Phase 4.

### 3.2 Estimation subagent (one per issue)

For each issue missing points, run the estimation subagent per
[_shared/story-points.md](../_shared/story-points.md) (existing-issue prompt inputs).
Launch **in parallel** when more than one issue needs estimates.

### 3.3 Write estimates to Jira

After each subagent returns, write points and worklog using the **existing issue**
write path in [_shared/story-points.md](../_shared/story-points.md).

### 3.4 Report and continue

Print a compact table: issue key, summary (truncated), story points, one-line rationale.
Include sprint total story points. Update the state registry and **continue into Phase 4 in
the same turn** — the table is preamble, not a report to hand back.

---

## Phase 4: Start Sprint

1. If the chosen sprint is already `active`, skip activation.
2. If the chosen sprint is `future`:
   - Check for another `active` sprint on board `<JIRA-BOARD-ID>`.
   - If an active sprint has open issues → **stop** and report the conflict (do not
     auto-close another team's active sprint).
   - If the active sprint has **no** open issues → close it:
     `jira_update_sprint` with `state: closed`.
   - Activate the chosen sprint: `jira_update_sprint` with `state: active`.
3. Re-verify open issues with JQL after activation (allow 5–10 s index lag if empty).

---

## Phase 5: Task Loop

Repeat until no open issues remain:

### 5.1 Query open tasks

```jql
Sprint = <sprint_id> AND statusCategory != Done ORDER BY priority DESC, rank ASC
```

If the result is empty → go to **Phase 6**.

### 5.2 Run sprint-task-runner for the next task

Read [sprint-task-runner](../sprint-task-runner/SKILL.md) and execute it for **one** issue:

- **Skip** sprint-task-runner Phase A steps 1–4 (sprint already selected and active).
- **Do** Phase A step 5–6 for the chosen issue key:
  - Transition to In Progress: `jira_get_transitions` → `jira_transition_issue`
    (id `<IN-PROGRESS-TRANSITION-ID>`).
  - Do not pass `comment` unless using Atlassian Document Format.
- **Run** sprint-task-runner Phases B → F end-to-end for that issue.

Pick the **first** issue from the JQL result (highest priority).

### 5.3 After each task

- Confirm the issue reached Done (transition id `<DONE-TRANSITION-ID>` from Phase F).
- Log a one-line progress note:
  `<JIRA-TASK-ID> done ({worklog_entries} worklogs, {total_tokens} tokens, <n> remaining)`.
- Rewrite the state registry: task counts, next issue key, `next_action`.
- **Immediately** re-run 5.1 for the next open task — no user gate, no turn end. A closed
  task is the most tempting false stopping point in this skill; there is none until 6.2.
- On **hard blocker** from sprint-task-runner: stop the loop, leave sprint **active**,
  record the blocker in the registry, report blocker + remaining issues. Do **not** close
  the sprint or run Phase 6.1.

---

## Phase 6: Close Inactive Epics, Close Sprint, Finish

When JQL returns **zero** open issues in the sprint:

### 6.1 Close inactive epics

Before closing the sprint, sweep project epics that no longer have open work:

1. List open epics:

```jql
project = <JIRA-PROJECT-KEY> AND issuetype = Epic AND statusCategory != Done
ORDER BY updated DESC
```

2. For each open epic, count remaining open children (prefer both parent and Epic Link):

```jql
(parent = <EPIC-KEY> OR "Epic Link" = <EPIC-KEY>) AND statusCategory != Done
```

3. Treat an epic as **inactive** (safe to close) when that count is **zero** — all children
   Done, or the epic has no children left open. Do **not** close epics that still have any
   open child (Story, Task, Bug, Debt, etc.).

4. For each inactive epic:
   - `jira_get_transitions` → transition to Done (`<DONE-TRANSITION-ID>`).
   - Optional short comment: children complete / no open scope remaining.
   - Proceed autonomously — do **not** ask for approval per epic.

5. If no open epics, or none are inactive → log one line and continue.

### 6.2 Close sprint

`jira_update_sprint` with `sprint_id` and `state: closed`.

Mark the state registry `closed` — this is what tells a later run to start fresh instead of
resuming.

### 6.3 Report

This is the run's terminal result and the one place a consolidated summary belongs:

- Sprint name, id, goal
- Story points (per issue + sprint total from Phase 3)
- Tasks completed (keys + one-line outcome, worklog count, total tokens/time each)
- Commits created (hash + branch per task)
- Epics closed in 6.1 (keys + one-line reason), or "none"
- Open epics left open (keys + why still active), if any
- Blockers skipped (if loop stopped early)
- Sprint closed confirmation

---

## MCP Reference

| Action | Tool | Key args |
|--------|------|----------|
| List sprints | `jira_get_sprints_from_board` | `board_id: "<JIRA-BOARD-ID>"`, `state` |
| Open issues | `jira_search` | `Sprint = <id> AND statusCategory != Done` |
| Open epics | `jira_search` | `issuetype = Epic AND statusCategory != Done` |
| Epic children | `jira_search` | `parent = KEY OR "Epic Link" = KEY` |
| Activate | `jira_update_sprint` | `state: active` |
| Close sprint | `jira_update_sprint` | `state: closed` |
| Start work | `jira_transition_issue` | transition id `<IN-PROGRESS-TRANSITION-ID>` |
| Finish issue / epic | `jira_transition_issue` | transition id `<DONE-TRANSITION-ID>` |
| Story points | `jira_update_issue` | `additional_fields: {"<JIRA-STORY-POINTS-FIELD-ID>": N}` |
| Log work | `jira_add_worklog` | `time_spent`, `comment` (orchestrator only) |

Sprint custom field id: `<JIRA-SPRINT-CUSTOM-FIELD-ID>` (for spot-checks via `jira_get_issue`).

Estimation details: [_shared/story-points.md](../_shared/story-points.md).

---

## Anti-Patterns

- **Do not** run multiple sprint-task-runner tasks in parallel
- **Do not** close the sprint while open issues remain (unless user explicitly requests)
- **Do not** skip Phase 6.1 epic sweep when closing a completed sprint
- **Do not** close an epic that still has any open children
- **Do not** auto-close another active sprint that still has open work
- **Do not** re-run Phase 1–4 inside each task — sprint context is set once
- **Do not** skip Phase 3 when open issues lack story points (unless user opted out)
- **Do not** run estimation subagents with write access; verify the tree is unchanged after
  (same integrity check as [td-review](../td-review/SKILL.md))
- **Do not** skip sprint-task-runner per-step reviews inside each task
- **Do not** ask for approval between tasks in autonomous mode
- **Do not** end the turn between tasks or phases — only the terminal conditions in
  [_shared/autonomous-run.md](../_shared/autonomous-run.md) end a sprint run
- **Do not** emit a phase summary as a standalone message — pair it with the next tool call
- **Do not** re-run Phase 1–4 when Phase 0 found an open state registry
- **Do not** carry raw Jira JSON forward — reduce to the fields the next action needs

---

## Related Skills

- Continuous-run contract and state registry: [_shared/autonomous-run.md](../_shared/autonomous-run.md)
- Per-task execution: [sprint-task-runner](../sprint-task-runner/SKILL.md)
- Create issues with estimate: [jira-create-issue](../jira-create-issue/SKILL.md)
- Sprint planning and backlog grooming: [jira-sprint-planning](../jira-sprint-planning/SKILL.md)
- Step details: [top-down-workflow](../top-down-workflow/SKILL.md)
- Review subagent procedure: [td-review](../td-review/SKILL.md)
