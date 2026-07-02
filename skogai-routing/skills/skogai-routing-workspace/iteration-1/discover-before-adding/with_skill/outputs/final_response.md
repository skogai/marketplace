Here's the routing that's already wired up in this repo, so you don't duplicate it.

## What exists (exhaustive scan)

I scanned every `*.md` in the repo for skogai router documents (`type: router` in
frontmatter). There are exactly **two**, both at the repo root — no plugin
subdirectory has its own router:

| File | permalink | XML tags | `<routes>` contents | Validation |
|------|-----------|----------|---------------------|-----------|
| `CLAUDE.md` | `marketplace/claude` | `<routes>` | `- @SKOGAI.md` | PASS |
| `SKOGAI.md` | `marketplace/skogai` | `<routes>` | *(empty)* | PASS |

The wiring is a simple chain: `CLAUDE.md` auto-loads (Claude Code loads it
natively), and its `<routes>` block `@`-links `SKOGAI.md` into context.
`SKOGAI.md` is the intended routing hub but its `<routes>` block is currently
**empty** — it routes to nothing yet. Only the `<routes>` tag is in use; no other
typed blocks exist.

## What this means for adding your plugin

- **No routing conflict to worry about.** Plugins here are registered in
  `.claude-plugin/marketplace.json` (a `./{plugin-name}` entry), which is a
  separate mechanism from the routing convention. Adding a plugin doesn't touch
  the router chain, and none of the existing 9 plugins register routing files.
- **`SKOGAI.md`'s empty `<routes>` is the natural place** *if* you later want your
  plugin's docs pulled into context via the routing convention — add an entry
  there rather than creating a new router. But that's optional and separate from
  registering the plugin itself.
- **Don't create a second root-level router.** `CLAUDE.md` → `SKOGAI.md` is the
  established entry point; new routes belong inside the existing `SKOGAI.md`
  `<routes>` block.

Both existing routers validate cleanly, so nothing needs fixing before you add
your plugin. This was read-only — I didn't modify anything in the repo.
