---
title: commit-philosophy
type: note
permalink: skogai/skills/skogai-git/references/commit-philosophy
---

# Commit Philosophy

## Core Principle

**Commit outcomes, not process.**

The git log should read like a changelog of what shipped, not a diary of planning activity.

## What to Commit

| Event                  | Commit? | Why                                   |
| ---------------------- | ------- | ------------------------------------- |
| Project initialization | YES     | Marks project start                   |
| Feature completed      | YES     | Actual code shipped                   |
| Bug fixed              | YES     | Problem resolved                      |
| Handoff/WIP state      | YES     | Preserves context for resume          |
| Plan created           | NO      | Intermediate - commit with completion |
| Research notes         | NO      | Intermediate                          |
| Minor tweaks           | NO      | Noise                                 |

## Commit Formats

### Initialization

```
docs: initialize [project-name] ([N] phases)

[One-liner description]

Phases:
1. [phase-name]: [goal]
2. [phase-name]: [goal]
3. [phase-name]: [goal]
```

### Feature Completion

```
feat([domain]): [one-liner summary]

- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]

[If issues encountered:]
Note: [issue and resolution]
```

### Bug Fix

```
fix([domain]): [what was fixed]

- [Root cause]
- [Solution applied]
```

### WIP Handoff

```
wip: [phase-name] paused at task [X]/[Y]

Current: [task name]
[If blocked:] Blocked: [reason]
```

## Atomic Commits

- 3+ files changed = consider splitting into 2+ commits
- Each commit should be independently reviewable
- Group related changes, separate unrelated ones

## Style Detection

Before committing, check repo style:

```bash
git log --oneline -10
```

Match the existing convention:

- Conventional commits: `feat:`, `fix:`, `docs:`
- Simple messages: "Add feature X"
- Ticket references: "[JIRA-123] Add feature"

## Anti-Patterns

Avoid committing:

- "Fixed typo"
- "WIP"
- "Updates"
- "Changes"
- Planning documents without code

These create noise. Commit outcomes, not process.

## Example Good Log

```
a]7f2d1 feat(checkout): Stripe payments with webhook verification
b]3e9c4 feat(products): catalog with search, filters, and pagination
c]8a1b2 feat(auth): JWT with refresh rotation using jose
d]5c3d7 feat(foundation): Next.js 15 + Prisma + Tailwind scaffold
e]2f4a8 docs: initialize ecommerce-app (5 phases)
```

Each commit tells what shipped, not what was planned.
