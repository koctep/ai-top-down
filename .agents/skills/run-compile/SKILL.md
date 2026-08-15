---
name: run-compile
description: Build or compile the repository through its Makefile. Use when producing build artifacts or validating compilation.
---

# Build the Project

Run `make build` from the repository root.

- Prefer this target over raw compiler or build-tool commands.
- Report the artifact location when the target provides one, and the actionable compiler error if it fails.
