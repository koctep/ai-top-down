# Failing Tests Triage

A full test run with failures is a **triage trigger, not a stopping point**. This file owns how
a failing suite is classified, what gets filed, and why the run continues.

Referenced by [sprint-runner](../sprint-runner/SKILL.md),
[sprint-task-runner](../sprint-task-runner/SKILL.md),
[td-30-development](../td-30-development/SKILL.md), [td-review](../td-review/SKILL.md) and
[run-test](../run-test/SKILL.md).

## Why this exists

A suite that was already red before the task starts will stay red no matter how correct the
current change is. Treating that as a hard blocker hands the run back to the user for a defect
nobody is working on, and the sprint stalls on unrelated code. The failures still matter — so
they become **their own tracked issue**, not a reason to stop.

## Trigger

Any [run-test](../run-test/SKILL.md) invocation that reports failures during an autonomous run:
Step 3 verification, Step 4 iterations, Phase C blocker review, or the pre-commit check in
Phase F.

## Classify before reacting

Classification is by **evidence**, never by reading test names or paths.

Baseline run — the task's base commit in a throwaway worktree, so the run's own working tree is
never touched (the integrity check in [td-review](../td-review/SKILL.md) compares it):

```bash
git worktree add /tmp/baseline-<JIRA-TASK-ID> <base-commit>
cd /tmp/baseline-<JIRA-TASK-ID> && make test   # or just the failing node ids
git worktree remove /tmp/baseline-<JIRA-TASK-ID>
```

`<base-commit>` is the commit the task's work started from (branch point, or `HEAD` before the
first Step 3/4 edit).

| Class | Evidence | Action |
| --- | --- | --- |
| **Caused by this task** | fails now, passes at base | Real defect of the current step — fix it here, in this task |
| **Pre-existing** | fails at base with the same error | File a Jira issue, record NON-BLOCKER, **continue** |
| **Flaky** | passes on re-run against the unchanged tree | Re-run once to confirm; if confirmed, file as pre-existing and note the observed pass/fail rate |

If the baseline run cannot be performed (no worktree support, environment refuses), treat the
failure as **caused by this task** — the conservative class. Never assume "probably unrelated".

## Filing the issue (pre-existing / flaky)

1. **Dedupe** — search Jira for an open issue naming the same test id
   (JQL `text ~ "<node id>"`). If one exists, link it and skip creation.
2. **Create** one issue per failure cluster (same root cause or same module) via
   [jira-create-issue](../jira-create-issue/SKILL.md):
   `project_key: <JIRA-PROJECT-KEY>`, `issue_type: <JIRA-DEBT-ISSUE-TYPE>`,
   `labels: ["tech-debt", "failing-test"]`, priority from impact.
3. The description **must** contain all of:
   - exact test identifiers — full node ids, one per line (`tests/x/test_y.py::TestZ::test_w`)
   - the repro command exactly as run (`make test`, or the narrowed command)
   - the base commit where it already fails — the evidence it predates the task
   - the failure excerpt per test: the assertion or exception plus the last ~15 lines of output
   - the suspected cause in one line, or `root cause not investigated`
   - the task key during whose run it was found

   A summary like "tests are red" without node ids and a repro command is not an acceptable
   issue — it moves the investigation cost to the next person instead of removing it.
4. **Record** it in `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md` under Follow-up Tasks: test ids,
   verdict `NON-BLOCKER — pre-existing`, Jira key.
5. **Continue** — update `next_action` in the state registry
   ([_shared/autonomous-run.md](autonomous-run.md)) and launch the next action in the same turn.

## Gates are baseline-relative

"All tests pass" in any step's Completion Criteria means:

- the Step 3 red test is green, **and**
- no failure outside the documented, filed pre-existing set.

Reviewers apply the same rule. A FAIL verdict whose only gap is a filed pre-existing failure is
invalid — re-run the review with the issue key supplied as context.

## Never terminal

Pre-existing failures never satisfy the hard-blocker terminal condition in
[_shared/autonomous-run.md](autonomous-run.md). A hard blocker is *the current change cannot be
made correct*. If the issue cannot be created because Jira auth is missing, that is terminal
condition 3 (credentials), not a test failure.

## Anti-Patterns

- **Do not** end the turn, or ask permission, to investigate failures unrelated to this task.
- **Do not** fix unrelated failures inside this task's diff — they get their own issue and their
  own task run.
- **Do not** skip, xfail, delete, or mark a failing test to make the suite green.
- **Do not** classify by test name, path, or intuition — produce baseline evidence.
- **Do not** file an issue for a failure your own change caused; fix it.
- **Do not** file one omnibus issue without node ids, repro command, and failure output.
- **Do not** close the task or the sprint while a caused-by-this-task failure is open.
