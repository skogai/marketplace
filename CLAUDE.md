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

Vendored plugins currently in the repo: `claude-md-management`, `feature-dev`, `plugin-dev`, `skill-creator` (Anthropic-vendored), plus `ponytail` and `skogai-core` (SkogAI/community). External plugins (e.g. `nelson`, `codex`, `skogai-routing`) live in other repos and enter the manifest via `.claude-plugin/external-repos.json` — see below.

## The one workflow that matters: regenerating the manifest

**Never hand-edit the `plugins` array in `.claude-plugin/marketplace.json`.** It is generated. After adding, removing, or changing any plugin's `.claude-plugin/plugin.json`, run:

```bash
make generate-marketplace-json      # wraps scripts/generate-marketplace-json.sh
```

`scripts/generate-marketplace-json.sh` is the source of truth for how the manifest is built, and its behavior is load-bearing:

- **Discovery**: finds every `*/.claude-plugin/plugin.json` in the repo (excluding `.worktrees/` and `.claude/worktrees/`) and builds one entry per plugin. Adding a plugin dir with a valid `plugin.json` is all it takes to be included — there is no separate registration step.
- **Source paths**: each entry's `source` is derived as `./<relative-dir>`. Plugins are expected to live at the top level.
- **External plugins**: an entry whose `source` is an object (e.g. `{"source": "url", "url": "..."}` or `{"source": "github", ...}`) points at a plugin that isn't vendored in this repo. **Never hand-edit these in `marketplace.json` either** — list the repo in `.claude-plugin/external-repos.json` instead, and the script clones it fresh (shallow) on every run and reads its `plugin.json` for metadata, same as a local plugin. Each entry there is `{"name", "source": "url"|"github", "url"|"repo", "ref"?, "path"?}`; `name`/`ref`/`path` are the script's own bookkeeping and get stripped before the value lands in `marketplace.json`. Use `"path"` when the plugin lives in a subdirectory of the repo (e.g. the repo is itself a monorepo/marketplace) — the script then emits Claude Code's `git-subdir` source type (`{source, url, path, ref?}`) instead of a plain `url`/`github` source, since those assume the plugin sits at the repo root.
- **Clone failures drop entries silently**: if an external repo can't be cloned (network, auth, deleted repo) or lacks a `plugin.json` at the expected path, the script prints a warning and **skips it** — the plugin simply vanishes from the regenerated manifest. Check the script's warnings before committing a regenerated `marketplace.json`; an entry present in `external-repos.json` but missing from the manifest usually means the clone failed, not that someone removed it. Cloning requires network access and git during generation (private repos need working auth, e.g. an SSH agent, ahead of time — several entries use `git@github.com:` SSH URLs).
- **Alphabetical sort**: entries are sorted by `name`, so diffs stay stable regardless of discovery order.
- **Auto version bump**: the marketplace's own `version` (tracked in the manifest header) is **patch-incremented automatically** whenever the generated content changes. Do not bump it by hand — let the script do it, and expect the version to move in your diff.
- **Hook-file stripping**: `hooks/hooks.json` is loaded automatically by Claude Code and must NOT appear in a plugin's `manifest.hooks`. The script strips it defensively and warns; if you see that warning, remove `hooks/hooks.json` from that plugin's `plugin.json` `hooks` array. `hooks` may be a single string or an array in the source `plugin.json` — the script normalizes either shape before stripping.
- Only non-empty fields from each `plugin.json` (`version`, `description`, `author`, `keywords`, `commands`, `agents`, `hooks`, `mcpServers`, `skills`, …) are copied into the entry.

Requires `jq` (and `shasum`); falls back to `python3` for relative-path computation.

## Plugin anatomy

A plugin is a top-level directory with:

- `.claude-plugin/plugin.json` — **required** manifest (name, version, description, author, and component arrays)
- `README.md` — **required** by the curation bar (`skogai-core` is currently missing one — a known gap, not a precedent)
- At least one component. Component dirs are all optional — create only the ones you use: `commands/*.md`, `agents/*.md`, `hooks/*.json`, `skills/<name>/SKILL.md`, `mcp-servers/*.json`

For scaffolding and validating structure, use the `plugin-dev` and `skill-creator` plugins bundled here. (Note: the README still advertises a `plugin-builder` plugin, but no such directory exists in the repo — that reference is stale.) When creating a plugin, model it on an existing one (e.g. `skogai-core` for a commands+agents+skills plugin, `claude-md-management` for commands+skills), then run the manifest generator.

### Two conventions that are easy to get wrong

- **LICENSE follows authorship.** The Anthropic-vendored plugins (`claude-md-management`, `feature-dev`, `plugin-dev`, `skill-creator`) each keep their upstream Anthropic LICENSE. The SkogAI-original/community plugins (`ponytail`, `skogai-core`) carry no LICENSE. When adding a SkogAI-original plugin, don't add a LICENSE; when vendoring third-party code, preserve its license.
- **No CODEOWNERS** beyond the Anthropic-vendored base.

## SkogAI routing (`<routes>` / SKOGAI.md)

CLAUDE.md, `SKOGAI.md`, and several plugin docs carry YAML frontmatter (`permalink`, `type: router`) and a `<routes>` block of `@`-links. This is the SkogAI memory-routing convention — the `<routes>` block chains context files together (CLAUDE.md → SKOGAI.md → …). When editing these files, **preserve the frontmatter and the `<routes>` block**; add new `@`-links there rather than inventing a new mechanism.

Every plugin directory has its own SKOGAI.md/CLAUDE.md router pair describing that plugin. These are deliberately not `@`-linked from the root — read a plugin's own SKOGAI.md when working inside it.

The root `AGENTS.md` is a generated knowledge-base snapshot (stamped with a commit hash); treat it as a reference summary, not a place to author guidance — this file and `SKOGAI.md` are the canonical instructions.

## Plugins with their own build/test

Most plugins are pure markdown/JSON and need no build. The exception is **`ponytail`**, a full Node project (its own `package.json`, `ponytail-mcp/` MCP server, `pi-extension/`, `benchmarks/`, `tests/`, and its own `AGENTS.md` — read it before changing ponytail code). Run its tests from that directory:

```bash
cd ponytail && npm test                # node --test tests/*.test.js && npm test --prefix pi-extension
cd ponytail/ponytail-mcp && npm test   # MCP server tests, run separately when touching that package
```

There is no root-level test runner or CI workflow; root "validation" is regenerating the manifest cleanly.

## The `docs/` directory

`docs/` is a local mirror of the official Claude Code documentation, fetched by `scripts/download-docs.sh` from `https://code.claude.com/docs/en`. The script writes into `${CLAUDE_PLUGIN_DATA}/docs/` and **skips the download if docs already exist** (idempotent). Treat these as a read-only reference cache — don't hand-edit them; re-run the script to refresh.

## Curation bar

This is hand-curated: prefer quality over quantity. A plugin must have working, accessible sources, accurate metadata (descriptions/keywords/component lists that match reality), and clear README documentation before it goes in the manifest.
