# SkogAI Market Conventions

This file documents how plugin structure is actually implemented in the
`skogai-market` marketplace repository (this repo), as distinct from the
generic Claude Code plugin spec covered in SKILL.md. Consult this file when
adding or auditing a plugin here, not when explaining plugin structure in
the abstract.

## Marketplace Manifest Layout

A single `.claude-plugin/marketplace.json` at the repository root lists every
plugin. Each entry uses a relative path source pointing at a top-level
directory:

```json
{ "name": "skoghooks", "source": "./skoghooks", ... }
```

Plugins are never nested under a subdirectory grouping — each lives directly
at repo root as `{plugin-name}/`.

## Required Files Per Plugin (Community Plugins)

Per this repo's CLAUDE.md, every plugin directory must contain:

- `.claude-plugin/plugin.json`
- `README.md`

**LICENSE files are not required** for plugins in this marketplace. The
sole exception is `plugin-dev`, which keeps its `LICENSE` file because it
bundles Anthropic's original plugin-development components under their
upstream license. Do not flag a missing `LICENSE` as an error for any other
plugin, and do not add one to a new plugin unless it is similarly vendoring
licensed upstream code.

## marketplace.json Is Generated — Never Hand-Edit It

`.claude-plugin/marketplace.json` is a build artifact produced by
`scripts/generate-marketplace-json.sh` (invoked via `make
generate-marketplace-json`). Do not edit `marketplace.json` directly; edit
each plugin's own `.claude-plugin/plugin.json` instead and regenerate.

The script, for every discovered `*/.claude-plugin/plugin.json`:

1. Computes the plugin's `source` path from its directory location
   (`./{plugin-name}`).
2. Copies `name`, `version`, `description`, `author`, `license`, `homepage`,
   `repository`, `keywords`, `commands`, `agents`, `hooks`, `mcpServers`,
   and `skills` **verbatim from `plugin.json`** into the marketplace entry —
   it does not scan the plugin's directories itself. Empty/absent fields are
   omitted from the entry.
3. Strips `./hooks/hooks.json` from a plugin's declared `hooks` field if
   present, since Claude Code loads that file automatically and declaring it
   again causes a "duplicate hooks file" error.
4. Sorts plugins alphabetically by name.
5. If the resulting JSON differs from what's on disk, bumps the marketplace
   manifest's patch version automatically.

Run it after adding a plugin or changing any `plugin.json`:

```bash
make generate-marketplace-json
# or: ./scripts/generate-marketplace-json.sh
```

## Declare Components Explicitly in plugin.json (Best Practice)

Claude Code's own auto-discovery (scanning `commands/`, `agents/`,
`skills/`, `hooks/` at the plugin root) works whether or not `plugin.json`
declares those fields — but the generator script only mirrors what
`plugin.json` declares into `marketplace.json`. This means a plugin that
omits `commands`/`agents`/`skills` from its `plugin.json` will have an
empty-looking entry in `marketplace.json` even if it has plenty of working
components on disk.

- **Good practice, followed here**: `claude-docs` and `plugin-builder`
  declare their components explicitly in `plugin.json`, e.g.
  `"commands": ["./commands/search.md"]`, `"skills": ["./skills/cc-skill-builder", ...]`.
  This gives anyone skimming `marketplace.json` an at-a-glance view of what
  each plugin provides, without opening the plugin directory.
- **Gap to fix, not a neutral choice**: `plugin-dev` and `skoghooks`
  currently ship a bare-minimum `plugin.json` (little more than `name` and
  `description`), so their marketplace entries don't list their
  commands/agents/skills even though the directories exist and are
  auto-discovered at runtime. When touching these plugins' manifests, add
  the explicit arrays rather than leaving them implicit.

## Practical Guidance When Adding a Plugin Here

1. Create the plugin at top level: `./{plugin-name}/`.
2. Add `.claude-plugin/plugin.json`, `README.md`. A `LICENSE` file is not
   needed unless the plugin is itself vendoring licensed upstream code.
3. In `plugin.json`, explicitly declare `commands`/`agents`/`skills`/`hooks`/
   `mcpServers` arrays for every component the plugin ships (paths relative
   to the plugin root, e.g. `"./skills/foobar"`), even though Claude Code
   would auto-discover them without this — it's what makes the plugin
   legible in `marketplace.json`.
4. Run `make generate-marketplace-json` to regenerate
   `.claude-plugin/marketplace.json` from the updated `plugin.json`. Never
   hand-edit `marketplace.json`.
5. Validate with `plugin-validator` (or `/plugin-builder:validate`) before
   considering the plugin complete.
