---
name: run-analyze
description: Run repository static analysis through the Makefile. Use before review or when validating code quality.
---

# Run Static Analysis

Run `make analyze` from the repository root.

- Prefer this target over invoking a linter or analyzer directly.
- Fix reported issues when they are in scope, then re-run the target to verify the result.
