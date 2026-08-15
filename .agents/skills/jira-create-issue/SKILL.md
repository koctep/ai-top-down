---
name: jira-create-issue
description: >-
  Estimate Fibonacci story points via a readonly subagent, then create a Jira Story,
  Task, or Debt issue with points set. Use when creating any non-epic Jira issue, or
  when another skill needs a create-with-estimate helper (tech-debt sync, audit stories,
  sprint-task-runner follow-ups).
---

# Jira Create Issue

Estimate story points, then create one Jira issue with points already set.

Uses **Atlassian MCP** (`<JIRA-MCP-SERVER>`). Configure placeholders — see
[jira-sprint-planning](../jira-sprint-planning/SKILL.md).

Estimation protocol: [_shared/story-points.md](../_shared/story-points.md).
Worklog rules: [_shared/token-worklog.md](../_shared/token-worklog.md).

## When to use

- Creating a **Story**, **Task**, **Debt**, or project-equivalent non-epic issue
- Any caller that would otherwise call `jira_create_issue` directly for those types

**Do not** use this skill for Epics — create epics with raw `jira_create_issue` and
**omit** story points (see [jira-audit-tickets](../jira-audit-tickets/SKILL.md)).

## Quick Start

```
- [ ] Read MCP schemas (jira_create_issue, jira_add_worklog; jira_search_fields if needed)
- [ ] Resolve <JIRA-STORY-POINTS-FIELD-ID> if unset
- [ ] Launch readonly estimation subagent (draft fields)
- [ ] Parse story_points + rationale
- [ ] jira_create_issue with SP in additional_fields
- [ ] Worklog on new key if tokens_used > 0
- [ ] Return key, url, story_points, rationale to caller
```

## Caller inputs

| Input | Required | Notes |
| --- | --- | --- |
| `project_key` | yes | `<JIRA-PROJECT-KEY>` |
| `issue_type` | yes | Story / Task / Debt / etc. — not Epic |
| `summary` | yes | Max ~240 chars |
| `description` | yes | Markdown |
| `priority` | no | e.g. `High` / `Medium` / `Low` |
| `labels` | no | string array |
| `parent` | no | Epic or parent key (next-gen) |
| `epic_link` / `epicKey` | no | Classic epic link if `parent` unsupported |
| `related_artifacts` | no | Paths for estimation context (e.g. debt md) |
| Other `additional_fields` | no | Merged with SP; must not override SP field |

## Flow (per issue)

1. **Estimate** — launch one `Task` subagent (`generalPurpose`, `readonly: true`)
   using [_shared/story-points.md](../_shared/story-points.md) **draft** mode.
   Pass proposed summary, description, issue type, priority, labels, parent/epic,
   repo `<REPO-PATH>`, and any related artifacts.
2. **Parse** — read `story_points` (must be one of 1, 2, 3, 5, 8, 13) and `rationale`.
3. **Create** — call `jira_create_issue` once:

```text
jira_create_issue(
  project_key: "<JIRA-PROJECT-KEY>",
  issue_type: "<type>",
  summary: "<summary>",
  description: "<description>",
  additional_fields: {
    "priority": {"name": "<optional>"},
    "labels": ["..."],
    "parent": "<optional>",
    "<JIRA-STORY-POINTS-FIELD-ID>": <story_points>
  }
)
```

Omit unused optional keys. `additional_fields` is a JSON **string** per MCP schema.

4. **Worklog** — if estimation `tokens_used > 0`, call `jira_add_worklog` on the **new**
   key (`role: estimation`).
5. **Return** to caller:

```text
{
  key: "<JIRA-TASK-ID>",
  url: "<JIRA-BASE-URL>/browse/<JIRA-TASK-ID>",
  story_points: <N>,
  rationale: "<text>"
}
```

## Multi-issue creates

When creating many issues (e.g. debt sync, audit focus stories):

1. Launch estimation subagents **in parallel** (batches of 8–10 if large).
2. Prefer **estimate → create per item** as each estimate returns (fail fast).
3. After the first successful create, **verify** with `jira_get_issue` on that key.
4. If verification fails, stop — do not write phantom keys into markdown.

**Do not use `jira_batch_create_issues`** — it may report success without persisting.

## Anti-Patterns

- **Do not** create Story/Task/Debt without an estimation subagent first
- **Do not** set story points on Epics
- **Do not** use heuristic/default points — always use the subagent Fibonacci result
- **Do not** use `jira_batch_create_issues`
- **Do not** run estimation subagents with write access — readonly only
- **Do not** ask the user for approval between estimate and create

## Related

- Estimation protocol: [_shared/story-points.md](../_shared/story-points.md)
- Callers: [tech-debt-jira-sync](../tech-debt-jira-sync/SKILL.md),
  [sprint-task-runner](../sprint-task-runner/SKILL.md) Phase D,
  [jira-audit-tickets](../jira-audit-tickets/SKILL.md)
- Existing-issue fill-in: [sprint-runner](../sprint-runner/SKILL.md) Phase 3
