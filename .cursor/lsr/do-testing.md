# Testing Guidelines for AI Agents

## Scope

This file defines **rules for AI agents writing and running automated pytest tests** in
`<PROJECT-NAME>`. It is **not** a manual-only verification checklist and does **not** replace the
project test suite or CI.

| Document | Audience | Covers |
| --- | --- | --- |
| **This file** (`.cursor/lsr/do-testing.md`) | Cursor AI agents | Per-test timeouts, bounded waits, GUI/event-loop patterns, `caplog` contract |
| [`doc/dev/testing.md`](../doc/dev/testing.md) | Developers and CI | `make test`, pytest.ini, coverage, guardrails |

Run the automated suite with `make test` (see project testing docs when present). Rules here
apply when **authoring or editing tests**, not instead of pytest.

## Documentation sync

When you change testing rules in **this file**, update the matching section in the project's
developer testing docs (e.g. `doc/dev/testing.md`) in the same PR (or open a follow-up Debt
issue). Keep these pairs aligned:

| Topic in `do-testing.md` | Mirror in project testing docs |
| --- | --- |
| Per-test timeout (mandatory) | § Per-test timeouts |
| GUI / event-loop tests | § GUI / widget tests |
| Running tests (`make test`) | § Makefile automation tests, pytest commands |
| `caplog` contract (error-path tests) | § Error-path test logging, § CI guardrails |
| References | § References (cross-links) |

When you change **developer-facing** pytest/CI docs, verify agent rules here still match
(timeouts, caplog, exit-code policy).

## General Principles

- Tests must not hang indefinitely — unbounded waits block CI, agent runs, and local
  development.
- **MANDATORY**: every test item must declare an explicit timeout before it can run.
- **No implicit/global default** — choose a timeout consciously for each module, class, or test.
- Add or update the timeout in the **same change** as the test code.

## Per-Test Timeout (MANDATORY)

Every collected test must have a `pytest.mark.timeout` marker via one of:

1. **Module scope** (preferred for files with uniform tests):

   ```python
   import pytest

   pytestmark = pytest.mark.timeout(30)
   ```

2. **Class scope** (for `unittest.TestCase` subclasses):

   ```python
   @pytest.mark.timeout(30)
   class TestFoo(unittest.TestCase):
       ...
   ```

3. **Function/method scope** (for individual overrides):

   ```python
   @pytest.mark.timeout(60)
   def test_slow_operation():
       ...
   ```

Closest-marker resolution applies: a function-level mark overrides class or module defaults.

Do **not** rely on a global `timeout = ...` in `pytest.ini` as a substitute for explicit
markers.

## Recommended Timeout Tiers

| Test kind | Suggested timeout (seconds) |
| --------- | --------------------------- |
| Pure unit (mocked I/O) | 10–30 |
| GUI widget / presenter | 30–60 |
| Integration / e2e / benchmark | 60–120 |

When in doubt, start conservative and lower only after the suite is stable.

## Internal Waits Must Be Bounded

Timeouts on the test function do not replace bounded waits inside the test body:

- `threading.Event.wait(timeout=...)` — always pass `timeout`
- GUI event loops — use a timer with a maximum duration (see project test helpers)
- Polling loops — include a deadline or iteration cap

## GUI / Event-Loop Tests

When a test runs a GUI event loop on the main thread, use the default signal-based
timeout — do **not** use `method="thread"` (it can segfault while the event loop is
running):

```python
pytestmark = pytest.mark.timeout(60)
```

Combine with bounded internal waits so event-loop polling cannot run forever even if the
outer timeout is generous.

## Running Tests

- Run the project test target (`make test`) after adding or changing tests — this executes the
  full automated pytest suite documented in project testing docs.
- Fix timeout failures by correcting hangs or raising the explicit mark — never by removing
  the marker.

## Error-path logging (`caplog` contract)

Tests that deliberately trigger production ERROR logs must satisfy **one** of:

| Rule | Requirement |
| --- | --- |
| **C1** | Assert expected log lines with `caplog.at_level(logging.ERROR, logger="...")` |
| **C2** | Register the message prefix in the project's expected-log allowlist (same PR) |
| **C3** | Keep strong behavioral assertions (signals, metrics, exceptions) as primary |
| **C4** | Do not rely on live `log_cli` output alone — caplog or allowlist required for new ERROR paths |
| **C5** | One caplog block per logger under test; match structured event prefixes when possible |

Example:

```python
def test_worker_logs_unexpected_error(caplog):
    import logging

    with caplog.at_level(logging.ERROR, logger="<package>.<module>.<component>"):
        worker.run()
    assert any("unexpected error" in r.message for r in caplog.records)
```

## References

- Language-specific notes: `.cursor/lsr/do-python.md` (Testing section)
- Project docs: `doc/dev/testing.md` (when present)
