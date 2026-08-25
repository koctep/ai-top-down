---
name: run-deps
description: Install or refresh repository dependencies through the Makefile. Use when dependencies need to be installed or synchronized.
---

# Install Dependencies

Run `make deps` from the repository root.

- Prefer this target over toolchain-specific install commands.
- If the target is unavailable or fails, report the output and the missing prerequisite; do not guess a substitute command.
