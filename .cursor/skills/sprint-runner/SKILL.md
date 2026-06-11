---
name: sprint-runner
description: >-
  Discover Jira sprints via Atlassian MCP, select and start one, run sprint-task-runner
  for each open issue until the sprint is empty, then close the sprint. Use when the user
  asks to run a sprint, execute all sprint tasks, start and finish a sprint, or automate
  a full sprint cycle.
---

# Sprint Runner

Orchestrates a **full sprint lifecycle**: discover sprints → select → start → run every
open task via [sprint-task-runner](../sprint-task-runner/SKILL.md) → close sprint.

Uses **Atlassian MCP** (`project-0-pypost-mcp-atlassian`). PYPOST board id: `34`.

## Autonomous Mode (mandatory)

Run **all phases without stopping for user approval** between tasks.

- **Do not** ask "Shall I run the next task?" after each task completes.
- **Do not** wait for confirmation between Phase 1–5.
- Inherit autonomous rules from sprint-task-runner for each task run.
- Only stop and ask the user when:
  - **sprint selection is ambiguous** (multiple equally valid candidates and no user hint),
  - a **hard blocker** stops sprint-task-runner and cannot be resolved,
  - **missing credentials / MCP auth** blocks Jira operations, or
  - the user **explicitly** asked to pause or approve.

At the **end**, provide one consolidated sprint summary — not per-task prompts.

## Quick Start Checklist

```
Sprint run:
- [ ] Phase 1: Discover sprints (future + active)
- [ ] Phase 2: Select sprint
- [ ] Phase 3: Start sprint (activate)
- [ ] Phase 4: Task loop (sprint-task-runner per open issue)
- [ ] Phase 5: Close sprint and report
```

---

## Phase 1: Discover Sprints

1. Read MCP tool schemas before calling.
2. Fetch sprints from board `34`:
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
short message, then **proceed without waiting**.

---

## Phase 3: Start Sprint

1. If the chosen sprint is already `active`, skip activation.
2. If the chosen sprint is `future`:
   - Check for another `active` sprint on board `34`.
   - If an active sprint has open issues → **stop** and report the conflict (do not
     auto-close another team's active sprint).
   - If the active sprint has **no** open issues → close it:
     `jira_update_sprint` with `state: closed`.
   - Activate the chosen sprint: `jira_update_sprint` with `state: active`.
3. Re-verify open issues with JQL after activation (allow 5–10 s index lag if empty).

---

## Phase 4: Task Loop

Repeat until no open issues remain:

### 4.1 Query open tasks

```jql
Sprint = <sprint_id> AND statusCategory != Done ORDER BY priority DESC, rank ASC
```

If the result is empty → go to **Phase 5**.

### 4.2 Run sprint-task-runner for the next task

Read `.cursor/skills/sprint-task-runner/SKILL.md` and execute it for **one** issue:

- **Skip** sprint-task-runner Phase A steps 1–4 (sprint already selected and active).
- **Do** Phase A step 5–6 for the chosen issue key:
  - Transition to In Progress: `jira_get_transitions` → `jira_transition_issue` (id `21`).
  - Do not pass `comment` unless using Atlassian Document Format.
- **Run** sprint-task-runner Phases B → F end-to-end for that issue.

Pick the **first** issue from the JQL result (highest priority).

### 4.3 After each task

- Confirm the issue reached Done (transition id `31` from Phase F).
- Log a one-line progress note:
  `PYPOST-### done ({worklog_entries} worklogs, {total_tokens} tokens, <n> remaining)`.
- **Immediately** start the next open task — no user gate.
- On **hard blocker** from sprint-task-runner: stop the loop, leave sprint **active**,
  report blocker + remaining issues. Do **not** close the sprint.

---

## Phase 5: Close Sprint and Finish

When JQL returns **zero** open issues:

1. `jira_update_sprint` with `sprint_id` and `state: closed`.
2. Report consolidated summary:
   - Sprint name, id, goal
   - Tasks completed (keys + one-line outcome, worklog count, total tokens/time each)
   - Commits created (hash + branch per task)
   - Blockers skipped (if loop stopped early)
   - Sprint closed confirmation

---

## MCP Reference

| Action | Tool | Key args |
|--------|------|----------|
| List sprints | `jira_get_sprints_from_board` | `board_id: "34"`, `state` |
| Open issues | `jira_search` | `Sprint = <id> AND statusCategory != Done` |
| Activate | `jira_update_sprint` | `state: active` |
| Close | `jira_update_sprint` | `state: closed` |
| Start work | `jira_transition_issue` | transition id `21` |
| Finish issue | `jira_transition_issue` | transition id `31` |
| Log work | `jira_add_worklog` | `time_spent`, `comment` (orchestrator only) |

Sprint custom field id: `customfield_10020` (for spot-checks via `jira_get_issue`).

---

## Anti-Patterns

- **Do not** run multiple sprint-task-runner tasks in parallel
- **Do not** close the sprint while open issues remain (unless user explicitly requests)
- **Do not** auto-close another active sprint that still has open work
- **Do not** re-run Phase 1–3 inside each task — sprint context is set once
- **Do not** skip sprint-task-runner per-step reviews inside each task
- **Do not** ask for approval between tasks in autonomous mode

---

## Related Skills

- Per-task execution: [sprint-task-runner](../sprint-task-runner/SKILL.md)
- Sprint planning and backlog grooming: [jira-sprint-planning](../jira-sprint-planning/SKILL.md)
- Step details: [top-down-workflow](../top-down-workflow/SKILL.md)
