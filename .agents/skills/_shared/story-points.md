# Story Point Estimation

Shared protocol for Fibonacci story-point estimates via readonly subagents.

Referenced by [jira-create-issue](../jira-create-issue/SKILL.md) and
[sprint-runner](../sprint-runner/SKILL.md) Phase 3.

Configure placeholders — see [jira-sprint-planning](../jira-sprint-planning/SKILL.md).
Story point field: `<JIRA-STORY-POINTS-FIELD-ID>` (discover via `jira_search_fields`
keyword `story point` if unset).

## Scale

Allowed values only: **1, 2, 3, 5, 8, 13**.

Estimate effort for the **top-down workflow** (Steps 1–8, including Failing
Repro). Do not implement.

## When to skip

- **Epics** — never set story points on epics.
- **Existing issues** that already have a non-null, non-zero value — skip unless the
  user explicitly asked to re-estimate.

## Estimation subagent

Launch a read-only subagent — file read and search, no edits — `readonly: true`. Pick the
agent type your harness offers for that capability; do not guess a type name.

One subagent per issue (or draft). Independent estimates may run **in parallel**.

### Prompt inputs

**Existing issue** (sprint-runner fill-in):

- Issue key, summary, description, issue type, priority, labels, parent/epic links
- Repo: `<REPO-PATH>`
- Related artifacts when present: `ai-tasks/<JIRA-TASK-ID>/`, linked parent context

**Draft** (before create — no key yet):

- Proposed summary, description, issue type, priority, labels, parent/epic (if any)
- Repo: `<REPO-PATH>`
- Related artifacts when present (e.g. `ai-tasks/<parent-key>/60-tech-debt.md`)

Always include:

- Scale: Fibonacci **1, 2, 3, 5, 8, 13** only
- Instruction: estimate effort for the top-down workflow; do not implement
- Instruction: do **not** ask the user for approval

### Required return format

```markdown
## Estimate
story_points: <1|2|3|5|8|13>
rationale: <1–3 sentences>

## Worklog
tokens_used: <number>
role: estimation
step: 0
step_name: story point estimate
```

## Write paths

### On create

Include story points in `jira_create_issue` `additional_fields` (see
[jira-create-issue](../jira-create-issue/SKILL.md)):

```text
additional_fields: {
  ...,
  "<JIRA-STORY-POINTS-FIELD-ID>": <story_points>
}
```

### On existing issue

After the subagent returns, update via `jira_update_issue`:

```text
jira_update_issue(
  issue_key: "<JIRA-TASK-ID>",
  fields: "{}",
  additional_fields: "{\"<JIRA-STORY-POINTS-FIELD-ID>\": <story_points>}"
)
```

### Worklog

If `tokens_used > 0`, log worklog on the issue key (new or existing) per
[token-worklog.md](token-worklog.md) (`role: estimation`).
