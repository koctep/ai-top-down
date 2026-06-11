---
name: top-down-workflow
description: Execute the top-down development workflow (Steps 1-7) for implementing Jira tasks, following project rules. Use when the user asks to implement a Jira task, follow the top-down approach, or work on sprint tasks.
---

# Top-Down Development Workflow

## Quick Start

When asked to implement a Jira task using the top-down approach, follow these 7 sequential
steps. **NEVER skip steps** and **always get user approval** before proceeding to the next
step (unless explicitly requested to run them sequentially in a batch).

The workflow relies on specific `.cursor/rules/*.mdc` files for detailed instructions. Always
read the relevant rule file before starting a step.

## The 7 Steps

1. **Requirements** (`10-requirements.mdc`)
   Gather business requirements and create `00-roadmap.md` and `10-requirements.md`. Do not
   write code or architecture.
2. **Architecture** (`20-architecture.mdc`)
   High-level architectural design and implementation plan. Create `20-architecture.md`.
3. **Development** (`30-development.mdc`)
   Iterative implementation with minimal meaningful changes. Update `00-roadmap.md`.
4. **Code Cleanup** (`40-code-cleanup.mdc`)
   Lint, format, and prepare code for review. Create `40-code-cleanup.md`.
5. **Observability** (`50-observability.mdc`)
   Add logging and metrics. Create `50-observability.md`.
6. **Review** (`60-review.mdc`)
   Technical debt analysis and follow-up task creation. Create `60-tech-debt.md`.
7. **Dev Docs** (`70-dev-docs.mdc`)
   Create or update developer documentation in `doc/dev`.

## Worklog Orchestration

The orchestrator (parent agent running this workflow) owns all Jira worklog writes. See
[_shared/token-worklog.md](../_shared/token-worklog.md) for the conversion formula and MCP
details.

**Formula:** `100 tokens = 1 min`, linear, per entry. `time_spent` is always `{minutes}m`
(never `1h` / `1h 30m` — Jira converts to hours in reports).

### When to log

| Event | Who writes worklog | When |
| ----- | ------------------ | ---- |
| Execution subagent returned | Orchestrator | Immediately after subagent |
| Review subagent returned | Orchestrator | Immediately after subagent |
| Fix subagent returned | Orchestrator | Immediately after each fix |
| Blocker review / fix returned | Orchestrator | Immediately after each subagent |
| Workflow complete | Orchestrator | After Step 7, **before** commit and Done |

### After each subagent

1. Parse `## Worklog` from the subagent return (`tokens_used`, `role`, `step`, `step_name`).
2. If `tokens_used > 0`:
   - `time_spent = convert_tokens_to_time_spent(tokens_used)`
   - `jira_add_worklog(issue_key, time_spent, comment)` using the subagent comment template.
3. Track `worklog_count` and running `total_tokens` for the task summary.
4. Proceed to the next step.

Subagents **do not** call Jira. They only return the `## Worklog` block.

### Final orchestrator worklog

After Step 7 (and any blocker-review phases), **before commit**:

1. Compute orchestrator-only `tokens_used` (coordination, prompts, MCP, git — excluding
   subagent totals already logged).
2. If `tokens_used > 0`, call `jira_add_worklog` with the orchestrator comment template.
3. Report `worklog_count`, `total_tokens`, and total time in the task summary.

## AI Execution Pattern

To maximize efficiency and ensure high quality, use the `Task` tool (subagents) to execute
each step:

1. **Execution Subagent**: Launch a subagent with `generalPurpose` type to execute the step.
   Pass the relevant `.mdc` file path and the Jira task details in the prompt.
2. **Log worklog**: Parse subagent `## Worklog` → `jira_add_worklog` (orchestrator).
3. **Review Subagent**: Launch a second subagent to review artifacts against the `.mdc` rule
   file. Have it fix any issues it finds (or launch a fix subagent if readonly).
4. **Log worklog**: Parse review subagent `## Worklog` → `jira_add_worklog` (orchestrator).
5. **User Approval**: Present results and wait for approval before the next step (unless the
   user explicitly asked to run multiple steps automatically).
6. After Step 7: **orchestrator worklog** → commit → close Jira task.

### Example Execution

```markdown
1. Agent: *Runs subagent to perform Step 1 (Requirements)*
2. Agent: *Parses Worklog → jira_add_worklog (subagent, Step 1 execution)*
3. Agent: *Runs subagent to review Step 1 artifacts*
4. Agent: *Parses Worklog → jira_add_worklog (subagent, Step 1 review)*
5. Agent: "Step 1 is complete and reviewed. Here is the summary... Shall I proceed to Step 2?"
...
N. Agent: *After Step 7 → jira_add_worklog (orchestrator)*
N+1. Agent: *Commit and close Jira task*
```

### Subagent prompt — required return block

Include in every subagent prompt:

```markdown
End your response with:

## Worklog
tokens_used: <number>
role: execution|review|fix|blocker_review
step: <N>
step_name: <name>
```

Use `tokens_used: 0` when unavailable.

## Critical Rules

- **Roadmap Tracking**: Always maintain the `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` file. Mark
  the current step as `[/]` when starting, and `[x]` when completed.
- **No Technical Details in Requirements**: Step 1 MUST NOT contain database schemas, API
  designs, or implementation details. Focus strictly on business goals and user stories.
- **Clean Before Review**: Step 4 (Code Cleanup) is mandatory before Step 6 (Review).
- **Subagents**: Use subagents to keep context clean and focused, especially for the
  Development loop and code reviews.
- **Worklog per subagent**: Log immediately after each subagent — never batch all tokens into
  one entry at task close.
- **Orchestrator worklog**: Always log orchestrator tokens separately at the end.

## Related Skills

- Full sprint cycle (discover → start → all tasks → close):
  [sprint-runner](../sprint-runner/SKILL.md)
- End-to-end single sprint task (Jira + commit + close):
  [sprint-task-runner](../sprint-task-runner/SKILL.md)
