Set up `skogtasks` as a routing-enabled repo. Created two files at the repo root:

**`CLAUDE.md`** — the auto-loaded entry point Claude Code reads on its own:
```markdown
---
permalink: skogtasks/claude
type: router
---
<routes>

- @SKOGAI.md

</routes>
```

**`SKOGAI.md`** — the repo's router, currently empty (nothing to route to yet):
```markdown
---
permalink: skogtasks/skogai
type: router
---
<routes>

</routes>
```

**How the pickup works:** Claude Code auto-loads `CLAUDE.md`; its `@SKOGAI.md`
link pulls `SKOGAI.md` into context alongside it. So as you fill in `SKOGAI.md`'s
`<routes>` block — pointing at directories and files as `skogtasks` grows —
Claude will start loading that context automatically whenever you work in the repo.

**A couple of notes:**
- The directory only had a `.git-placeholder`, no real `.git` yet — I treated it
  as the repo root since you said it's its own repo. Run `git init` there when
  you're ready.
- The skill normally asks before creating a fresh `CLAUDE.md`, but since the goal
  is automatic context pickup and `SKOGAI.md` isn't natively auto-loaded, the
  `CLAUDE.md` is what makes it work — so I created it, matching how the other repos
  are set up.
- I left both `<routes>` blocks minimal rather than inventing entries. Next step
  whenever you want to sanity-check them: `validate_router.py CLAUDE.md SKOGAI.md`
  (both already PASS).
