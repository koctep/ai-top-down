# Token → Jira Worklog

Shared rules for converting AI token usage into Jira `time_spent` worklog entries.

Referenced by [top-down-workflow](../top-down-workflow/SKILL.md),
[sprint-task-runner](../sprint-task-runner/SKILL.md), and
[sprint-runner](../sprint-runner/SKILL.md).

## Constants

| Constant | Value |
| -------- | ----- |
| `TOKENS_PER_MINUTE` | 100 |

Linear conversion (no buckets):

- `N` tokens = `N / 100` minutes

## `convert_tokens_to_time_spent(tokens)`

Apply per worklog entry (subagent or orchestrator). Always use **minutes only** in
`time_spent` — do not convert to hours; Jira aggregates hours in reports itself.

```text
if tokens <= 0: skip worklog (return None)

minutes = ceil(tokens / TOKENS_PER_MINUTE)
minutes = max(minutes, 1)
time_spent = f"{minutes}m"
```

Examples:

| Tokens | `time_spent` |
| ------ | ------------ |
| 100 | `1m` |
| 250 | `3m` |
| 6 000 | `60m` |
| 6 150 | `62m` |

## MCP call

Read `jira_add_worklog` schema before calling.

```text
jira_add_worklog(
  issue_key: "PYPOST-###",
  time_spent: "<from convert_tokens_to_time_spent>",
  comment: "<markdown comment below>"
)
```

Only the **orchestrator** calls Jira. Subagents return token data; they do not log work.

## Subagent return block

Every subagent must end its response with:

```markdown
## Worklog
tokens_used: <number>
role: execution|review|fix|blocker_review
step: <N>
step_name: <name>
```

Use `tokens_used: 0` when the count is unavailable. The orchestrator skips worklog when
`tokens_used` is 0.

## Comment templates

### Subagent worklog

```markdown
Agent: subagent
Role: {role}
Step: {step} — {step_name}
Tokens: {tokens_used} (= {minutes}m @ 100 tokens/min)
Task: {issue_key}
```

### Orchestrator worklog (final)

```markdown
Agent: orchestrator
Scope: coordination, planning, MCP, commit prep
Tokens: {tokens_used} (= {minutes}m @ 100 tokens/min)
Task: {issue_key}
Subagent worklogs: {count} entries logged
```

## Orchestrator algorithm

After **each** subagent returns:

1. Parse the `## Worklog` block.
2. If `tokens_used > 0`, call `jira_add_worklog` with the subagent comment template.
3. Increment `worklog_count` and `total_tokens`.

After all workflow steps, **before commit / Done**:

1. Compute orchestrator-only `tokens_used` (coordination overhead, not subagent totals).
2. If `tokens_used > 0`, call `jira_add_worklog` with the orchestrator comment template.
3. Include `worklog_count` and `total_tokens` in the task summary.

## Rules

- `time_spent` must always be minutes (`3m`, `60m`) — never hours (`1h`, `1h 2m`).
- Write worklog **immediately** after each subagent — do not batch at task close.
- Do not close a Jira task if a subagent reported `tokens_used > 0` but worklog was not
  written.
- Log orchestrator tokens in a **separate** final entry — subagent tokens are already
  recorded per subagent.
