---
name: jira-audit-tickets
description: Create a Code Audit epic and focused audit stories in any Jira project via Atlassian MCP. Use when the user asks to create audit tickets, set up a code audit epic, plan audit focus areas in Jira, or bootstrap a systematic codebase review backlog.
---

# Jira Audit Tickets

Create a **Code Audit** epic and child issues for each audit focus in any Jira project.

## Placeholders

| Placeholder | Meaning | Example |
| --- | --- | --- |
| `<JIRA-MCP-SERVER>` | Atlassian MCP server id | `user-mcp-atlassian` |
| `<JIRA-PROJECT-KEY>` | Jira project key | `PROJ` |
| `<JIRA-BASE-URL>` | Jira instance base URL | `https://your-org.atlassian.net` |
| `<JIRA-EPIC-ISSUE-TYPE>` | Issue type for the epic | `Epic` |
| `<JIRA-AUDIT-ISSUE-TYPE>` | Issue type for audit tasks | `Story`, `Task` |
| `<REPO-PATH>` | Local repo path (for deliverable paths) | `/path/to/repo` |

## Quick Start

When the user asks to create audit tickets:

1. Read MCP tool schemas before calling (`jira_search`, `jira_create_issue`, `jira_link_to_epic`).
2. Discover issue types used in the project (search recent epics and their children).
3. Check whether a Code Audit epic already exists.
4. Create the epic (if missing), then create audit focus stories linked via `parent`.
5. Verify with JQL and return issue keys + URLs.

## MCP Server

Use `<JIRA-MCP-SERVER>`.

## Step 1 — Discover project conventions

```jql
project = <JIRA-PROJECT-KEY> AND type = Epic ORDER BY created DESC
```

From the top 3–5 epics, note:

- Epic issue type name → `<JIRA-EPIC-ISSUE-TYPE>`
- Child issue type (Story vs Task) → `<JIRA-AUDIT-ISSUE-TYPE>`
- Whether children use `parent` (next-gen) or epic link field

Also run:

```jql
project = <JIRA-PROJECT-KEY> AND labels = audit ORDER BY created DESC
```

If an open **Code Audit** epic exists, reuse it — do not create a duplicate.

## Step 2 — Create the epic

**Summary:** `Code Audit`

**Description:**

```markdown
Systematic review of the codebase to assess quality, security, architecture,
and maintainability. Each audit focus produces findings and follow-up issues
for remediation.
```

**Labels:** `audit`

```text
jira_create_issue(
  project_key: <JIRA-PROJECT-KEY>,
  issue_type: <JIRA-EPIC-ISSUE-TYPE>,
  summary: "Code Audit",
  description: <above>,
  additional_fields: {"labels": ["audit"]}
)
```

Record the epic key as `<JIRA-AUDIT-EPIC-KEY>`.

## Step 3 — Create audit focus stories

Create one `<JIRA-AUDIT-ISSUE-TYPE>` per focus area. Link each to the epic:

```json
{"parent": "<JIRA-AUDIT-EPIC-KEY>", "labels": ["audit"]}
```

Add extra labels where noted (`security`, `testing`).

### Standard focus areas

Use all eight unless the user requests a subset or project-specific additions.

| # | Summary | Extra labels |
| --- | --- | --- |
| 1 | Audit: architecture and package boundaries | — |
| 2 | Audit: security and secrets handling | `security` |
| 3 | Audit: test coverage and test quality | `testing` |
| 4 | Audit: code quality and maintainability | — |
| 5 | Audit: observability and logging | — |
| 6 | Audit: performance and scalability | — |
| 7 | Audit: documentation and ADR alignment | — |
| 8 | Audit: dependencies and supply chain | — |

### Description template

Adapt scope bullets to the project's stack (language, packages, infra). Keep this structure:

```markdown
[One-line goal for this focus area.]

**Scope**
- [Bullet 1 — what to inspect]
- [Bullet 2]
- [Bullet 3]

**Deliverables**
- Findings in `ai-tasks/<ISSUE-KEY>/` (or project-equivalent docs path)
- Follow-up Jira issues for remediation
```

Replace deliverable path with `<REPO-PATH>` conventions when known (e.g. `ai-tasks/`, `doc/dev/`, `docs/audits/`).

### Scope hints by focus

| Focus | Typical scope bullets |
| --- | --- |
| Architecture | Layer boundaries, dependency direction, service boundaries, ADR alignment |
| Security | Secrets storage, auth tokens, PII in logs/DB, transport encryption, ACL model |
| Tests | Unit/integration coverage, critical paths, flakiness, CI test gates |
| Code quality | Static analysis, complexity, duplication, error handling, dead code |
| Observability | Log levels, PII in logs, failure diagnostics, debug vs release |
| Performance | Query/index cost, sync throughput, API batching, UI latency targets |
| Documentation | Dev docs vs code, ADRs, onboarding gaps, artifact drift |
| Dependencies | Outdated packages, licenses, native deps, security advisories |

### Project-specific focuses

Add or swap focuses when the user or codebase implies them:

- Accessibility / i18n
- Multi-platform parity (mobile vs web)
- Data privacy / compliance (GDPR, retention)
- API contract / backward compatibility

Ask the user only when the stack is unclear and the choice materially changes scope.

## Step 4 — Linking children to epic

**Preferred (next-gen hierarchy):** set `parent` in `additional_fields` when creating each story.

**Fallback (classic epic link):** create stories, then call `jira_link_to_epic` for each:

```text
jira_link_to_epic(issue_key: <STORY-KEY>, epic_key: <JIRA-AUDIT-EPIC-KEY>)
```

If `parent` fails, retry with `jira_link_to_epic`.

## Step 5 — Verify

```jql
project = <JIRA-PROJECT-KEY> AND parent = <JIRA-AUDIT-EPIC-KEY> ORDER BY key ASC
```

Confirm:

- Expected number of focus stories created
- All have label `audit`
- None duplicated from a prior run

## Reporting

Return a table:

| Key | Summary |
| --- | --- |
| `<JIRA-AUDIT-EPIC-KEY>` | Code Audit (Epic) |
| … | Audit: … |

Include browse URLs: `<JIRA-BASE-URL>/browse/<KEY>`.

## Optional — Sprint assignment

If the user also wants a sprint, hand off to [jira-sprint-planning](../jira-sprint-planning/SKILL.md):

- Sprint name: `Code Audit` (≤ 30 chars)
- Issues: all audit story keys (not the epic)
- Typical size: 8 stories ≈ one 2-week sprint

## Checklist

```
Audit ticket creation:
- [ ] Read MCP tool schemas
- [ ] Discover epic/story issue types in project
- [ ] Check for existing Code Audit epic (label audit)
- [ ] Create epic if missing
- [ ] Create 8 focus stories with descriptions
- [ ] Link stories to epic (parent or epic link)
- [ ] Verify via JQL
- [ ] Report keys and URLs
```
