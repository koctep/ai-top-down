---
name: run-check
description: Run the repository's combined quality gate through the Makefile. Use when both static analysis and tests must pass.
---

# Run Quality Checks

Run `make check` from the repository root.

- Use it as the preferred combined validation target instead of separately invoking toolchains.
- Report whether analysis and tests passed; include the first actionable failure when they do not.
