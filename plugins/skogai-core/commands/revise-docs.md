---
description: Update repo docs (CLAUDE.md, PLAN.md, FILESTRUCTURE.md, README.md) with learnings from this session
allowed-tools: Read, Edit, Glob
---

Review this session for learnings that should be captured in the repo's top-level documentation files.

## Step 1: Reflect

What context was missing or changed that would help future sessions?
- New conventions, patterns, or tooling discovered
- Structural changes to the repo (new files, moved things, renamed things)
- Warnings, gotchas, or decisions made
- Plan status changes (tasks completed, new tasks added)

## Step 2: Find Docs Files

Run this to see all caps docs files in the repo:

!`find . -maxdepth 3 -name "[A-Z]*.md" ! -path "./.claude/*" ! -path "./docs/*" | sort`

Decide which file each addition belongs in:
- `CLAUDE.md` — conventions, commands, patterns for AI sessions
- `PLAN.md` — current direction, near-term tasks, status
- `FILESTRUCTURE.md` — where things live in the repo
- `README.md` — human-facing intro

## Step 3: Review Current State

For each file that may need updating, read its current content:

!`cat -n CLAUDE.md`

!`cat -n PLAN.md`

!`cat -n FILESTRUCTURE.md`

## Step 4: Draft Additions

**Keep it concise** — one line per concept. These files are loaded into every session prompt; brevity matters.

Avoid:
- Verbose explanations
- Obvious information
- One-off fixes unlikely to recur

## Step 5: Show Proposed Changes

For each addition:

```
### Update: ./PLAN.md  (or CLAUDE.md / FILESTRUCTURE.md)

**Why:** [one-line reason]

\`\`\`diff
+ [the addition]
\`\`\`
```

## Step 6: Apply with Approval

Ask if the user wants to apply the changes. Only edit files they approve.
