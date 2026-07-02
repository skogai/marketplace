Set up `skogtasks` with the standard routing convention so Claude auto-loads its context. The directory was empty, so I initialized it as a repo and added the two router files:

**`git init`** — made it a real repo root (you said it's being split out into its own repo).

**`CLAUDE.md`** (auto-loaded by Claude Code — the entry point):
```markdown
---
permalink: skogtasks/claude
type: router
---
<routes>

- @SKOGAI.md

</routes>
```

**`SKOGAI.md`** (pulled in via the `@SKOGAI.md` link above):
```markdown
---
permalink: skogtasks/skogai
type: router
---
<routes>

</routes>
```

How it works: `CLAUDE.md` is the only file Claude Code loads automatically. Its `@SKOGAI.md` route pulls `SKOGAI.md` into context too — so just being in the `skogtasks` directory now gives Claude both. I left `SKOGAI.md`'s `<routes>` block empty on purpose; as the repo fills in, add `@`-links there (e.g. `- @docs/` or `- @src/SKOGAI.md`) to point Claude at the parts that matter.

A couple of judgment calls, since this was a fresh empty repo: I created `CLAUDE.md` outright (normally I'd check with you first, but auto-pickup is impossible without it) and ran `git init`. Both are easy to undo if you'd rather handle them differently.

Next step (optional): validate anytime with
`skogai-routing/skills/skogai-routing/scripts/validate_router.py skogtasks/SKOGAI.md skogtasks/CLAUDE.md` — both currently PASS.
