---
name: td-00-rules
description: Core Top-Down workflow principles and mandatory execution order. Use for any task following the Top-Down process.
---

# Top-Down Approach to Programming

## Philosophy of the Approach

**Top-Down** is a development methodology where a system is designed and implemented starting from high-level abstractions and gradually detailed down to concrete implementation.

### Key Principles

1. **Abstraction before Details**
   - First define WHAT the system should do
   - Then define HOW it will be organized
   - Finally implement specific details

2. **Sequence is Mandatory**
   - Each step builds on the results of the previous one
   - Do not skip design stages
   - Implementation starts only after design is complete

3. **Documentation at Each Stage**
   - Each step creates specific artifacts
   - Documentation is created in parallel with design
   - Documents serve as the basis for the next steps

4. **Structure before Code**
   - First create the project structure and stubs
   - Then stubs are gradually replaced by implementation
   - This allows seeing the full picture of the system before details

## Development Process

Development using the top-down approach consists of **8 sequential steps**:

1. **Requirements** — gathering and documenting requirements, what needs to be built
2. **Architecture** — high-level architectural design, how it is organized
3. **Failing Repro** — automated red test that demonstrates the defect or missing behavior
   (no production fix; execution and review in separate subagents)
4. **Development** — iterative implementation with minimal meaningful changes using stubs
5. **Code Cleanup** — preparing code for review (linting, formatting, cleanup)
6. **Observability** — adding logging and metrics
7. **Review** — technical debt analysis and task finalization
8. **Dev Docs** — creating/updating developer documentation in `doc/dev`

### Execution Sequence

Steps are performed **strictly sequentially**. Do not proceed to the next step until the current one is completed and all its artifacts are created.

**MANDATORY**: After completing each step, you must obtain a review from the user before proceeding to the next step.

## Feedback Process

### How to Request a Review

1. **Clearly Describe Changes**
   - Specify exactly what was done
   - Explain complex decisions
   - Provide usage examples (if applicable)

2. **Provide Context**
   - Reference requirements from previous steps
   - Point to related files and changes
   - Describe impact on the system

3. **Be Ready for Questions**
   - Do not rush to answer
   - Explain technical decisions
   - Offer alternative approaches if necessary

### How to Give Feedback

1. **Constructiveness**
   - Start with positive aspects
   - Suggest specific improvements
   - Explain reasons for comments

2. **Prioritization**
   - Separate blocker-issues from nice-to-have
   - Indicate what can be fixed later
   - Identify critical problems

3. **Communication Clarity**
   - Use clear language
   - Provide examples of desired changes
   - Confirm understanding of fixes

## Critical Rules

⚠️ **DO NOT START WRITING PRODUCTION CODE** until steps 1–3 (requirements,
architecture, failing repro) are completed. A red automated test on Step 3 is
allowed and required for behavioral changes; the product fix belongs to Step 4.

⚠️ **DO NOT SKIP STEPS** — each step is mandatory and creates the foundation for the next.

⚠️ **DO NOT PROCEED TO THE NEXT STEP** until all completion criteria of the current one are met and a review is received from the user.

## Rules for Working with AI Assistant

### When Working on a Task

- **MANDATORY** check for JIRA task ID — if not specified, request it from the user before starting work
- **MANDATORY**: JIRA-TASK-ID must be set by the user, do not use made-up or approximate values
- Always reference the current step
- Before proceeding to the next step — check completion criteria of the current one
- **MANDATORY** after completing each step, request a review from the user and wait for their approval before proceeding to the next step
- **MANDATORY**: When receiving review comments, they must be addressed and a review requested again. Comments cannot be taken as approval to proceed to the next step
- If the user asks to skip steps — **POLITELY REFUSE** and explain the importance of the sequence
- **MANDATORY**: If there is any question, wait for the user's answer before continuing work

### When Creating Artifacts

- Use clear filenames
- Structure information logically
- Use markdown for documents
- Add examples and diagrams where appropriate

### Roadmap Maintenance

- **MANDATORY** maintain the file `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` to track progress
- At STEP 1 create `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` from [td-10-requirements' roadmap template](../td-10-requirements/assets/roadmap.md)
- When starting work on a step, mark it as `[/]` (in progress)
- When completing a step, mark it as `[x]` (completed)
- Replace `<JIRA-TASK-ID>` with the actual task ID from JIRA

### Programming Languages

- The project can be developed in different languages
- **MANDATORY** determine the programming language at STEP 1 (requirements) before starting work on the task
- When designing and implementing, consider the features of the selected language
- Language-specific guidance is in `.agents/skills/lsr-<language-name>/SKILL.md`
- When working on steps 2–7 (architecture, development, cleanup, observability, review, dev docs) **MANDATORY** consider the specifics of the selected language from the corresponding file

### File Handling

- **MANDATORY** use [lsr-requirements](../lsr-requirements/SKILL.md)
