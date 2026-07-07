# Project Context & Rules

This repository follows the "Top-Down" development methodology. In Codex, the default workflow is
manual: the user explicitly tells Codex which role to perform at each stage, and Codex must only
do the work for that role before handing control back.

Codex may switch to a fully autonomous single-agent execution only when the user explicitly asks
for autonomous mode. If the user does not clearly request autonomous execution, keep the default
manual handoff behavior.

## General Principles

- **Top-Down Approach**: Requirements -> Architecture -> Development -> Code Cleanup ->
  Observability -> Review -> Documentation -> Commit.
- **Strict Sequence**: Never skip steps. Each step depends on the output of the previous one.
- **Single Active Role**: In one prompt, Codex acts as exactly one role. Do not merge Analyst,
  Product Owner, Senior, Junior, and Team Lead responsibilities into one pass.
- **Explicit Handoffs**: After finishing a step, stop, summarize what was produced, and wait for
  the next role prompt.
- **Autonomous Mode Is Opt-In**: Only run multiple stages without stopping if the user explicitly
  requests autonomous mode, full autonomy, end-to-end autonomous execution, or equivalent wording.

## File Handling & Code Standards

- **Language-Specific Rules**: Always check `.cursor/lsr/` for language-specific rules
  (e.g. `do-python.md`, `do-typescript.md`).
- **Core Rules**: Always read the relevant files in `.cursor/rules/` for the current step.
- **Encoding**: UTF-8
- **Line Endings**: LF (Unix style)
- **Line Length**: Maximum 100 characters, unless stricter language rules apply.
- **Whitespace**: Remove trailing whitespace and ensure a single final newline.
- **Language**: All code, comments, and documentation must be in English.

## Role-Based Handoff Flow

When a user provides a new task, follow this exact sequence by acting in the requested role only:

1. **Analyst**
   - Read `.cursor/rules/00-rules.mdc` and `.cursor/rules/10-requirements.mdc`.
   - Gather requirements and create `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md`.
   - Create `ai-tasks/<JIRA-TASK-ID>/10-requirements.md`.
   - Mark the roadmap step as completed and stop.

2. **Product Owner**
   - Review `10-requirements.md` for business clarity and scope.
   - Reject technical implementation details in the requirements.
   - Approve the task for architecture or request requirement fixes.

3. **Senior Software Engineer**
   - Read `.cursor/rules/20-architecture.mdc`.
   - Create `ai-tasks/<JIRA-TASK-ID>/20-architecture.md`.
   - Stop after architecture is ready for Team Lead review.

4. **Team Lead**
   - Review `20-architecture.md` for compliance with project rules and maintainability.
   - Approve it for implementation or request architecture fixes.

5. **Junior Software Engineer**
   - Read `.cursor/rules/30-development.mdc`.
   - Implement code from `20-architecture.md` in small iterations.
   - After each iteration, stop so the Senior Engineer can review.
   - After implementation, perform cleanup and create
     `ai-tasks/<JIRA-TASK-ID>/40-code-cleanup.md`.

6. **Senior Software Engineer**
   - Review Junior iterations until implementation is complete.
   - Read `.cursor/rules/50-observability.mdc`.
   - Add logs, metrics, and traces as required.
   - Create `ai-tasks/<JIRA-TASK-ID>/50-observability.md`.

7. **Team Lead**
   - Read `.cursor/rules/60-review.mdc`, `.cursor/rules/70-dev-docs.mdc`, and
     `.cursor/rules/99-commit.mdc`.
   - Analyze technical debt and create `ai-tasks/<JIRA-TASK-ID>/60-review.md`.
   - Create `ai-tasks/<JIRA-TASK-ID>/70-dev-docs.md`.
   - Prepare the final commit message proposal.

## Execution Modes

### Manual Mode (default)

Use this mode unless the user explicitly says otherwise.

- Codex performs exactly one role per prompt.
- After each role finishes, Codex stops and waits for the next handoff.
- This is the safe default for all ambiguous requests.

### Autonomous Mode (explicit opt-in only)

Use this mode only when the user clearly requests autonomous execution.

- Codex may perform the full Top-Down pipeline in one run.
- Codex still follows the same role order and relevant `.cursor/rules/*` files.
- Codex should simulate the handoffs internally, but keep outputs separated by stage.
- If blocked by missing business requirements or an approval decision, Codex should ask only the
  minimum required question, then continue autonomously.
- If the user did not explicitly ask for autonomy, do not use this mode.

## Recommended Codex Prompting

Use direct prompts that name the role, task, and execution mode explicitly.

Manual mode example:

```text
Act as the Senior Software Engineer for task AUTH-123.
Read .cursor/rules/00-rules.mdc and .cursor/rules/20-architecture.mdc.
Create ai-tasks/AUTH-123/20-architecture.md based on the approved requirements.
Only perform this role's responsibilities. Summarize the result and stop.
```

Autonomous mode example:

```text
Work in autonomous mode for task AUTH-123.
Execute the full Top-Down pipeline end-to-end following CODEX.md and .cursor/rules/.
Move through each role in order, create all required artifacts, and only stop if a required
business decision is missing.
```

For manual implementation loops, use short prompts such as:

```text
Act as the Junior Software Engineer for task AUTH-123.
Continue the next implementation iteration from ai-tasks/AUTH-123/20-architecture.md.
Make a small, reviewable change and stop for Senior review.
```

This preserves the same Top-Down workflow as the Claude and Gemini variants while fitting how
Codex works in a single interactive session.
