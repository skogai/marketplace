---
title: commit-push
type: note
permalink: skogai/skills/skogai-git/workflows/commit-push
---

# Commit and Push Workflow

Semantic commits following "outcomes not process" philosophy.

\<required_reading>

- references/commit-philosophy.md \</required_reading>

<process>

## 1. Check What Changed

```bash
git status
git diff
```

## 2. Stage Changes

```bash
# Stage specific files
git add src/feature.ts src/feature.test.ts

# Stage all changes
git add .

# Interactive staging
git add -p
```

## 3. Detect Repo Style

```bash
git log --oneline -10
```

Match existing convention:

- Conventional: `feat:`, `fix:`, `docs:`
- Simple: "Add feature X"
- Ticket refs: "[JIRA-123] Add feature"

## 4. Write Commit Message

**Format:**

```
type(scope): short description

- Key accomplishment 1
- Key accomplishment 2

[Optional: Note about issues/decisions]
```

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `refactor` - Code change (no feature/fix)
- `test` - Tests
- `chore` - Maintenance

**Example:**

```bash
git commit -m "feat(auth): add JWT refresh token rotation

- Implement refresh token endpoint
- Add token expiry validation
- Store refresh tokens in Redis

Note: Using jose library for JWT handling"
```

## 5. Atomic Commits

If 3+ files changed, consider splitting:

```bash
# First commit: core feature
git add src/core/
git commit -m "feat(auth): add token generation logic"

# Second commit: tests
git add tests/
git commit -m "test(auth): add token generation tests"

# Third commit: docs
git add docs/
git commit -m "docs(auth): document token flow"
```

## 6. Push

```bash
# Push to current branch
git push

# Push and set upstream
git push -u origin feature/my-feature

# Force push (use carefully)
git push --force-with-lease
```

## 7. Using wt step (LLM-generated)

If wt is configured with LLM:

```bash
wt step commit
```

Generates commit message from diff automatically.

</process>

\<message_templates>

## Feature

```
feat(scope): add [feature name]

- [What it does]
- [Key implementation detail]
- [User-facing change]
```

## Bug Fix

```
fix(scope): resolve [issue]

- Root cause: [what was wrong]
- Solution: [how it was fixed]
```

## Documentation

```
docs(scope): document [topic]

- [What was documented]
- [Where to find it]
```

## Initialization

```
docs: initialize [project-name] ([N] phases)

[One-liner description]

Phases:
1. [phase]: [goal]
2. [phase]: [goal]
```

## WIP Handoff

```
wip: [phase] paused at task [X]/[Y]

Current: [task name]
Blocked: [reason if blocked]
```

\</message_templates>

\<anti_patterns>

Avoid:

- "Fixed typo"
- "WIP"
- "Updates"
- "Changes"
- Committing without message
- Giant commits with unrelated changes

These create noise. Commit outcomes, not process.

\</anti_patterns>

\<success_criteria>

- Commits are atomic and reviewable
- Messages describe outcomes
- Matches repo style
- Changes pushed to remote \</success_criteria>
