# Transcript — Diagnose & fix broken CLAUDE.md router

Task: check why `core/CLAUDE.md` in the sandbox isn't pulling in `SKOGAI.md`.

Sandbox path:
`/tmp/claude-1000/-home-skogix--local-src-marketplace/cafdca9e-77c3-46a0-ab76-86734e3544bd/scratchpad/sandbox2/eval2-baseline/core/`

## Step 1 — Read the two files as-is

- `CLAUDE.md` (42 bytes) contained a single line, no trailing newline:
  `` Read [`SKOGAI.md`](SKOGAI.md) / @SKOGAI.md ``
- `SKOGAI.md` (3288 bytes) is a real "skogai/core — Agent Entrypoint" doc — the file the router is supposed to bring in.

## Step 2 — Inspect the raw bytes

`xxd CLAUDE.md` confirmed the exact contents and, importantly, that the file
ends at `@SKOGAI.md` with **no trailing newline**:

```
00000000: 5265 6164 205b 6053 4b4f 4741 492e 6d64  Read [`SKOGAI.md
00000010: 605d 2853 4b4f 4741 492e 6d64 2920 2f20  `](SKOGAI.md) / 
00000020: 4053 4b4f 4741 492e 6d64                 @SKOGAI.md
```

## Step 3 — Compare against the repo's canonical router convention

Looked at how routers are written elsewhere in this repo (the marketplace
`CLAUDE.md` and root `SKOGAI.md`). Both use a dedicated `<routes>` block with
each import on its own newline-terminated line:

```
---
permalink: marketplace/claude
type: router
---

<routes>

- @SKOGAI.md

</routes>
```

The recent commit `2d70b7e "Add root SKOGAI.md router, fixing CLAUDE.md's
dangling @SKOGAI.md link"` confirms `@SKOGAI.md` is the intended import
mechanism in this project.

## Step 4 — Diagnosis

Claude Code only pulls a file's *contents* into context via the `@path` import
syntax. In the broken file:

1. `` [`SKOGAI.md`](SKOGAI.md) `` is an ordinary Markdown link. Links are **not**
   imports — nothing gets pulled in from it. The `SKOGAI.md` inside backticks is
   a code span, and imports are explicitly not evaluated inside code spans.
   So the most prominent part of the line does nothing automatic.
2. The only real import token is `@SKOGAI.md` — but it sits at the very end of
   the file with **no trailing newline** and mixed inline with prose after a
   `/`. Import tokens are meant to be delimited by whitespace/newline; a token
   flush against EOF with no terminator is fragile and is the most likely reason
   the content isn't being reliably pulled in. Every working router in this repo
   puts `- @SKOGAI.md` on its own newline-terminated line.

Net: the file relies on a Markdown link (which imports nothing) plus a
badly-delimited trailing `@` token, instead of the repo's proven
`<routes>` + own-line import pattern.

## Step 5 — Fix

Rewrote `core/CLAUDE.md` to the canonical, unambiguous router form so the
import is on its own newline-terminated line and the misleading non-importing
link is removed:

```
<routes>

- @SKOGAI.md

</routes>
```

(No frontmatter added — the sandbox `SKOGAI.md` has none and this is the
minimal change that matches the repo's routing convention.)

Verified the written bytes end with a newline after `</routes>` and the import
line is `- @SKOGAI.md\n`.

## Assumptions

- The sandbox is an isolated throwaway copy (per task), so editing
  `core/CLAUDE.md` in place is safe.
- The intent of the router is simply to pull `SKOGAI.md` into context; I did not
  try to preserve the "Read the link" prose, since a link does not perform an
  import and duplicated it only added confusion.
- I did not attempt to spawn a nested Claude Code session to empirically expand
  the import (would be costly/out of scope); diagnosis is based on Claude Code's
  documented `@`-import rules and this repo's established convention.

## Files changed

- `core/CLAUDE.md` — replaced single-line link+trailing-`@` with a `<routes>`
  block importing `@SKOGAI.md` (copy under `files/core/CLAUDE.md`).
