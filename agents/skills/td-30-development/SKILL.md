---
name: td-30-development
description: Step 4 of the Top-Down workflow: implement the approved design and make the reviewed failing repro pass.
---

# STEP 4: Development

## General Principle

This step combines design, creating stubs, implementation, and integration. It is performed cyclically until the task is fully completed.

⚠️ **Prerequisite**: Step 3 (Failing Repro) must be complete — a reviewed red
automated test exists (or documented N/A for no behavioral change). The first
Development work for behavioral tasks is to implement the fix until that test
goes green. Do not reverse red → green order.

## Goal

Implement the task iteratively, in small steps, with constant quality control and feedback from the user.

## Preparation

1. Update the roadmap per [td-roadmap](../td-roadmap/SKILL.md): STEP 4 → `[/]`.

## Development Process

⚠️ **In this step, it is necessary to recursively perform the following actions until the task is fully completed**:

1. 📋 **Define minimal meaningful change**
   - The size of the change should not exceed **100 edited lines of code**.
   - The change must be logically complete (even if part of the functionality is implemented via stubs).
   - Prefer making the Step 3 red test pass as the first (or early) meaningful change.

2. **Implement the change**
   - Write code implementing the selected change.
   - Use **stubs** for large or not yet implemented parts of the system so that the code is compilable and, if possible, executable.
   - Follow the architecture defined in Step 2.

3. **Update Roadmap**
   - Add a brief summary (what was done) as a sub-item of STEP 4 — see
     [td-roadmap](../td-roadmap/SKILL.md).
   - Format: `- [x] Implemented functionality X...`
   - STEP 4 itself stays `[/]` until the whole step passes its gate.

4. 📋 **Request review**
   - **MANDATORY**: After each iteration (each minimal meaningful change), request a review from the user.
   - Do not proceed to the next change without user approval.

## Code Quality and Testing

During development, **MANDATORY** ensure code quality:

1. **Static Code Analysis**
   - Use linters and static analyzers for the selected programming language
   - Fix all warnings before requesting a review

2. **Testing**
   - Keep the Step 3 repro green; add further tests for new functionality as needed
   - For Python/pytest projects: every new or changed test must have an explicit
     `@pytest.mark.timeout(...)` or module/class `pytestmark` (see
     [do-testing](../do-testing/SKILL.md))
   - Run existing tests before each change with [run-test](../run-test/SKILL.md)
   - Ensure all tests pass — measured **against the baseline**: the Step 3 test is green and
     no failure exists beyond the documented pre-existing set. Failures that already reproduce
     at the task's base commit are triaged and filed as their own issue, not fixed here and not
     a reason to stop
     ([_shared/failing-tests-triage.md](../_shared/failing-tests-triage.md))

3. **Code review**
   - Check code readability and clarity
   - Follow project coding standards
   - Document complex logic

4. **Refactoring**
   - Maintain code cleanliness and readability
   - Avoid code duplication
   - Optimize performance if necessary

## Artifacts

- Project code.
- Per-iteration sub-items under STEP 4 in `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md`.

## Completion Criteria

- All functionality described in requirements and architecture is implemented.
- Step 3 red test(s) pass (unless Step 3 was N/A).
- All stubs replaced with real code.
- Tests pass (if applicable) — no failure beyond the pre-existing set documented and filed per
  [_shared/failing-tests-triage.md](../_shared/failing-tests-triage.md).
- ✅ **Received final approval from the user**.
- After the acceptance gate passes, its owner marks STEP 4 as `[x]`
  ([td-roadmap](../td-roadmap/SKILL.md)) and the workflow proceeds to STEP 5.
