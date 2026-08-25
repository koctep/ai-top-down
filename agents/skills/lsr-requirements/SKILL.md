---
name: lsr-requirements
description: File-handling standards and language-specific guidance for all repository edits.
---
# File Handling Rules

## Language-Specific Guidelines

When working with any file, ALWAYS use the corresponding language skill.

- Python: [lsr-python](../lsr-python/SKILL.md)
- TypeScript: [lsr-typescript](../lsr-typescript/SKILL.md)
- JavaScript: [lsr-javascript](../lsr-javascript/SKILL.md)
- Markdown: [lsr-markdown](../lsr-markdown/SKILL.md)
- Erlang: [lsr-erlang](../lsr-erlang/SKILL.md)
- Kazoo: [lsr-kazoo](../lsr-kazoo/SKILL.md)
- Flutter/Dart: [lsr-flutter](../lsr-flutter/SKILL.md)

Read and follow the guidelines in the specific language file before making changes.

When editing test files (`tests/**`, `test_*.py`, `*_test.py`), also read
[do-testing](../do-testing/SKILL.md) for mandatory per-test timeout rules.

## General Principles

- **Encoding**: Use UTF-8.
- **Line Endings**: Use LF (Unix style).
- **Line Length**: Maximum 100 characters. This global limit can ONLY be reduced (made stricter) by specific language rules, never increased.
- **Trailing Whitespace**: Remove trailing whitespace from all lines.
- **Final Newline**: Ensure a single newline at the end of the file.
- **Language**: All code, comments, and documentation must be in English.
