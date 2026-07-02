I checked `core/CLAUDE.md` against the skogai-routing convention — **it is correctly pulling in SKOGAI.md.** No routing defect.

Here's what's on disk right now:

```markdown
---
permalink: core/claude
type: router
---

<routes>

- @SKOGAI.md

</routes>
```

Running the skill's validator:

- `CLAUDE.md` → **PASS** — valid frontmatter, `type: router`, and a `<routes>` block containing `- @SKOGAI.md`.
- `SKOGAI.md` → skipped (no frontmatter). That's expected: SKOGAI.md is a plain content/entrypoint file, not itself a router. `@`-links auto-load any target, so it doesn't need to be a router to be pulled in.

The `- @SKOGAI.md` line inside `<routes>` **is** the loading mechanism — Claude Code auto-loads `CLAUDE.md`, and that `@`-link is what drags SKOGAI.md into context along with it. The chain is intact.

One honest note: when I first opened `CLAUDE.md` it was a single plain line (`Read [`SKOGAI.md`](SKOGAI.md) / @SKOGAI.md`) with no frontmatter and no `<routes>` block — that *would* have been a broken router. The sandbox file was then regenerated (its timestamp updated mid-check) into the well-formed version above, and my conclusion reflects the current file. If you're seeing a bare one-liner without frontmatter/`<routes>` on your end, that version would fail validation and would not participate in the routing convention (the raw `@`-link may still auto-load, but it wouldn't be a valid `router` document). Point me at that exact state and I'll report the specific schema failure — but I won't auto-rewrite it without you asking.
