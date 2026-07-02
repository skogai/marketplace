# Routing already wired up in this marketplace

Here's what exists so you don't duplicate it before adding your plugin.

## There's one routing convention, and it's already implemented

The repo uses a **router document** convention: a file with frontmatter
`type: router` plus a `<routes>` XML block, chained together with Claude Code's
native `@`-links.

- **`CLAUDE.md`** (repo root) — `permalink: marketplace/claude`, `type: router`.
  Its `<routes>` block contains a single entry: `- @SKOGAI.md`.
- **`SKOGAI.md`** (repo root) — `permalink: marketplace/skogai`, `type: router`.
  Its `<routes>` block is currently **empty**.

Both validate as PASS. So the active routing chain is just `CLAUDE.md → SKOGAI.md`,
and `SKOGAI.md` has no route entries yet.

## The convention is owned by the `skogai-routing` plugin — reuse it

Everything about routing lives in the existing **`skogai-routing`** plugin
(already registered in `.claude-plugin/marketplace.json`):

- `skills/skogai-routing/SKILL.md` — defines the router type, scaffolding, and
  validation rules.
- `scripts/` — `validate_router.py`, `list_routers.py`, `list_xml_tags.py`,
  `parse-frontmatter.sh`.
- `schemas/router.schema.json`, plus `SKOGAI.md`/`CLAUDE.md` examples.

**Don't reimplement routing, a schema, or validators — they already exist.** Only
`router` is implemented in v1 (other types like `workflow`/`reference` are
planned but not built, so don't add them speculatively).

## What that means for adding your new plugin

1. **Marketplace manifest** — add your plugin to the `plugins` array in
   `.claude-plugin/marketplace.json` with `source: "./your-plugin"`. Nothing
   routing-specific is required there.
2. **Routing entry (optional)** — if your plugin needs to be discoverable via a
   route, the place to add it is `SKOGAI.md`'s `<routes>` block (currently empty),
   not `CLAUDE.md`. Keep it minimal — one `@`-link or path entry.
3. **Validate** — after any routing edit, run the plugin's own validator:
   `skogai-routing/skills/skogai-routing/scripts/validate_router.py SKOGAI.md`.

**Bottom line:** routing is centralized in `skogai-routing`. The only routing
touchpoint for a new plugin is optionally adding an entry to the empty
`<routes>` block in `SKOGAI.md`. Everything else (schema, validation,
scaffolding) is already there to reuse.

*(Note: this was a read-only inspection — nothing in the repo was modified.)*
