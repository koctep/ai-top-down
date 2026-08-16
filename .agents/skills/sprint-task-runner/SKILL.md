---
name: sprint-task-runner
description: Autonomously run one Jira sprint task end-to-end (Steps 1-8) with per-step subagents and reviews, tech-debt blockers, follow-up Jira issues, commit, and close — no per-step user approval. Use when the user asks to run a single sprint task or execute one issue through the top-down workflow. For full sprint cycles (all tasks + close sprint), use sprint-runner instead.
---

# Sprint Task Runner

Orchestrates one sprint task from Jira activation through commit and closure.
Uses **Atlassian MCP** (`<JIRA-MCP-SERVER>`) and the **top-down workflow**
([top-down-workflow](../top-down-workflow/SKILL.md)).

Board id: `<JIRA-BOARD-ID>`.

Configure placeholders — see [jira-sprint-planning](../jira-sprint-planning/SKILL.md).

## Autonomous Mode (mandatory)

When this skill is active, run **all phases A–F without stopping for user approval**.

- **Do not** ask "Shall I proceed to Step N?" or similar after each step.
- **Do not** wait for confirmation between phases B, C, D, E, or F.
- **Override** top-down-workflow and `td-*` skills that say "request review from user"
  or "wait for approval" — treat sprint-task-runner as pre-approved for the full run.
- Subagents must **not** pause for user gates; fix review failures via fix subagents instead.
- Only stop and ask the user when:
  - a **hard blocker** cannot be resolved after fix loops (report what failed and why), or
  - **missing credentials / MCP auth** prevents Jira or git operations, or
  - the user **explicitly** asked to pause or approve a specific step.

At the **end** (after Phase F), provide one consolidated summary — not step-by-step prompts.

## Quick Start Checklist

```
Sprint task run:
- [ ] Phase A: Activate sprint and pick task
- [ ] Phase B: Steps 1–7 (execution + review subagent per step; worklog per subagent)
- [ ] Phase C: Tech-debt blocker review (+ fix loop if needed; worklog per subagent)
- [ ] Phase D: Create Jira follow-ups and update 60-tech-debt.md
- [ ] Phase E: Step 8 (execution + review subagent; worklog per subagent)
- [ ] Phase F: Orchestrator worklog, commit (td-99-commit), and close Jira task
```

Run phases sequentially. Do **not** batch Steps 1–7 into one subagent unless the user
explicitly requests a batch.

---

## Phase A: Sprint and Task Selection

**Orchestrated by sprint-runner?** If the parent run already selected/activated the sprint
and passed a specific issue key, **skip steps 1–4** and use that key for steps 5–6.

1. Read MCP tool schemas before calling.
2. Find the sprint: `jira_get_sprints_from_board` (board `<JIRA-BOARD-ID>`) or JQL `Sprint = <id>`.
3. Activate if needed: `jira_update_sprint` with `state: active`.
4. List open sprint issues: JQL `Sprint = <id> AND status != Done ORDER BY priority DESC`.
5. **Pick one task** — prefer highest-priority open issue that fits the sprint goal.
   Tell the user which task was chosen and why.
6. Transition to In Progress: `jira_get_transitions` → `jira_transition_issue`
   (id `<IN-PROGRESS-TRANSITION-ID>`).
   Do not pass `comment` unless using Atlassian Document Format.

---

## Phase B: Steps 1–7 (Top-Down Workflow)

Follow **Worklog Orchestration** in
[top-down-workflow/SKILL.md](../top-down-workflow/SKILL.md) and
[_shared/token-worklog.md](../_shared/token-worklog.md): after each subagent, the
orchestrator calls `jira_add_worklog` with that subagent's `tokens_used`.

For **each step** (1 through 7), run **two subagents** in order:

### B1. Execution subagent

Launch an execution subagent — general-purpose, with file read, write, and shell access.
Prompt must include:

- Jira task key, summary, description
- Step skill: `<SKILLS-DIR>/td-<step-file-name>/SKILL.md` (see mapping below)
- Language skill: `<SKILLS-DIR>/lsr-python/SKILL.md` (or relevant language)
- Roadmap template: [td-10-requirements/assets/roadmap.md](../td-10-requirements/assets/roadmap.md)
- Instruction: execute **only this step**; mark roadmap `[/]` then `[x]` after
  review passes (for Step 3, leave `[/]` until B2 review completes)

| Step | Step skill | Main artifacts |
|------|-----------|----------------|
| 1 | `td-10-requirements/SKILL.md` | `00-roadmap.md`, `10-requirements.md` |
| 2 | `td-20-architecture/SKILL.md` | `20-architecture.md` |
| 3 | `td-25-failing-repro/SKILL.md` | red test(s) under `tests/` (or N/A note) |
| 4 | `td-30-development/SKILL.md` | code, green tests, roadmap updates |
| 5 | `td-40-code-cleanup/SKILL.md` | `40-code-cleanup.md` |
| 6 | `td-50-observability/SKILL.md` | `50-observability.md` |
| 7 | `td-60-review/SKILL.md` | `60-tech-debt.md` |

**Step 3 (Failing Repro):** Write the red test only — **no production fix**. Test must
fail on current code for the intended reason. Do **not** merge B1 and B2 into one
`Task` call.

**Step 4 (Development):** Iterate until requirements are met; each iteration ≤ 100 LOC
when possible. First priority: make the Step 3 red test green.

### B2. Review subagent

Launch a review subagent — read-only (file read and search, no edits), `readonly: true`.
Prompt must include:

- Same step-skill path
- Paths to artifacts produced in B1
- Instruction: verify full compliance with the step skill; classify gaps as fixable or
  blocking; **do not implement fixes** (readonly)

**Step 3 review:** Confirm failure mode is the intended defect / missing behavior (not
a broken fixture). If the test harness needs fixes, launch a **fix** subagent that
may edit tests only — never the product fix. Re-run review until PASS.

If review finds fixable gaps (other steps), launch a **fix subagent** (general-purpose,
write access, not readonly), log its worklog, then re-run the review subagent for that
step. Repeat until review passes.

**Immediately proceed to the next step** — no user confirmation.

---

## Phase C: Tech-Debt Blocker Review

Log worklog after each blocker-review and fix subagent (same orchestration rules as Phase B).

After Step 7 completes, launch an **independent** review subagent (`readonly: true`):

- Read `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md` and the implementation
- Classify each item: **BLOCKER** (must fix before close) or **NON-BLOCKER**
- A blocker = broken/incomplete/unsafe relative to acceptance criteria, not deferred work

**If BLOCKERs found:**

1. Launch fix subagent with concrete fix list
2. Re-run blocker review subagent
3. Repeat until verdict is **SAFE TO CLOSE**

---

## Phase D: Jira Follow-Ups

When **SAFE TO CLOSE**:

1. For each follow-up in `60-tech-debt.md` **without** a Jira link, create an issue via
   [jira-create-issue](../jira-create-issue/SKILL.md)
   (`project_key: <JIRA-PROJECT-KEY>`, `issue_type: <JIRA-DEBT-ISSUE-TYPE>`,
   `labels: ["tech-debt"]`, priority from the debt row, related artifact
   `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`). Do **not** call `jira_create_issue` raw.
2. Update `60-tech-debt.md` with
   `Jira: [<KEY>](<JIRA-BASE-URL>/browse/<KEY>)` using the returned key.
3. Skip creating duplicates when a linked issue already exists.

---

## Phase E: Step 8 (Dev Docs)

Run the same **execution + review** pair as Phase B (with worklog after each subagent):

- Execution: [td-70-dev-docs](../td-70-dev-docs/SKILL.md) → `doc/dev/` updates
- Review: verify against `td-70-dev-docs`

---

## Phase F: Commit and Close

1. **Orchestrator worklog** — log orchestrator-only `tokens_used` via `jira_add_worklog`
   (see [_shared/token-worklog.md](../_shared/token-worklog.md)). Do this **before** commit.
2. Follow [td-99-commit](../td-99-commit/SKILL.md):
   - `git status` and `git diff`
   - Stage relevant files, commit with Conventional Commits + JIRA ID **on the current branch**
   - Optionally record a suggested branch name in `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md`
     (reference only — for PR naming or future use)
3. Transition Jira task to Done: `jira_transition_issue` (transition id `<DONE-TRANSITION-ID>`)
4. Report: commit hash, branch name, Jira URL, `worklog_count`, `total_tokens`, remaining
   sprint tasks

**Do not** run `git checkout -b`, `git switch`, or otherwise create/switch branches. The project
commits directly on the working branch (e.g. `main`).

---

## Subagent Prompt Template

```markdown
Task: <JIRA-TASK-ID> — Step N (<step name>)
Repo: <REPO-PATH>

Step skill: <SKILLS-DIR>/td-<NN>-<name>/SKILL.md (read before acting)
Language skill: <SKILLS-DIR>/lsr-python/SKILL.md

Jira summary: ...
Jira description: ...

Execute ONLY Step N. Update ai-tasks/<JIRA-TASK-ID>/00-roadmap.md ([/] → [x]).
Do NOT ask the user for approval — sprint-task-runner is fully autonomous.
Return: summary, files changed, test results, issues found.

## Worklog
tokens_used: <number>
role: execution|review|fix|blocker_review
step: <N>
step_name: <name>
```

Review subagent adds: `Readonly. Do not edit files. Return PASS/FAIL with gap list.` and the
same `## Worklog` block (`role: review` or `blocker_review`).

For Step 3 use `step_name: Failing Repro`. Step 3 review may allow a fix subagent for
**test harness only** if readonly review cannot edit.

---

## Anti-Patterns

- **Do not** ask for user approval between steps or phases (autonomous mode)
- **Do not** merge Steps 1–7 into one subagent (unless user explicitly asks)
- **Do not** merge Step 3 write-test and review-test into one `Task` call
- **Do not** implement the production fix inside the Step 3 execution subagent
- **Do not** skip per-step review subagents
- **Do not** close the Jira task while blocker review says BLOCKED
- **Do not** create Jira follow-ups before blocker review passes
- **Do not** create follow-ups with raw `jira_create_issue` — use jira-create-issue
- **Do not** use `jira_transition_issue` `comment` with plain Markdown (ADF required)
- **Do not** create or switch git branches — commit on the current branch only
- **Do not** close the Jira task without orchestrator worklog when orchestrator `tokens_used > 0`
- **Do not** skip `jira_add_worklog` when a subagent returned `tokens_used > 0`
- **Do not** batch all tokens into one worklog at task close — log per subagent as you go

---

## Related Skills

- Full sprint orchestration (all tasks + close): [sprint-runner](../sprint-runner/SKILL.md)
- Create follow-ups with estimate: [jira-create-issue](../jira-create-issue/SKILL.md)
- Step details and critical rules: [top-down-workflow](../top-down-workflow/SKILL.md)
- Sprint planning and backlog analysis: [jira-sprint-planning](../jira-sprint-planning/SKILL.md)
