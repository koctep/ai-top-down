---
name: run-makefile
description: Create or improve repeatable Makefile workflows. Use when a build, test, verification, or generation command should become a documented Makefile target.
---

# Maintain Makefile Workflows

Add a root `Makefile` target when a command is repeatable and should be shared.

- Prefer a clean target over documenting a one-off shell command in rules or developer documentation.
- Add a `##` description comment on the target line.
- Ensure the default target and `make help` display those descriptions.
- Use the new target in the related `do-*` skill or project documentation.
