---
name: run-test
description: Run the repository test suite through the Makefile. Use when validating implementation changes or reproducing test failures.
---

# Run Tests

Run `make test` from the repository root.

- Prefer this target over calling a test framework directly.
- Follow [do-testing](../do-testing/SKILL.md) when creating or changing automated tests.
- Report the command, outcome, and relevant failing test names — full node ids, not summaries.
- On failures, classify them per
  [_shared/failing-tests-triage.md](../_shared/failing-tests-triage.md) before acting: a red
  suite is a triage trigger, and failures that predate the change get their own Jira issue
  rather than stopping the run.
