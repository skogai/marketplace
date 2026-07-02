You're right — `core/CLAUDE.md` wasn't reliably pulling in `SKOGAI.md`. Here's what was going on.

The file was a single freeform line:

```
Read [`SKOGAI.md`](SKOGAI.md) / @SKOGAI.md
```

The part that *looks* like it includes the file — the Markdown link `[SKOGAI.md](SKOGAI.md)` — is decorative. A plain Markdown link imports nothing; it just renders as a clickable path. The only token with real import semantics is `@SKOGAI.md`, and it was tacked on after a slash in a non-standard line. On top of that, the file was missing the `type: router` frontmatter and the `<routes>` block that every other `CLAUDE.md` router in this repo uses (including your marketplace root). So it didn't match — or get treated as — a router at all.

I fixed it to the canonical form used elsewhere in the repo:

```
---
permalink: core/claude
type: router
---

<routes>

- @SKOGAI.md

</routes>
```

Now the `@SKOGAI.md` import lives inside the standard `<routes>` block (the tested pattern), the router frontmatter is present, and the dead decorative link is gone. `SKOGAI.md` sits in the same directory, so the relative import resolves correctly.

`SKOGAI.md` itself was fine — I didn't touch it.

One small assumption: I set `permalink: core/claude` to mirror the root's `marketplace/claude`. If `core` uses a different permalink scheme, tweak that slug — it doesn't affect the import.
