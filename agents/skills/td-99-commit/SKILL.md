---
name: td-99-commit
description: Top-Down commit procedure for reviewing, committing, and reporting completed work.
---

# STEP 9: Commit Changes

## General Principle

⚠️ **Final chord**. A quality commit is care for colleagues and future self. Change history should be readable and understandable.

## Goal

Record completed work in the version control system with a clear and structured description.

## Actions

⚠️ **The commit never carries bookkeeping writes.** The branch name and the resulting commit
hash are **never** written to any file — not the roadmap, not anywhere. They exist only in chat.
The one file write in this whole step is the roadmap `[x]` mark for the `COMMIT` entry itself
(the workflow journal requires every step to record its own completion), and it happens **before**
`git commit` runs so it lands inside the same commit — never as a separate edit afterward.

1. 🔍 **Check changes**: Run `git status` and `git diff` to make sure only necessary things are included in the commit.
2. 📗 **Roadmap**: If `ai-tasks/<JIRA-TASK-ID>/00-roadmap.md` exists, mark the `COMMIT` entry `[x]`
   now — see [td-roadmap](../td-roadmap/SKILL.md). Do not write the branch name or anything else
   to this file.
3. ➕ **Add files**: Use `git add` to index changes, including the roadmap edit from step 2.
4. 📝 **Formulate message**: Write a commit message according to the Conventional Commits standard
   (subject line + bullet-point theses in the body — see below).
5. 🚀 **Propose commit**: Generate the commit command and propose the user to execute it.
6. ✅ **Check result**: Ensure the commit was successful (clean working tree) — do not touch any
   file to "fix" or annotate the result; if something is wrong, report it in chat.
7. 💬 **Report**: Work out the recommended branch name (based on task ID) and output it, together
   with the resulting commit hash, to the chat only. **Do not switch** branches and **do not write**
   either value to any file.

## Branch Naming Rules

Use the following format for branch names:

```text
<type>/<JIRA-TASK-ID>-<short-description>
```

### Components

1. **type**: Type of changes matching the commit type (feature, fix, refactoring, etc.).
2. **JIRA-TASK-ID**: Task ID from the tracker (e.g., `<JIRA-PROJECT-KEY>-15`).
3. **short-description**: Short description of changes in English in `kebab-case`.

### Examples

- `feature/<JIRA-TASK-ID>-login-validation`
- `fix/<JIRA-TASK-ID>-timeout-error`
- `refactoring/async-db-driver`

## Formatting Rules (Conventional Commits)

We use the **Conventional Commits** standard supplemented with JIRA ID.

Format:

```bash
<type>(<scope>): <JIRA-TASK-ID> <subject>

[optional body]

[optional footer(s)]
```

### Main Types (type)

- `feature`: ✨ New functionality
- `fix`: 🐛 Bug fix
- `documentation`: 📚 Documentation update
- `style`: 💎 Formatting, spaces, semicolons (code does not change)
- `refactoring`: ♻️ Refactoring (without features and fixes)
- `performance`: 🚀 Performance improvement
- `test`: 🚨 Adding or editing tests
- `chore`: 🔧 Maintenance, configs, build

### Subject Requirements

1. **JIRA ID**: At the beginning of the description, mandatory specify the task ID
   (e.g., `<JIRA-TASK-ID>`).
2. **Imperative**: Use imperative mood: "Add feature", not "Added feature".
3. **No period**: Do not put a period at the end of the subject.
4. **Brevity**: First line (including type and ID) should not exceed **72 characters**.
5. **Language**: English (mandatory).

### Body and Footer

- **Separator**: Empty line between subject and body.
- **Format**: The body is a flat list of bullet-point theses (`-`), not prose paragraphs — one
  bullet per distinct change or reason, each answering "What?" or "Why?" (not "How?").
- **Breaking Changes**: Indicate in the footer with prefix `BREAKING CHANGE:`.
- **Links**: Links to tasks in tracker in footer (if not specified in subject).
- **Line Length**: Lines in message body should not exceed **100 characters**.
- **Continuation**: Wrap a long bullet onto an indented continuation line rather than writing a
  second sentence; keep each bullet to one thesis.

### Examples

```bash
git commit -m "feature(user): <JIRA-TASK-ID> add login validation"
```

```bash
git commit -m "fix(api): <JIRA-TASK-ID> handle timeout error correctly"
```

With message body:

```bash
git commit -m "refactoring(core): <JIRA-TASK-ID> switch to async database driver

- Replace the blocking db driver with an async one to avoid stalling under high load
- Update call sites in the connection pool to await the new driver calls

BREAKING CHANGE: The 'db.connect()' method is now asynchronous."
```

## Completion Criteria

- ✅ Changes committed to git.
- ✅ Commit message complies with rules (type, ID, format).
