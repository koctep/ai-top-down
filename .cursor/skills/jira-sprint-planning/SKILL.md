---
name: jira-sprint-planning
description: Analyze Jira backlog, propose sprint topics, create future sprints, and assign issues via Atlassian MCP. Use when the user asks to plan sprints, analyze backlog, propose sprint themes, create Jira sprints, or add issues to sprints.
---

# Jira Sprint Planning

Configure placeholders for your Jira instance before use:

| Placeholder | Meaning | Example |
| --- | --- | --- |
| `<JIRA-MCP-SERVER>` | Atlassian MCP server id | `user-mcp-atlassian` |
| `<JIRA-PROJECT-KEY>` | Jira project key | `PROJ` |
| `<JIRA-TASK-ID>` | Full issue key | `PROJ-123` |
| `<JIRA-BOARD-ID>` | Agile board id | `12` |
| `<JIRA-BASE-URL>` | Jira instance base URL | `https://your-org.atlassian.net` |
| `<JIRA-SPRINT-CUSTOM-FIELD-ID>` | Sprint custom field id | `customfield_XXXXX` |
| `<JIRA-STORY-POINTS-FIELD-ID>` | Story point estimate field id | `customfield_10016` |
| `<JIRA-DEBT-ISSUE-TYPE>` | Issue type for tech-debt follow-ups | `Debt`, `Task` |
| `<IN-PROGRESS-TRANSITION-ID>` | Transition id → In Progress | `21` |
| `<DONE-TRANSITION-ID>` | Transition id → Done | `31` |
| `<REPO-PATH>` | Local path to the target repository | `/path/to/repo` |

## Quick Start

When the user asks to analyze backlog and plan sprints:

1. Read Atlassian MCP tool schemas before calling (`jira_search`, `jira_get_agile_boards`, `jira_get_sprints_from_board`, `jira_create_sprint`, `jira_update_sprint`, `jira_add_issues_to_sprint`).
2. Analyze open backlog and recent activity.
3. Propose **3 sprint topics** with goals, candidate issue keys, and rationale.
4. On user approval: create/update sprints and add issues.
5. Verify assignments with JQL, not only the add-to-sprint response.

## MCP Server

Use `<JIRA-MCP-SERVER>`.

Board id: `<JIRA-BOARD-ID>` (`<JIRA-PROJECT-KEY> board`).

## Backlog Analysis

```jql
project = <JIRA-PROJECT-KEY> AND statusCategory != Done ORDER BY priority DESC, updated DESC
```

Also fetch:

- `jira_get_agile_boards` with `project_key: <JIRA-PROJECT-KEY>`
- `jira_get_sprints_from_board` for `active`, `future`, and recent `closed` sprints

Paginate with `page_token` when `next_page_token` is present. Sample at least 100–150 open issues before proposing topics.

### How to cluster issues

Group by coherent themes, not random priority slices:

| Cluster signal | Examples |
|---|---|
| Recent feature follow-ups | Subsystem UX polish, security hardening, tree/list correctness |
| Shared labels | `tech-debt`, `security`, `testing`, `ui` |
| Parent/source ticket in summary | `[<JIRA-TASK-ID>]`, `[<JIRA-TASK-ID>]` |
| Cross-cutting debt | Large component growth, missing integration tests |

Prefer themes that:

- Close a recently shipped feature wave
- Share code ownership or subsystem
- Fit in one 2-week sprint (roughly 8–15 issues)

Deprioritize for primary sprint slots:

- Old audit-only debt with no product impact
- Duplicate/overlapping test tasks (merge when grooming)
- Meta/process tasks (`sync tasks with code`, lint-debt-only items)

## Proposal Format

Present exactly **3 topics**. For each:

1. **Sprint name** (≤ 30 chars — Jira limit)
2. **Goal** (1 sentence)
3. **Why now** (link to recent closed sprints or fresh backlog cluster)
4. **Candidate issues** (explicit `<JIRA-TASK-ID>` keys)
5. **Expected outcome**

If the user asked for analysis only, stop after the proposal. Do not create sprints until they confirm.

For structured backlog analysis with many issues, prefer a canvas over long markdown tables.

## Creating Sprints

### Reuse existing future sprint when possible

Before creating, check `jira_get_sprints_from_board` with `state: future`. Update an existing matching sprint with `jira_update_sprint` instead of creating a duplicate.

### Defaults

- **Duration**: 2 weeks per sprint
- **State**: `future`
- **Dates**: sequential windows after the latest closed/future sprint
- **Required fields for create**: `board_id`, `name`, `start_date`, `end_date`; optional `goal`

Example:

```text
Sprint 1: 2026-06-23 → 2026-07-06
Sprint 2: 2026-07-07 → 2026-07-20
Sprint 3: 2026-07-21 → 2026-08-03
```

Use ISO 8601 UTC (`2026-06-23T00:00:00.000Z`).

### Naming

If Jira rejects a name (> 30 chars), shorten the title and keep full intent in `goal`.

## Adding Issues to Sprints

Use `jira_add_issues_to_sprint`:

```json
{
  "sprint_id": "<sprint-id>",
  "issue_keys": "<JIRA-TASK-ID>,<JIRA-TASK-ID>,<JIRA-TASK-ID>"
}
```

Rules:

- Add only open issues the user approved for that sprint
- Batch by sprint (one call per sprint)
- Do not move issues silently across sprints without telling the user

## Verification

After adding issues:

1. Wait briefly for Jira index lag (5–10 s) if needed
2. Verify with JQL:

```jql
Sprint = <sprint-id> ORDER BY key ASC
```

3. Spot-check individual issues when JQL is slow:

```text
jira_get_issue with fields: summary,<JIRA-SPRINT-CUSTOM-FIELD-ID>
```

Sprint field id: `<JIRA-SPRINT-CUSTOM-FIELD-ID>`.

`jira_get_sprint_issues` may return empty for future sprints immediately after assignment — treat JQL + `<JIRA-SPRINT-CUSTOM-FIELD-ID>` as source of truth.

Report final counts per sprint and list issue keys.

## Reference Topic Templates

Use as starting points, then adapt to current backlog:

### 1. Feature UX Polish

Typical candidates: inline edit cleanup, delete confirmation, dialog sync/validation, naming helper/tests.

### 2. Security and Storage Hardening

Typical candidates: credential provider chain, encryption settings UI, storage adapter refactor, async crypto, masking/logging integration tests.

### 3. Data Structure / Navigation Correctness

Typical candidates: stable entity identity, stale-state reconciliation after delete, incremental tree updates, large component extraction, delete/rename regression tests.

## Related Skills

- Create issues with story-point estimate: [jira-create-issue](../jira-create-issue/SKILL.md)
- Run a started sprint end-to-end: [sprint-runner](../sprint-runner/SKILL.md)
- Execute a single sprint task: [sprint-task-runner](../sprint-task-runner/SKILL.md)

## Checklist

```
Sprint planning:
- [ ] Read MCP tool schemas
- [ ] Fetch open backlog (paginated)
- [ ] Review board + existing sprints
- [ ] Propose 3 topics with explicit issue keys
- [ ] Get user approval (unless explicitly told to create now)
- [ ] Create/update future sprints with goals and dates
- [ ] Add approved issues per sprint
- [ ] Verify via JQL and report counts
```
