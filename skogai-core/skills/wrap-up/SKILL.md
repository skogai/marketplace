---
name: wrap-up
description: end-of-session checklist — ship, remember, review, journal. invoke at session close.
---

Run four phases in order. Auto-apply all findings without asking; present a consolidated report at the end.

## phase 1: ship

**task sync** (if `gptodo` is on PATH):
1. `gptodo fetch --all` — refresh external issue states
2. `gptodo list` — find stale in-progress tasks; mark completed ones with `gptodo edit <id> --state done`

**commit:**
1. `git status` on every repo touched this session
2. Commit uncommitted changes with a descriptive message, push to remote

**worktree cleanup** (if `wt` is on PATH):
1. `wt list` — merge and remove completed worktrees

**file placement check:**
1. For any files created or saved this session: verify naming follows kebab-case convention
2. Auto-fix naming violations (rename the file)
3. If a `.md` file isn't a `{CLAUDE,SKOGAI,AGENTS}.md`, it should live in `docs/` unless explicitly placed elsewhere — auto-move misplaced files

## phase 2: remember

Review what was learned. Place each piece in the right location:
- **auto-memory** (`.planning/memory/`) — debugging insights, patterns, project quirks
- **CLAUDE.md** — permanent conventions or commands that should guide all future sessions
- **.claude/rules/** — topic-specific rules scoped to file types (use `paths:` frontmatter)
- **`@import` reference** — when CLAUDE.md would benefit from referencing another file instead of duplicating content
- **gptodo task** — future work that needs research or has dependencies

## phase 3: review & apply

Analyze the conversation for self-improvement opportunities. If the session was short or routine, say "nothing to improve" and proceed.

**categories:**
- **skill gap** — things that were wrong or needed multiple attempts
- **friction** — repeated manual steps that should be automatic
- **knowledge** — facts about projects or preferences that should have been known
- **automation** — repetitive patterns that could become skills, hooks, or scripts

Auto-apply all actionable findings. Present a summary:

```
findings (applied):
1. <category>: <what happened>
   → [location] <what was changed>

no action needed:
1. <what was found> — already documented
```

## phase 4: journal

Review the full conversation for material worth preserving: interesting solutions, milestones, architectural decisions, debugging stories.

If journal-worthy: save to `personal/journal/YYYY-MM-DD/<description>.md` (append-only).

Otherwise: "nothing worth journaling from this session."
