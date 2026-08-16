---
name: td-60-tech-debt
description: "Step 7 of the Top-Down workflow: analyze the implemented solution for technical debt and record it in 60-tech-debt.md. This is the step and its artifact; for the procedure of running a review subagent see td-review."
---

# STEP 7: Technical Debt Analysis

## General Principle

⚠️ **This step is the technical debt analysis stage**. Before proceeding to documentation, it is necessary to honestly evaluate and document all trade-offs, assumptions, and technical debt that arose during the development process.

## Goal

Ensure long-term project maintainability by explicitly recording technical debt and plans for its elimination.

## Actions

1. Update the roadmap per [td-roadmap](../td-roadmap/SKILL.md): STEP 7 → `[/]`.
2. Analyze the implemented solution for:
   - Temporary solutions ("crutches")
   - Missing tests
   - Tests missing explicit timeout markers for Python/pytest projects (**BLOCKER** — see
     [do-testing](../do-testing/SKILL.md))
   - Areas requiring optimization
   - Deviations from the initial architecture
   - Hardcoded values
3. Create file `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`.
4. Update user documentation in `doc` (if applicable).
5. 📋 **Request review from the user** to verify technical debt documentation.
6. The acceptance gate owner marks STEP 7 as `[x]` once the gate passes
   ([td-roadmap](../td-roadmap/SKILL.md)); then proceed to STEP 8.

## Artifacts

- **File**: `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`.

## Template

Use the following template for `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`.

```markdown
# <JIRA-TASK-ID>: Technical Debt Analysis

## Shortcuts Taken

Describe here any "quick fixes" or compromises made for the sake of development speed.

## Code Quality Issues

List code sections that can be improved (refactoring, naming, function breakdown).

## Missing Tests

Indicate scenarios or modules that remain without test coverage.

## Performance Concerns

Describe potential performance issues, if any.

## Follow-up Tasks

List specific tasks that need to be created in the future to address the described issues.
```

## Related Skills

- Running the review subagent that checks this step's artifacts (and the tech-debt blocker
  review): [td-review](../td-review/SKILL.md)

## Completion Criteria

- Technical debt file created and filled (even if there is no debt, this must be explicitly stated).
- ✅ **Received review and approval from the user** to proceed to STEP 8.
