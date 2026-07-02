---
permalink: marketplace/claude
type: router
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

<routes>

- @SKOGAI.md

</routes>

## What this repository is

SkogAI Market is a **hand-curated marketplace of Claude Code plugins** (commands, agents, skills, hooks, MCP servers). The whole repo is a single distribution unit: each top-level directory is one plugin, and `.claude-plugin/marketplace.json` is the generated manifest that lists them all. Users add it with `/plugin marketplace add skogai-market/marketplace` and install individual plugins from the `/plugin` menu.

## The one workflow that matters: regenerating the manifest

**Never hand-edit the `plugins` array in `.claude-plugin/marketplace.json`.** It is generated. After adding, removing, or changing any plugin's `.claude-plugin/plugin.json`, run:

```bash
make generate-marketplace-json      # wraps scripts/generate-marketplace-json.sh
```

`scripts/generate-marketplace-json.sh` is the source of truth for how the manifest is built, and its behavior is load-bearing:

- **Discovery**: finds every `*/.claude-plugin/plugin.json` in the repo (excluding `.claude/worktrees/`) and builds one entry per plugin. Adding a plugin dir with a valid `plugin.json` is all it takes to be included — there is no separate registration step.
- **Source paths**: each entry's `source` is derived as `./<relative-dir>`. Plugins are expected to live at the top level.
- **Alphabetical sort**: entries are sorted by `name`, so diffs stay stable regardless of discovery order.
- **Auto version bump**: the marketplace's own `version` (currently tracked in the manifest header) is **patch-incremented automatically** whenever the generated content changes. Do not bump it by hand — let the script do it, and expect the version to move in your diff.
- **Hook-file stripping**: `hooks/hooks.json` is loaded automatically by Claude Code and must NOT appear in a plugin's `manifest.hooks`. The script strips it defensively and warns; if you see that warning, remove `hooks/hooks.json` from that plugin's `plugin.json` `hooks` array.
- Only non-empty fields from each `plugin.json` (`version`, `description`, `author`, `keywords`, `commands`, `agents`, `hooks`, `mcpServers`, `skills`, …) are copied into the entry.

Requires `jq` (and `shasum`); falls back to `python3` for relative-path computation.

## Plugin anatomy

A plugin is a top-level directory with:

- `.claude-plugin/plugin.json` — **required** manifest (name, version, description, author, and component arrays)
- `README.md` — **required**
- At least one component. Component dirs are all optional — create only the ones you use: `commands/*.md`, `agents/*.md`, `hooks/*.json`, `skills/<name>/SKILL.md`, `mcp-servers/*.json`

For scaffolding and validating structure, use the `plugin-dev` and `skill-creator` plugins bundled here. (Note: the README still references a `plugin-builder` plugin, but no such directory exists in the repo — that reference is stale.) When creating a plugin, model it on an existing one (e.g. `commit-commands` for a commands-only plugin), then run the manifest generator.

### Two conventions that are easy to get wrong

- **LICENSE follows authorship.** The Anthropic-vendored plugins (`claude-code-setup`, `claude-md-management`, `code-simplifier`, `commit-commands`, `feature-dev`, `skill-creator`, `plugin-dev`) each keep their upstream Anthropic LICENSE. The community/SkogAI-original plugins (`ponytail`, `skogai-routing`, `skoghooks`) carry no LICENSE. When adding a SkogAI-original plugin, don't add a LICENSE; when vendoring third-party code, preserve its license.
- **No CODEOWNERS** beyond the Anthropic-vendored base.

## SkogAI routing (`<routes>` / SKOGAI.md)

CLAUDE.md, `SKOGAI.md`, and several plugin docs carry YAML frontmatter (`permalink`, `type: router`) and a `<routes>` block of `@`-links. This is the SkogAI memory-routing convention — the `<routes>` block chains context files together (CLAUDE.md → SKOGAI.md → …). When editing these files, **preserve the frontmatter and the `<routes>` block**; add new `@`-links there rather than inventing a new mechanism.

## Plugins with their own build/test

Most plugins are pure markdown/JSON and need no build. The exception is **`ponytail`**, a full Node project (its own `package.json`, `ponytail-mcp/` MCP server, `pi-extension/`, `benchmarks/`, `tests/`). Run its tests from that directory:

```bash
cd ponytail && npm test        # node --test tests/*.test.js && npm test --prefix pi-extension
```

## The `docs/` directory

`docs/` is a local mirror of the official Claude Code documentation, fetched by `scripts/download-docs.sh` from `https://code.claude.com/docs/en`. The script writes into `${CLAUDE_PLUGIN_DATA}/docs/` and **skips the download if docs already exist** (idempotent). Treat these as a read-only reference cache — don't hand-edit them; re-run the script to refresh.

## Curation bar

This is hand-curated: prefer quality over quantity. A plugin must have working, accessible sources, accurate metadata (descriptions/keywords/component lists that match reality), and clear README documentation before it goes in the manifest.
