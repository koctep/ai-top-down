# Project Context & Rules

This repository follows the "Top-Down" development methodology. You must build the system starting from high-level abstractions down to concrete implementation using a strict role-based handoff process.

## General Principles
- **Top-Down Approach**: Requirements -> Architecture -> Development -> Code Cleanup -> Observability -> Review -> Documentation -> Commit.
- **Strict Sequence**: Never skip steps. Each step builds on the previous one.
- **Mandatory Role Handoffs**: You MUST route tasks to the appropriate specialized subagent. Do not attempt to do everything yourself.

## File Handling & Code Standards
- **Language-Specific Rules**: Always check `.cursor/lsr/` for language-specific rules (e.g., `do-python.md`, `do-typescript.md`).
- **Encoding**: UTF-8
- **Line Endings**: LF (Unix style)
- **Line Length**: Maximum 100 characters. Can only be reduced by language rules.
- **Whitespace**: Remove trailing whitespace, ensure single final newline.
- **Language**: All code, comments, and documentation must be in English.

## Role-Based Handoff Flow
When a user provides a new task, follow this exact sequence by delegating to the appropriate agents:

1. **Analyst (`analyst`)**: Gathers requirements and creates `10-requirements.md`.
2. **Product Owner (`product_owner`)**: Reviews `10-requirements.md` for business logic.
3. **Senior Software Engineer (`senior_engineer`)**: Creates `20-architecture.md`.
4. **Team Lead (`team_lead`)**: Reviews `20-architecture.md`.
5. **Junior Software Engineer (`junior_engineer`)**: Iteratively implements code based on `20-architecture.md`.
   - *Inner Loop*: Junior writes code -> Senior reviews -> Junior writes more code.
   - Once done, Junior performs code cleanup (`40-code-cleanup.md`).
6. **Senior Software Engineer (`senior_engineer`)**: Implements observability (`50-observability.md`).
7. **Team Lead (`team_lead`)**: Analyzes tech debt (`60-review.md`), creates dev docs (`70-dev-docs.md`), and performs the final commit.
