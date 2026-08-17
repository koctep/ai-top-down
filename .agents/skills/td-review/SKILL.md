---
name: td-review
description: How to run a review subagent in the Top-Down pipeline — when to launch one, the read-only prompt template, the working-tree integrity check, verdict format, and the fix loop. Use whenever a step's artifacts must be reviewed by a separate agent. This is the review *procedure*; Step 7 tech-debt analysis is td-60-tech-debt.
---

# Review Subagent Procedure

Every Top-Down step is verified by an **independent agent** that did not produce the work.
This skill owns how that review is launched, constrained, verified, and closed out.

> **Not to be confused with** [td-60-tech-debt](../td-60-tech-debt/SKILL.md) — that is Step 7
> of the workflow (technical-debt analysis and its artifact). This skill is the reusable
> *procedure* for running any review subagent, including the one that reviews Step 7.

## Core Rule

**The agent that produced the work never reviews it.** Execution and review are always separate
launches, never merged into one call — a single agent asked to "write it and then check it"
reviews its own reasoning and reliably passes itself.

The reviewer also never fixes what it finds: it reports, and a **separate fix agent** applies the
changes. The one narrow exception is the Step 3 test harness, described below.

## When to Launch a Review Subagent

| Situation | Reviews | Verdict feeds |
| --------- | ------- | ------------- |
| After each step's execution subagent | Step artifacts vs the step skill | The step's `[x]` gate |
| After Step 3 execution | The red test and its failure mode | Step 3 `[x]` gate |
| After Step 7 | `60-tech-debt.md` vs the implementation | Blocker verdict before close |
| After a fix subagent | That the reported gaps are actually closed | Re-run of the same gate |

In autonomous runs the review verdict **is** the acceptance gate — see
[td-roadmap](../td-roadmap/SKILL.md). In interactive runs it precedes the user's approval.

## Naming the Subagent

Describe the subagent by the **capability** it needs, never by a harness-specific agent-type
name — those names differ between AI tools and change between releases. Read the agent types the
current harness offers and pick the one matching the described capability.

- **Review subagent** — file read and search; no edits.
- **Fix subagent** — file read, write, and shell access.

## Launch Protocol

1. **Record the working tree** — `git status --porcelain` and `git diff` before launching.
2. **Launch** the review subagent with the prompt template below.
3. **Verify the tree** — run both commands again and compare (see Integrity Check).
4. **Read the verdict** — PASS, or FAIL with a classified gap list.
5. **Log the worklog** — parse the `## Worklog` block, call `jira_add_worklog`
   ([_shared/token-worklog.md](../_shared/token-worklog.md)). The orchestrator logs; the
   subagent never calls Jira.
6. **Fix loop** on FAIL — launch a separate fix subagent, log its worklog, then re-run the
   review from step 1. Repeat until PASS.
7. **Close the gate** — on PASS the gate owner marks the step `[x]`
   ([td-roadmap](../td-roadmap/SKILL.md)). The reviewer never writes that mark itself.

## Prompt Template

```markdown
Task: <JIRA-TASK-ID> — review of Step N (<step name>)
Repo: <REPO-PATH>

Step skill: <SKILLS-DIR>/td-<NN>-<name>/SKILL.md (read before reviewing)
Artifacts produced by the execution agent: <paths>

Verify full compliance with the step skill and its Completion Criteria.
Read-only: do NOT edit, create, or delete any file, and do not run commands that
change the working tree. Report gaps — do not fix them.

Return:
- Verdict: PASS or FAIL
- For FAIL: numbered gap list, each classified `fixable` or `blocking`, each with the
  file/line or artifact section it refers to

## Worklog
tokens_used: <number>
role: review
step: <N>
step_name: <name>
```

Reuse the same block for a blocker review with `role: blocker_review`.

## Verdict Format

- **PASS** — every Completion Criterion of the step skill is met. Nothing else counts as PASS;
  "mostly fine" is a FAIL with a gap list.
- **FAIL** — numbered gaps, each classified:
  - `fixable` — a fix subagent can close it inside the current step.
  - `blocking` — the step's premise is wrong (missing artifact, wrong architecture, requirement
    not covered); needs the step re-run or escalation, not a patch.

Every gap names the artifact it applies to. A gap without a location is not actionable and the
reviewer must resolve it into one.

**Pre-existing test failures are not gaps.** A failure that reproduces at the task's base commit
and has a filed issue does not make the step FAIL — see
[_shared/failing-tests-triage.md](../_shared/failing-tests-triage.md). If a review returns FAIL
on such a failure alone, re-run it with the issue key as context instead of launching a fix
subagent.

## Integrity Check

Read-only is an **instruction in the prompt, not an enforced parameter**. The subagent-launch
tool has no read-only flag, and any agent with shell access can write regardless of which other
tools it holds. Verify instead of trusting:

1. Before launching, record `git status --porcelain` and `git diff`.
2. After it returns, record both again and compare.
3. If they differ, the review is **invalid** — revert the subagent's changes (`git checkout` for
   tracked files, delete untracked ones), then re-run the review, restating that it must not
   edit.

A review whose tree changed cannot be accepted by re-reading the diff and deciding it looks
harmless — the verdict came from an agent that broke its own constraint.

## Fix Subagents

- A fix subagent is a **separate launch** from the review that found the gaps.
- Its input is the reviewer's gap list, not the reviewer's context.
- After it returns, **re-run the review** — a fix is never self-certifying.
- Log a worklog for the fix subagent, same as for review.

### Step 3 exception (test harness only)

The Step 3 reviewer may fix **test-only** issues (fixtures, timeouts, asserts) so the red test
fails for the intended reason. It must never implement the production fix. Check its diff: it
must touch the test layout alone. Anything outside it is reverted and re-run — see
[td-25-failing-repro](../td-25-failing-repro/SKILL.md).

## Anti-Patterns

- **Do not** merge execution and review into one launch.
- **Do not** let the reviewer fix what it found (outside the Step 3 test-harness exception).
- **Do not** accept a review without comparing the working tree before and after.
- **Do not** accept PASS on a step whose Completion Criteria were not each checked.
- **Do not** let the reviewer mark the step `[x]` — that is the gate owner's act.
- **Do not** skip the re-review after a fix subagent.
- **Do not** name the subagent by a harness agent-type string copied from another tool.
- **Do not** batch several steps' artifacts into one review — one review per step gate.
- **Do not** FAIL a step for a filed pre-existing test failure.

## Related Skills

- Roadmap marks and the acceptance gate: [td-roadmap](../td-roadmap/SKILL.md)
- Workflow entry point and step list: [top-down-workflow](../top-down-workflow/SKILL.md)
- Autonomous runs and blocker review: [sprint-task-runner](../sprint-task-runner/SKILL.md)
- Step 7 tech-debt analysis (the artifact, not this procedure):
  [td-60-tech-debt](../td-60-tech-debt/SKILL.md)
- Worklog conversion: [_shared/token-worklog.md](../_shared/token-worklog.md)
