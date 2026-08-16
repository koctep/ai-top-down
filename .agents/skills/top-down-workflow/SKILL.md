---
name: top-down-workflow
description: Execute the top-down development workflow (Steps 1-8) for implementing Jira tasks, following project rules. Use when the user asks to implement a Jira task, follow the top-down approach, or work on sprint tasks.
---

# Top-Down Development Workflow

## Quick Start

When asked to implement a Jira task using the top-down approach, follow these 8 sequential
steps. **NEVER skip steps** and **always get user approval** before proceeding to the next
step (unless explicitly requested to run them sequentially in a batch).

The workflow relies on specific `td-*` skills for detailed instructions. Always read the
relevant step skill before starting a step.

## The 8 Steps

1. **Requirements** ([td-10-requirements](../td-10-requirements/SKILL.md))
   Gather business requirements and create `00-roadmap.md` and `10-requirements.md`. Do not
   write code or architecture.
2. **Architecture** ([td-20-architecture](../td-20-architecture/SKILL.md))
   High-level architectural design and implementation plan. Create `20-architecture.md`.
   Must include a failing-repro plan for Step 3 (or document N/A for docs-only work).
3. **Failing Repro** ([td-25-failing-repro](../td-25-failing-repro/SKILL.md))
   Write an automated red test that demonstrates the defect or missing behavior. **No
   production fix.** Execution and review **must** run in separate subagents.
4. **Development** ([td-30-development](../td-30-development/SKILL.md))
   Iterative implementation with minimal meaningful changes; make the red test green.
   Update `00-roadmap.md`.
5. **Code Cleanup** ([td-40-code-cleanup](../td-40-code-cleanup/SKILL.md))
   Lint, format, and prepare code for review. Create `40-code-cleanup.md`.
6. **Observability** ([td-50-observability](../td-50-observability/SKILL.md))
   Add logging and metrics. Create `50-observability.md`.
7. **Review** ([td-60-review](../td-60-review/SKILL.md))
   Technical debt analysis and follow-up task creation. Create `60-tech-debt.md`.
8. **Dev Docs** ([td-70-dev-docs](../td-70-dev-docs/SKILL.md))
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
| Workflow complete | Orchestrator | After Step 8, **before** commit and Done |

### After each subagent

1. Parse `## Worklog` from the subagent return (`tokens_used`, `role`, `step`, `step_name`).
2. If `tokens_used > 0`:
   - `time_spent = convert_tokens_to_time_spent(tokens_used)`
   - `jira_add_worklog(issue_key, time_spent, comment)` using the subagent comment template.
3. Track `worklog_count` and running `total_tokens` for the task summary.
4. Proceed to the next step.

Subagents **do not** call Jira. They only return the `## Worklog` block.

### Final orchestrator worklog

After Step 8 (and any blocker-review phases), **before commit**:

1. Compute orchestrator-only `tokens_used` (coordination, prompts, MCP, git — excluding
   subagent totals already logged).
2. If `tokens_used > 0`, call `jira_add_worklog` with the orchestrator comment template.
3. Report `worklog_count`, `total_tokens`, and total time in the task summary.

## AI Execution Pattern

To maximize efficiency and ensure high quality, use the `Task` tool (subagents) to execute
each step.

**Naming subagents:** this skill describes each subagent by the **capability** it needs, not
by a harness-specific agent type name — those names differ between AI tools and change
between releases. Read the agent types your harness offers and pick the one matching the
described capability; never guess a type name.

1. **Execution Subagent**: Launch a general-purpose subagent — file read, write, and shell
   access — to execute the step. Pass the relevant `td-*` skill path and the Jira task
   details in the prompt.
2. **Log worklog**: Parse subagent `## Worklog` → `jira_add_worklog` (orchestrator).
3. **Review Subagent**: Launch a read-only subagent — file read and search — to review
   artifacts against the step skill. It reports gaps; it never fixes them. Launch a
   separate fix subagent for anything it finds.
4. **Log worklog**: Parse review subagent `## Worklog` → `jira_add_worklog` (orchestrator).
5. **User Approval**: Present results and wait for approval before the next step (unless the
   user explicitly asked to run multiple steps automatically).
6. After Step 8: **orchestrator worklog** → commit → close Jira task.

**Step 3 (Failing Repro):** Never merge writing the red test and reviewing it into one
`Task` call. Always run execution, then a separate review subagent.

### Review subagent integrity check

Read-only review is an **instruction in the subagent prompt, not an enforced parameter**.
The subagent-launch tool has no read-only flag, and any agent with shell access can write
regardless of which other tools it holds. Verify instead of trusting:

1. Before launching a review subagent, record the working tree: `git status --porcelain`
   and the output of `git diff`.
2. After it returns, record both again and compare.
3. If they differ, the review is **invalid** — revert the subagent's changes (`git checkout`
   for tracked files, delete untracked ones), then re-run the review, restating that it
   must not edit.

Apply the same check to the Step 3 fix subagent, which may edit tests only: its diff must
touch the test layout alone. Anything outside it is reverted and re-run.

### Example Execution

```markdown
1. Agent: *Runs subagent to perform Step 1 (Requirements)*
2. Agent: *Parses Worklog → jira_add_worklog (subagent, Step 1 execution)*
3. Agent: *Runs subagent to review Step 1 artifacts*
4. Agent: *Parses Worklog → jira_add_worklog (subagent, Step 1 review)*
5. Agent: "Step 1 is complete and reviewed. Here is the summary... Shall I proceed to Step 2?"
...
A. Agent: *After Step 2 approval → execution subagent writes failing repro (Step 3)*
B. Agent: *Worklog → separate review subagent for Step 3 red test*
C. Agent: *Worklog → approval → Step 4 Development (make tests green)*
...
N. Agent: *After Step 8 → jira_add_worklog (orchestrator)*
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

Use `tokens_used: 0` when unavailable. For Step 3 use `step_name: Failing Repro`.

## Critical Rules

- **Roadmap Tracking**: Always maintain the `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` file. Mark
  the current step as `[/]` when starting, and `[x]` when completed.
- **No Technical Details in Requirements**: Step 1 MUST NOT contain database schemas, API
  designs, or implementation details. Focus strictly on business goals and user stories.
- **Red Before Green**: Do not implement the production fix until Step 3 (Failing Repro) has
  a reviewed red test (or documented N/A for no behavioral change). Step 3 execution and
  review **must** be separate subagents.
- **Clean Before Review**: Step 5 (Code Cleanup) is mandatory before Step 7 (Review).
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
