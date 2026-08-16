---
name: td-10-requirements
description: Step 1 of the Top-Down workflow: gather and document business requirements without implementation details.
---

# STEP 1: Requirements Gathering and Documentation

## General Principle

⚠️ **Always use the "top-down" programming approach and perform steps strictly sequentially**. Do not proceed to the next step until the current one is completed and its artifacts are created.

⛔ **STRICTLY PROHIBITED**: Do not include any architectural or technical solutions, database schemas, API designs, or specific implementation details in the requirements document. This phase is solely for understanding *what* needs to be done, not *how*.

🔍 **MANDATORY**: If the initial request is technical (e.g., "add a column to table X", "create an API endpoint"), you MUST ask "Why?" to uncover the underlying business requirement. Understanding the business goal is a mandatory condition for completing this step.

## Goal

Create a single document with a full description of business tasks and functional requirements.
- **Focus**: Business value, user needs, and functional scope.
- **Exclude**: Technical implementation details, architecture diagrams, and tech stack decisions (except for the high-level language choice if mandated).

## Actions

1. Create file `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` from the roadmap template and replace
   `<JIRA-TASK-ID>` with the actual task ID — see [td-roadmap](../td-roadmap/SKILL.md).
2. Update the roadmap per [td-roadmap](../td-roadmap/SKILL.md): STEP 1 → `[/]`.
3. 🔍 **Determine programming language** for task implementation and record it in the
   `Task Metadata` section of `00-roadmap.md`
4. Gather all requirements from the user. **If the user provides a technical solution**, you must ask clarifying questions to understand the underlying business reason before proceeding.
5. Document them in a structured way.
6. Define system boundaries (scope).
7. Identify main entities and their interactions (business entities, not database tables).
8. 📋 **Request review from user** to verify all step artifacts.
9. The acceptance gate owner marks STEP 1 as `[x]` once the gate passes — see
   [td-roadmap](../td-roadmap/SKILL.md).

## Artifacts

- **File**: `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` (created from the
  [roadmap template](../td-roadmap/assets/roadmap.md)).
- **File**: `ai-tasks/<JIRA-TASK-ID>/10-requirements.md`.
- **Content of requirements.md**:
  - Description of the problem/task.
  - **Programming language** for implementation.
  - Functional requirements (what the system should do).
  - Non-functional requirements (performance, security, etc.).
  - Constraints and assumptions.
  - Main entities and their attributes (business perspective).
  - User scenarios (use cases) or user stories.

## Requirements File Template

When the task is clear, create a file using the following template (removing comments):

```markdown
# <JIRA-TASK-ID>: <Short description of the task>

## Goals

This section describes why this task is needed from a business perspective.

## User Stories

Section with a list of user stories. Use roles defined in the project (if applicable).

## Definition of Done

This section describes when the task is considered `done`, with a list of acceptance criteria (business logic verification).

## Task Description

This section describes the problem, goals, and constraints.

## Q&A

List of questions and answers. Add links if used.
```

## Completion Criteria

- Programming language determined and documented.
- All business requirements documented.
- **Business goal/reason is explicitly stated and understood (MANDATORY).**
- No ambiguities in wording.
- No technical/architectural solutions present.
- Main system components defined at a high level (business domain).
- ✅ **Received review and approval from user** before proceeding to the next step.
