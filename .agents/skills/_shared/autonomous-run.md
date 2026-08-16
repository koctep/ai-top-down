# Autonomous Run Contract

Shared rules that keep a long autonomous run going: when the turn may end, how to report
progress without ending it, and what state to persist so an interruption is cheap.

Referenced by [sprint-runner](../sprint-runner/SKILL.md) and
[sprint-task-runner](../sprint-task-runner/SKILL.md).

## Why this exists

Some harnesses end the assistant turn on **any** message that is not a tool call. A run
that announces "sprint selected, proceeding" as a standalone message has already handed
control back to the user — the "proceed without waiting" that follows is unreachable.
"Do not ask for approval" is therefore not enough; the rule is **do not end the turn**.

## Terminal conditions

End the turn **only** when one of these is true. This list is exhaustive.

1. The run reached its terminal result (sprint closed, or the single task is Done and
   committed).
2. A **hard blocker** survived the skill's fix loops and cannot be resolved without the
   user.
3. **Missing credentials or MCP auth** blocks Jira or git operations.
4. The user **explicitly** asked to pause, approve, or stop.

Everything else — a finished phase, a finished step, a passing review, a closed task, a
long tool result, a near-full context — is a **mid-run checkpoint**, not a stopping point.

## Progress is commentary, not a final message

Progress reporting is required by the runner skills. Emit it as preamble text **in the
same turn as the next tool call**, never as a standalone message.

**Continuation rule:** after writing any progress line, the next thing produced must be a
tool call. If the next action would be "wait" or "report and stop", check the terminal
conditions above — if none applies, take the next action instead.

Consolidated summaries belong to terminal condition 1 or 2. There is exactly **one** final
message per run.

## State registry

Maintain `ai-tasks/sprint-<sprint_id>/00-sprint-state.md`. Rewrite it (full overwrite, not
append) after every phase boundary, every completed task, and every subagent whose result
changes the next action.

```markdown
# Sprint <sprint_id> — run state

sprint: <id> <name> (<state>)
phase: <current runner phase>
tasks: <total> total, <done> done, <open> open
current: <JIRA-TASK-ID> — <phase/step> — <what just finished>
next_action: <the single next operation to perform>
blockers: none | <key>: <one line>
updated: <ISO timestamp>
```

`next_action` is the point of the file: it must be specific enough to resume from without
re-deriving anything (`launch B2 review subagent for step 4`, not `continue task`).

Keep the whole file under ~20 lines. It is a resume pointer, not a log.

## Resume

Before starting a fresh run, check for `00-sprint-state.md` with a sprint that is not
closed. If found, read it and continue from `next_action` — skip discovery, selection,
estimation, and activation. Restarting those phases on an active sprint wastes context and
risks duplicate writes.

## Context hygiene

A run that burns context on raw tool output stops earlier and resumes worse.

- Request narrow fields from Jira (`fields` limited to key, summary, status, priority,
  story points). Never carry a full issue JSON forward.
- Reduce every tool result to the facts the next action needs — a table row, a count, a
  verdict — before continuing.
- Compress each subagent result to 3–5 lines (verdict, files touched, `tokens_used`) and
  put the durable part in the state registry.
- Progress lines are one line each. Detail belongs in the run artifacts.

When context runs low: write the state registry **first**, then keep going. Do not end the
turn to "start fresh" — the registry exists so compaction is transparent.

## Rules

- Do not end the turn outside the terminal conditions.
- Do not emit a progress report as a standalone message — pair it with the next tool call.
- Do not treat a completed phase, step, or task as a natural stopping point.
- Do not re-run discovery or activation phases when the state registry shows an active run.
- Do not let the state registry go stale — a wrong `next_action` is worse than none.
