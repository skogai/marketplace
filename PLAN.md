# skogai/marketplace Plan

This repo is the plugin catalog and development workspace for the skogai personal plugin ecosystem. It hosts plugins for Claude Code (primary) and ports them to Codex and other agents as first-class citizens once the Claude Code implementation is solid.

## Direction

- **Plugins are the product.** The marketplace catalog (`marketplace.json`) is the source of truth. Each plugin in `plugins/` is independently installable and versioned.
- **Claude Code first, then port.** Implement fully for Claude Code, then adapt for Codex (and future agents). Codex support is first-class — not an afterthought.
- **hooks/ feeds plugins eventually.** The hooks in `hooks/` are not currently wired up. They are a staging ground for behavior that will migrate into `skogai-core` or the appropriate plugin as the ecosystem matures.
- **Keep the catalog lean.** Add new plugins only after the existing ones are solid. Prefer depth over breadth.

## Current Plugins

| Plugin | Purpose |
|---|---|
| `skogai-core` | Core agents and commands: `code-explorer`, `code-architect`, `code-reviewer`, `code-simplifier`, `feature-dev`, `revise-claude-md` |
| `skogai-plugin` | Plugin development toolkit: skills, agents, and commands for building Claude Code plugins |
| `skogai-tests` | Bats testing framework for shell script TDD |
| `skogai-jq` | JSON transform layer used by hooks and scripts across the ecosystem |

## Near-Term Tasks

- Audit `skogai-core` agents and commands for quality — these were recently added and need real-world validation.
- Decide what belongs in `skogai-core` vs a future domain plugin (e.g. git workflows, notifications).
- Begin migrating relevant hooks from `hooks/` into `skogai-core` once it stabilizes.
- Port `skogai-core` components to Codex (agents → Codex agents, commands → Codex equivalents).
- Update `FILESTRUCTURE.md` and `CLAUDE.md` to reflect the current plugin inventory accurately.
- Remove stale planning docs that have been superseded by implemented work.
