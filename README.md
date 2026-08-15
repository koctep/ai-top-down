# Top-Down AI Development Pipeline

This repository uses the "Top-Down" methodology and a role-based agent model for development with Claude Code. The process is broken down into strict steps, each executed by a specialized subagent.

## Sharing Skills with AI Tools

The canonical skill set lives in `.agents/skills`; shared workflow rules live in
`.agents/rules`. Link both into the selected tool's configuration in the current
directory:

```bash
./scripts/ai-init.sh claude
./scripts/ai-init.sh cursor gemini
./scripts/ai-init.sh --all
```

Use another source directory with `AI_SKILLS_DIR=/path/to/skills` and
`AI_RULES_DIR=/path/to/rules`, or preview the changes with `--dry-run`. Existing
files and directories are never replaced; use `--force` only to replace a
conflicting symlink.

## How to Use the Agent Pipeline in Claude Code

You need to act as a "dispatcher" and reviewer: launch the necessary agent, answer their questions, and pass the baton to the next agent after a stage is completed.

### 1. Starting the Process
Start a new task by calling the main analyst agent and giving them the essence of the task in the terminal with Claude Code running:

```bash
/agent analyst I want to add OAuth2 authentication functionality, task <JIRA-TASK-ID>
```

### 2. The Handoff Flow

Each agent strictly performs their part of the work. Here is what the full cycle looks like:

1. **Analyst (`/agent analyst`)**
   - Will gather requirements from you (ask clarifying questions if needed).
   - Will create `00-roadmap.md` and `10-requirements.md`.
   - Will ask you to hand over control to the Product Owner.

2. **Product Owner (`/agent product_owner`)**
   - Call them: `/agent product_owner check requirements`
   - They will check `10-requirements.md` for business logic and absence of technical details.
   - They will give approval for the Senior Engineer.

3. **Architect / Senior Engineer (`/agent senior_engineer`)**
   - Call them: `/agent senior_engineer prepare architecture`
   - They will design the system based on the requirements and create `20-architecture.md`.

4. **Team Lead (`/agent team_lead`)**
   - Call them: `/agent team_lead review architecture`
   - They will check the architecture for compliance with project rules.

5. **Junior Engineer (`/agent junior_engineer`)**
   - Call them: `/agent junior_engineer start development`
   - They will start writing code in iterations (no more than 100 lines at a time).
   - **Important:** After every iteration, the Junior will ask you to pass the code for review to the Senior: `/agent senior_engineer review iteration`.
   - After the feature is ready and reviewed, the Junior will perform code cleanup themselves (`40-code-cleanup.md`).

6. **Senior Engineer again (`/agent senior_engineer`)**
   - Call them: `/agent senior_engineer add observability`
   - They will add logs and metrics, creating `50-observability.md`.

7. **Final step: Team Lead (`/agent team_lead`)**
   - Call them: `/agent team_lead perform final review and tech debt`
   - They will analyze technical debt (`60-tech-debt.md`), create developer docs (`70-dev-docs.md`), and formulate the final git commit with the correct message.
   - *Note: If at this stage the Team Lead finds critical tech debt, they will return the task back to the Senior/Junior engineers.*

## How to Use the Agent Pipeline in Gemini CLI

The process in Gemini CLI is largely autonomous (if running in YOLO mode) but follows the same core methodology via custom commands.

### 1. Starting the Process
Start a new task by calling the analyst command:

```bash
/analyst I want to add OAuth2 authentication functionality, task <JIRA-TASK-ID>
```

### 2. The Handoff Flow
In Gemini CLI, agents are configured to automatically trigger the next agent using commands. The flow works as follows:

1. **Analyst (`/analyst`)** -> Will gather requirements and automatically call `/po`.
2. **Product Owner (`/po`)** -> Will review requirements and automatically call `/senior`.
3. **Senior Engineer (`/senior`)** -> Will prepare the architecture and call `/team_lead` for review.
4. **Team Lead (`/team_lead`)** -> Will approve the architecture and call `/junior` to start coding.
5. **Junior Engineer (`/junior`)** -> Will code iteratively, calling `/senior` for reviews. After cleanup, calls `/senior` for observability.
6. **Senior Engineer (`/senior`)** -> Will add observability and call `/team_lead` for final steps.
7. **Team Lead (`/team_lead`)** -> Will perform final reviews, write dev docs, and create the commit.

*Note: For the best experience with this pipeline in Gemini CLI, ensure your CLI is configured to allow agents to execute commands autonomously, or be prepared to confirm the execution of the next command in the chain.*
