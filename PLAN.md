# skogai/marketplace Plan

This repo is the plugin catalog and development workspace for the skogai personal plugin ecosystem. It hosts plugins for Claude Code (primary) and ports them to Codex and other agents as first-class citizens once the Claude Code implementation is solid.

## Direction

- **Plugins are the product.** The marketplace catalog (`marketplace.json`) is the source of truth. Each plugin in `plugins/` is independently installable and versioned.
- **Claude Code first, then port.** Implement fully for Claude Code, then adapt for Codex (and future agents). Codex support is first-class — not an afterthought.
- **hooks/ is a staging ground.** `hooks/`, `tests/`, and `scripts/` contain a working hook pattern built on `scripts/skogai-jq.sh`. These are not wired into any plugin yet. They are the reference implementation that hooks in `skogai-core` and future plugins will be based on.
- **Keep the catalog lean.** Add new plugins only after the existing ones are solid. Prefer depth over breadth.

## Current Plugins

| Plugin | Always loaded | Purpose |
|---|---|---|
| `skogai-core` | yes | The trusted baseline — always present. Core code agents (`code-explorer`, `code-architect`, `code-reviewer`, `code-simplifier`) and workflow commands (`feature-dev`, `revise-claude-md`). |
| `skogai-plugin` | no | Load when developing plugins. Skills, agents, and commands for building Claude Code plugins. |
| `skogai-tests` | no | Load when working with tests. Currently focused on bats for shell script TDD. |
| `skogai-jq` | no | JSON transform and hook I/O framework. More than a skill — a tooling layer. Distribution model TBD. |

## Planned Plugins

| Plugin | Status | Notes |
|---|---|---|
| `skogai-lessons` | planned | Surfaces contextual lessons from `concepts/` via session hooks. `hooks/lesson_matcher.py` is the prototype. |

## Near-Term Tasks

- Validate `skogai-core` agents and commands in real sessions — recently added, need field testing.
- Decide distribution model for `skogai-jq`: stays as a plugin, becomes a library, or gets embedded in scripts.
- Wire `hooks/` behavior into `skogai-core` as the first real plugin hook implementation.
- Design and scaffold `skogai-lessons` plugin with `lesson_matcher.py` and `concepts/` as its foundation.
- Update `FILESTRUCTURE.md` and `CLAUDE.md` to reflect the current plugin inventory accurately.
