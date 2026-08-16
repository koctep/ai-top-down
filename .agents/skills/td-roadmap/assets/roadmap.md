# Roadmap: <JIRA-TASK-ID>

## Task Metadata

- **Implementation language**: *[determined at STEP 1 — mandatory]*
- **Branch name**: *[recorded by the commit procedure — reference only, do not switch]*

## Step Status

- [ ] **STEP 1: Requirements Gathering and Documentation**
- [ ] **STEP 2: High-Level Architecture Design**
- [ ] **STEP 3: Failing Repro Test**
  - [ ] *[Red test path or N/A — no behavioral change]*
- [ ] **STEP 4: Development**
  - [ ] *[Add summaries of completed iterations here]*
- [ ] **STEP 5: Code Cleanup**
- [ ] **STEP 6: Observability**
- [ ] **STEP 7: Review and Technical Debt**
- [ ] **STEP 8: Dev Docs**
- [ ] **COMMIT: Commit Changes**

## Status Legend

- `[ ]` — step not started
- `[/]` — step in progress
- `[x]` — step completed and accepted (acceptance gate passed)

See the `td-roadmap` skill for who writes which mark and when.

## Artifacts

### STEP 1: Requirements

- `ai-tasks/<JIRA-TASK-ID>/10-requirements.md`

### STEP 2: Architecture

- `ai-tasks/<JIRA-TASK-ID>/20-architecture.md`

### STEP 3: Failing Repro

- Automated red test(s) under `tests/` (or N/A note in roadmap)

### STEP 4: Development

- Source code
- Tests
- Documentation updates

### STEP 5: Code Cleanup

- `ai-tasks/<JIRA-TASK-ID>/40-code-cleanup.md`

### STEP 6: Observability

- `ai-tasks/<JIRA-TASK-ID>/50-observability.md`

### STEP 7: Review

- `ai-tasks/<JIRA-TASK-ID>/60-tech-debt.md`

### STEP 8: Dev Docs

- `doc/dev/`

### COMMIT

- Commit hash and message (Conventional Commits + JIRA ID)
