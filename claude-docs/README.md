# claude-docs

Download the latest Claude Code documentation and provide search functionality for it.

## Overview

`claude-docs` keeps a local, offline copy of the official Claude Code documentation and gives you tools to search and reason over it, so you (and Claude) can get grounded, accurate answers about Claude Code features instead of relying on stale training knowledge.

## Installation

```bash
/plugin install ./claude-docs
```

Or from the SkogAI Market marketplace:

```bash
/plugin marketplace add skogai-market/marketplace
/plugin install claude-docs
```

## Components

### Hook: SessionStart doc download

On session start, `hooks/hooks.json` runs `scripts/download-docs.sh`, which downloads the Claude Code docs (as markdown) into `${CLAUDE_PLUGIN_ROOT}/references/docs/`. If the docs are already present, the download is skipped to keep session start fast — run the script manually to force a refresh:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/download-docs.sh"
```

### Command: `/claude-docs:search`

Search the local documentation cache:

```
/claude-docs:search how do PreToolUse hooks work
```

### Agent: `docs-researcher`

A subagent that searches and reads the documentation cache to answer questions about Claude Code, citing which doc file(s) it drew from. Claude will invoke it automatically for Claude Code questions, or you can ask for it directly.

## Requirements

- `curl` available on `PATH` (used by the download script)
