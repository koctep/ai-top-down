---
name: td-25-failing-repro
description: Step 3 of the Top-Down workflow: create and independently review a red automated repro without changing production code.
---

# STEP 3: Failing Repro Test

## General Principle

⚠️ **Transition to this step is possible only after full completion of Step 2**
(Architecture) and user approval of `ai-tasks/<JIRA-TASK-ID>/20-architecture.md`
(unless sprint-task-runner / batch mode overrides approval).

This step creates an automated **red** test that demonstrates the defect or missing
behavior **before** any production fix. Development (Step 4) must not start until
this step is complete.

⛔ **STRICTLY PROHIBITED**: Do not change production code to fix the bug or
implement the feature in this step. Only test harness / roadmap updates are
allowed. Do not use `xfail`, `skip`, or similar to hide a red failure.

⚠️ **Orchestrator MUST use two separate subagents** — never merge write and review:

1. **Execution subagent** — write the failing test, run it, confirm it fails for
   the intended reason.
2. **Review subagent** (new `Task` context) — verify the failure mode, fix
   test-only issues if needed, never implement the product fix.

## Goal

Prove the problem (or missing acceptance behavior) with an automated check that
fails on current code and will pass after Step 4.

## When N/A

If Architecture explicitly concludes there is **no runtime behavioral change**
(docs-only / process-only), mark STEP 3 `[x]` with a roadmap note
`N/A — no behavioral change` and do **not** write a test. Still run a brief
review subagent to confirm the N/A rationale.

## Actions

### Execution subagent

1. Mark STEP 3 in `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` as `[/]` (work started).
2. Read `20-architecture.md` failing-repro plan (what to assert, where, how to
   force without live external deps when architecture says so).
3. Read `.agents/skills/do-testing/SKILL.md` and the relevant language skill
   (`.agents/skills/lsr-<language>/SKILL.md`).
4. Write the automated test asserting **desired** behavior (so it fails today and
   passes after the fix). Prefer mirroring existing test fixtures.
5. Run [run-test](../run-test/SKILL.md), using targeted `PYTEST_ARGS` when the Makefile supports them.
6. Confirm the failure reason matches the intended defect / missing feature — not
   a broken fixture or import error. Fix the test setup until the failure is
   meaningful; still do not fix production.
7. Add a roadmap sub-bullet with the test path (leave STEP 3 as `[/]` until
   review completes).

### Review subagent (separate launch — mandatory)

1. Read this rule, `20-architecture.md`, and the new/changed test file(s).
2. Spot-check against production code that the test exercises the intended path.
3. Re-run the test if needed; confirm still red for the right reason.
4. Fix test-only issues (timeouts, fixtures, asserts). **Do not** implement the
   product fix.
5. After review passes (and user approval, unless batch override), mark STEP 3
   `[x]` in the roadmap.

## Artifacts

- Automated failing test(s) under `tests/` (or project test layout).
- Roadmap updates under STEP 3 (path to test; or N/A note).

## Completion Criteria

- Red automated verification exists (or documented N/A for no behavioral change).
- Failure mode is the intended defect / missing acceptance behavior.
- No production fix landed in this step.
- Execution and review ran in **separate** subagents.
- ✅ **Received review and approval from the user** before Step 4 (unless
  sprint-task-runner / batch override).
