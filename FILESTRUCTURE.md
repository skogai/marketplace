# FILESTRUCTURE

```
marketplace/
├── AGENTS.md / CLAUDE.md       ← same file (CLAUDE.md symlinks to AGENTS.md)
├── FILESTRUCTURE.md            ← this file
├── README.md                   ← human-facing intro
│
├── .claude-plugin/
│   └── marketplace.json        ← Claude Code catalog
├── .agents/
│   └── plugins/
│       └── marketplace.json    ← Codex marketplace catalog
├── .codex/
│   └── config.toml             ← repo-local Codex baseline config
├── docs/
│   ├── hook-compatibility.md   ← Claude vs Codex hook behavior matrix
│   └── codex-marketplace.md    ← Codex marketplace/config notes
│
├── plugins/                    ← local plugin home (pluginRoot in manifest)
│   └── codex-hooks/            ← Codex marketplace smoke-test plugin
│       ├── .codex-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── codex-hooks-smoke/
│               └── SKILL.md
│
├── hooks/                      ← Claude Code hooks (run in this repo)
│   ├── pre-tool-use.sh         ← allow/block tool calls
│   ├── post-tool-use.sh        ← post-tool logging
│   ├── session-start.sh        ← session bootstrap + context injection
│   ├── stop.sh                 ← stop hook router
│   ├── stop-git-dirty.sh       ← warns on uncommitted changes at stop
│   ├── stop-quality-gate.sh    ← quality checks at stop
│   ├── user-prompt-submit.sh   ← user prompt handling
│   └── lesson_matcher.py       ← injects lessons into session context
│
├── tests/                      ← bats test suites
│   ├── test-helper.bash        ← shared assertions and helpers
│   ├── pre-tool-use/
│   │   └── pre-tool-use.bats   ← allow/block rule coverage (43 tests)
│   ├── codex-plugin/
│   │   └── codex-plugin.bats   ← Codex marketplace/plugin smoke tests
│   └── stop/
│       ├── router.bats
│       ├── git-dirty.bats
│       └── quality-gate.bats
│
├── scripts/
│   ├── fetch-claude-code-docs.sh   ← refresh docs/claude-code/
│   ├── fetch-codex-hook-docs.sh    ← refresh docs/codex/
│   ├── fetch-hook-docs.sh          ← refresh both ignored docs snapshots
│   └── find-agent-root.sh
│
├── docs/claude-code/           ← gitignored; official Claude Code docs
├── docs/codex/                 ← gitignored; official Codex hook docs and schemas
│
├── .skogai/                    ← skogai/core submodule (do not edit here)
│
│   Symlinked to root for discoverability:
├── agents   → .skogai/agents
├── bin      → .skogai/bin
├── commands → .skogai/commands
├── skills   → .skogai/skills
└── .claude  → .skogai/.claude

Codex-specific `.agents/` and `.codex/` directories are real repo-local directories, not `.skogai/` symlinks.
```
