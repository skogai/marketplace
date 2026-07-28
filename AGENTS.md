# PROJECT KNOWLEDGE BASE

**Generated:** 2026-07-10  
**Commit:** d50850a  
**Branch:** master

## OVERVIEW

SkogAI Market is a hand-curated marketplace, not a single application. Each vendored plugin is a top-level directory; the root manifest distributes them as one marketplace.

## STRUCTURE

```text
marketplace/
├── .claude-plugin/          # Generated marketplace manifest and external-plugin inputs
├── scripts/                 # Manifest generator and docs-mirror fetcher
├── ponytail/                # Full Node plugin; has its own AGENTS.md and tests
├── plugin-dev/              # Plugin-authoring commands, agents, and skills
├── skill-creator/           # Skill authoring and evaluation tooling
├── feature-dev/             # Feature-development workflow plugin
├── claude-md-management/    # CLAUDE.md maintenance plugin
├── skogai-core/             # Shared SkogAI commands and agents
└── docs/                    # Read-only Claude Code documentation mirror
```

## WHERE TO LOOK

| Task | Location | Notes |
|---|---|---|
| Marketplace rules and plugin anatomy | `CLAUDE.md` | Canonical root guidance; follow its routing rules. |
| Repository routing | `SKOGAI.md` | Points to repo tasks and plugin-local router pairs. |
| Create or validate a plugin | `plugin-dev/` | Start with its commands, agents, and skills. |
| Create or evaluate a skill | `skill-creator/skills/skill-creator/` | Contains the evaluation, report, and packaging helpers. |
| Change a plugin's registration | `<plugin>/.claude-plugin/plugin.json` | Regenerate the root manifest afterward. |
| Manage external plugins | `.claude-plugin/external-repos.json` | Source of truth for non-vendored entries. |
| Change Ponytail code or adapters | `ponytail/` | Read `ponytail/AGENTS.md` first. |

## CODE MAP

| Entry point | Role |
|---|---|
| `Makefile` | Exposes `generate-marketplace-json`. |
| `scripts/generate-marketplace-json.sh` | Discovers local plugins and external repos; writes the marketplace manifest. |
| `.claude-plugin/marketplace.json` | Generated distribution manifest. |
| `ponytail/package.json` | Ponytail test and Node-package entry point. |
| `ponytail/ponytail-mcp/index.js` | Ponytail MCP runtime entry point. |
| `ponytail/pi-extension/index.js` | Ponytail Pi extension runtime entry point. |

Reference centrality is unmeasured: no project-attached LSP or codegraph is available.

## CONVENTIONS

- Keep plugins at repository root with `.claude-plugin/plugin.json`, `README.md`, and at least one component.
- Use `${CLAUDE_PLUGIN_ROOT}` and relative manifest paths for portable intra-plugin references.
- Preserve YAML frontmatter and `<routes>` blocks in `CLAUDE.md` and `SKOGAI.md`; extend the established routing mechanism.
- Keep plugin metadata, component lists, and README claims accurate. This marketplace favors curation over volume.
- Follow the local `AGENTS.md` in `ponytail/`; its Node runtime, benchmarks, and package-local tests are exceptional in this repository.

## ANTI-PATTERNS (THIS PROJECT)

- Do not hand-edit `.claude-plugin/marketplace.json` or manually bump its version. Run the generator instead.
- Do not register external plugins in `marketplace.json`; add them to `external-repos.json`.
- Do not include `hooks/hooks.json` in a plugin manifest's `hooks` field; Claude Code auto-loads it.
- Do not nest plugins or add a separate registration step: discovery uses top-level `*/.claude-plugin/plugin.json`.
- Do not hand-edit `docs/`; refresh the documentation mirror with `scripts/download-docs.sh`.
- Do not treat root `README.md` references to `plugin-builder` as current; use `plugin-dev` and `skill-creator`.

## COMMANDS

```bash
# Regenerate after changing a local plugin manifest or external-repo entry.
make generate-marketplace-json

# Run Ponytail's main and Pi extension tests after Ponytail changes.
cd ponytail && npm test

# Run Ponytail MCP tests when changing that package.
cd ponytail/ponytail-mcp && npm test
```

## NOTES

- The manifest generator sorts entries and may patch-bump the marketplace version when generated content changes.
- Generation needs `jq` and `shasum`; resolving external plugins also needs network access and working Git authentication.
- No root test runner or visible CI workflow exists. Root validation is manifest generation; tests are concentrated in `ponytail/`.

<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes_tool` or `query_graph_tool` instead of Grep
- **Understanding impact**: `get_impact_radius_tool` instead of manually tracing imports
- **Code review**: `detect_changes_tool` + `get_review_context_tool` instead of reading entire files
- **Finding relationships**: `query_graph_tool` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview_tool` + `list_communities_tool`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
| ------ | ---------- |
| `detect_changes_tool` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context_tool` | Need source snippets for review — token-efficient |
| `get_impact_radius_tool` | Understanding blast radius of a change |
| `get_affected_flows_tool` | Finding which execution paths are impacted |
| `query_graph_tool` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes_tool` | Finding functions/classes by name or keyword |
| `get_architecture_overview_tool` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes_tool` for code review.
3. Use `get_affected_flows_tool` to understand impact.
4. Use `query_graph_tool` pattern="tests_for" to check coverage.
