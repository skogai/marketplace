# FILESTRUCTURE

```
marketplace/
├── AGENTS.md / CLAUDE.md       ← same file (CLAUDE.md symlinks to AGENTS.md)
├── FILESTRUCTURE.md            ← this file
├── README.md                   ← human-facing intro
│
├── .claude-plugin/
│   └── marketplace.json        ← catalog (name, owner, plugins list)
│
├── plugins/                    ← local plugin home (pluginRoot in manifest)
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
│   └── stop/
│       ├── router.bats
│       ├── git-dirty.bats
│       └── quality-gate.bats
│
├── scripts/
│   ├── fetch-claude-code-docs.sh   ← refresh docs/claude-code/
│   └── find-agent-root.sh
│
├── docs/
│   └── claude-code/            ← gitignored; official Claude Code docs
│
├── .skogai/                    ← skogai/core submodule (do not edit here)
│
│   Symlinked to root for discoverability:
├── agents   → .skogai/agents
├── bin      → .skogai/bin
├── commands → .skogai/commands
├── skills   → .skogai/skills
└── .claude  → .skogai/.claude
```
