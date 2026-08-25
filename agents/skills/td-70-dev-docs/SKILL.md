---
name: td-70-dev-docs
description: Step 8 of the Top-Down workflow: create or update developer documentation.
---

# STEP 8: Developer Documentation

## General Principle

⚠️ **This step focuses on documenting the implementation details for other developers**. Clear documentation is crucial for maintainability and onboarding.

## Goal

Create or update developer documentation in `doc/dev` to reflect the changes made during the task.

## Actions

1. Update the roadmap per [td-roadmap](../td-roadmap/SKILL.md): STEP 8 → `[/]`.
2. Create or update documentation files in the `doc/dev` directory.
   - If a relevant file exists, update it.
   - If not, create a new markdown file (e.g., `doc/dev/<feature-name>.md`).
3. The documentation should include:
   - **Overview**: What the feature/module does.
   - **Architecture**: High-level design and key components.
   - **Usage**: How to use the code (API, functions, classes).
   - **Configuration**: Any configuration settings or environment variables.
   - **Troubleshooting**: Common issues and how to resolve them.
4. 📋 **Request review from the user** to verify the documentation.
5. The acceptance gate owner marks STEP 8 as `[x]` once the gate passes — see
   [td-roadmap](../td-roadmap/SKILL.md).

## Artifacts

- **Files**: Markdown files in `doc/dev/`.

## Template

Use a structure similar to this for new documentation files:

```markdown
# <Feature/Module Name>

## Overview
Brief description of the feature or module.

## Architecture
- **Component A**: Description
- **Component B**: Description
[Link to architecture diagram if available]

## API / Usage

### `functionName(param)`
Description of what the function does.
- **param**: Description
- **Returns**: Description

## Configuration
List of configuration options.

## Troubleshooting
Common issues and solutions.
```

## Completion Criteria

- Developer documentation in `doc/dev` is created or updated.
- ✅ **Received review and approval from the user** to close the task.
