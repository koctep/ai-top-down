---
name: tech-debt-jira-sync
description: Scan ai-tasks/*/60-tech-debt.md for unticketed follow-ups, create Jira Debt issues with correct priority via Atlassian MCP, and write browse links back into each task's 60-tech-debt.md (not 00-tech-debt-consolidated.md). Use when the user asks to ticket tech debt, sync debt to Jira, find unticketed 60-tech-debt items, or bulk-create Debt follow-ups from ai-tasks artifacts.
---

# Tech Debt Jira Sync

Sync unticketed follow-ups from `ai-tasks/*/60-tech-debt.md` into Jira **Debt**
issues and write links back into **each task's `60-tech-debt.md`** — that file is
the source of truth, not `ai-tasks/00-tech-debt-consolidated.md`.

Uses **Atlassian MCP** (`<JIRA-MCP-SERVER>`). Configure placeholders — see
[jira-sprint-planning](../jira-sprint-planning/SKILL.md).

For a **single sprint task** closing flow, prefer Phase D in
[sprint-task-runner](../sprint-task-runner/SKILL.md) (same ticket format).

Create Debt issues via [jira-create-issue](../jira-create-issue/SKILL.md) (estimate
subagent → create with story points). Do **not** call `jira_create_issue` raw.

## Quick Start

```
- [ ] Read MCP tool schemas before calling
- [ ] Scan all ai-tasks/*/60-tech-debt.md for unticketed items
- [ ] Dedupe and skip accepted/out-of-scope/resolved items
- [ ] Create issues via jira-create-issue (verify persistence)
- [ ] Update each ai-tasks/<TASK>/60-tech-debt.md in place with Jira links
- [ ] Report summary (count, key range, story points, files updated, skipped)
```

---

## Phase 1: Discover Unticketed Items

### Sources

Scan **only** `ai-tasks/*/60-tech-debt.md` unless the user widens scope.

### What counts as unticketed

| Pattern | Example |
| --- | --- |
| Table row with `TD-N` / `D-N` / priority column, no browse link | `\| TD-1 \| Low \| Wire OTel adapter \| ... \|` |
| Explicit marker | `Jira: _none_`, `no Jira issue yet`, `No ticket filed` |
| Bullet with `no Jira yet` | `(non-blocker; no Jira yet)` |

### Already ticketed (skip)

- Line contains `[PYPOST-N](https://...atlassian.net/browse/PYPOST-N)`
- Notes column references an existing parent ticket only (e.g. `PYPOST-555` epic child)

### Do not ticket (skip)

| Signal | Reason |
| --- | --- |
| `accepted by design`, `low risk`, `covered implicitly` | Documented waiver |
| `out of scope`, `not required`, `not a blocker` | Explicit non-follow-up |
| `Resolved`, `Fixed`, `Done in`, `**Improved**` | Closed debt |
| `tracked under PYPOST-N`, `deferred to PYPOST-N` | Already tracked elsewhere |
| `Future — PYPOST-N` | Cross-reference to existing debt doc |

When unsure, prefer **skip** over duplicate tickets.

### Priority

Extract from the artifact row (`High` / `Medium` / `Low`). Default: `Low`.

---

## Phase 2: Create Jira Issues

Follow [jira-create-issue](../jira-create-issue/SKILL.md) for each unticketed item
(estimation subagent → create with story points). Do **not** call `jira_create_issue`
directly or use `jira_batch_create_issues`.

### Required inputs to jira-create-issue

| Field | Value |
| --- | --- |
| `project_key` | `<JIRA-PROJECT-KEY>` |
| `issue_type` | `<JIRA-DEBT-ISSUE-TYPE>` (usually `Debt`) |
| `summary` | `[<parent-key>] <short description>` (max ~240 chars) |
| `description` | Source file, line, parent key, original notes |
| `priority` | From Phase 1 (`High` / `Medium` / `Low`) |
| `labels` | `["tech-debt"]` |
| `related_artifacts` | Path to the source `60-tech-debt.md` |

### Example draft

```json
{
  "project_key": "PYPOST",
  "summary": "[PYPOST-579] Wire OTel adapter in production composition root",
  "issue_type": "Debt",
  "description": "Source: `ai-tasks/PYPOST-579/60-tech-debt.md` line 12\n\nParent: PYPOST-579",
  "priority": "Low",
  "labels": ["tech-debt"],
  "related_artifacts": ["ai-tasks/PYPOST-579/60-tech-debt.md"]
}
```

Story points are set by the create skill — do not hardcode them here.

### Batching

For large backlogs (>20 items), follow jira-create-issue multi-issue rules:
parallel estimation batches of **8–10**, estimate → create per item, verify the first
new key with `jira_get_issue` before updating markdown.

### Deduping

Before create, normalize summary text and dedupe across files. Same debt narrative
in multiple parent tasks → one ticket; link all source lines to that key.

---

## Phase 3: Update `60-tech-debt.md` (required)

**Always edit the per-task artifact** `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`.
Do not use `ai-tasks/00-tech-debt-consolidated.md` as input or as the place to
record new links — it is a derived rollup only.

For each created issue, update the matching line in that task's `60-tech-debt.md`:

```markdown
Jira: [PYPOST-123](<JIRA-BASE-URL>/browse/PYPOST-123)
```

### By line type

| Line type | Update |
| --- | --- |
| Table row | Append `\| Jira: [KEY](url) \|` to last column |
| `Jira: _none_` | Replace marker with link |
| Bullet `no Jira yet` | Replace parenthetical / append link on next line |

Do **not** strip existing valid `PYPOST-*` browse links. Never regex-remove
`PYPOST-6xx` keys broadly — that deletes legitimate links.

Optionally save a run log to `scripts/untracked_debt_tickets_created.json` (audit
only — links must still live in `60-tech-debt.md`):

```json
[
  {
    "key": "PYPOST-583",
    "file": "ai-tasks/PYPOST-579/60-tech-debt.md",
    "line": 12,
    "parent": "PYPOST-579",
    "summary": "...",
    "story_points": 2
  }
]
```

### Optional: regenerate consolidated rollup

Only if the user asks, or as a post-pass after all `60-tech-debt.md` files are
updated:

```bash
python scripts/consolidate_tech_debt.py
```

This rebuilds `ai-tasks/00-tech-debt-consolidated.md` from artifacts — never edit
the consolidated file by hand to add tickets.

---

## Report Template

```markdown
## Tech debt Jira sync

| Metric | Value |
| --- | ---: |
| Files scanned | N |
| Tickets created | N |
| Key range | PYPOST-X – PYPOST-Y |
| Story points (sum) | N |
| `60-tech-debt.md` files updated | N |
| Skipped (accepted/out of scope) | N |

### Intentionally not ticketed
- PYPOST-448: accepted by design (3 items)
- ...

### Mapping
`scripts/untracked_debt_tickets_created.json`
```

---

## Anti-Patterns

- **Do not** read or update `00-tech-debt-consolidated.md` instead of per-task `60-tech-debt.md`
- **Do not** call `jira_create_issue` raw — use [jira-create-issue](../jira-create-issue/SKILL.md)
- **Do not** use `jira_batch_create_issues` without verifying keys exist afterward
- **Do not** update markdown before `jira_get_issue` confirms at least one new key
- **Do not** ticket items marked accepted / out of scope / resolved
- **Do not** create duplicate tickets when a browse link or `tracked under PYPOST-N` exists
- **Do not** run broad cleanup regexes on `60-tech-debt.md` files

## Related

- Create with estimate: [jira-create-issue](../jira-create-issue/SKILL.md)
- Single-task close: [sprint-task-runner](../sprint-task-runner/SKILL.md) Phase D
- Derived rollup (optional): `python scripts/consolidate_tech_debt.py` → `ai-tasks/00-tech-debt-consolidated.md`
