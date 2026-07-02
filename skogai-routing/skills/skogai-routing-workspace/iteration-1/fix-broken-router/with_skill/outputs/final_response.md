You're right — that `CLAUDE.md` isn't pulling in `SKOGAI.md` the way the skogai-routing
convention intends. I checked it with the skill's validator and by reading the raw file.

**What the file actually is** (whole contents, one line):

```
Read [`SKOGAI.md`](SKOGAI.md) / @SKOGAI.md
```

**Why it's broken as a router:**

1. **No frontmatter / not a router.** The validator can't even classify it —
   `WARN  CLAUDE.md: no frontmatter found — skipping`. Without `type: router` it isn't a
   recognized router document.
2. **No `<routes>` block.** In this convention the `<routes>` block *is* the loading
   mechanism, and it's simply not there.
3. **The markdown link doesn't auto-load.** `[SKOGAI.md](SKOGAI.md)` is just a clickable
   link — Claude Code does not auto-import it. That leaves only the trailing bare
   `@SKOGAI.md` as a load candidate, so the file is relying on an incidental inline
   mention instead of the intended router shape.

**Recommended fix** — make it match the standard router shape (this is
`examples/CLAUDE.md.example`):

```markdown
---
permalink: skogai-routing/claude
type: router
---
<routes>

- @SKOGAI.md

</routes>
```

I did **not** change the file — the skill's rule is to report validation failures and
let you (or a follow-up edit) apply the fix rather than auto-fixing. Say the word and I'll
rewrite `core/CLAUDE.md` to the shape above.

(Separately: `core/SKOGAI.md` also isn't in router shape, but that's fine here — it's the
destination content doc, not the file doing the routing.)
