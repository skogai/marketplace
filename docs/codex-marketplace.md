# Codex Marketplace Setup

This repo exposes marketplace metadata for both Claude Code and Codex.

Claude Code reads:

- `.claude-plugin/marketplace.json`

Codex reads:

- `.agents/plugins/marketplace.json`

The Codex marketplace exposes a repo-local smoke-test plugin:

```json
{
  "name": "skogai",
  "interface": {
    "displayName": "skogai"
  },
  "plugins": [
    {
      "name": "codex-hooks",
      "source": {
        "source": "local",
        "path": "./plugins/codex-hooks"
      },
      "policy": {
        "installation": "INSTALLED_BY_DEFAULT",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

The plugin payload lives at `plugins/codex-hooks` and includes `.codex-plugin/plugin.json`.

## Repo-Local Codex Baseline

The repo-local Codex baseline lives at `.codex/config.toml`:

```toml
[features]
multi_agent = true
hooks = true

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
```

Keep heavier or credentialed MCP extras in `~/.codex/config.toml` unless a project task explicitly needs them.

## Validation

Local structural checks:

```bash
jq -e . .agents/plugins/marketplace.json .claude-plugin/marketplace.json
codex mcp list
env HOME=/tmp/codex-marketplace-test-home codex plugin marketplace add "$PWD"
env HOME=/tmp/codex-marketplace-test-home codex debug prompt-input "Run the Codex hooks plugin smoke test."
```

`codex mcp list` should show the repo-local `context7` server when Codex is loading `.codex/config.toml` for this workspace.

The marketplace add command should report:

```text
Added marketplace `skogai`
```

The prompt-input debug output should include `codex-hooks-smoke` after the marketplace is added with the temporary HOME.

The repeatable Bats smoke test is:

```bash
bats tests/codex-plugin/codex-plugin.bats
```

The current Codex CLI exposes marketplace add/upgrade/remove commands, but not a standalone plugin install command in `codex plugin --help`. The smoke test therefore verifies both layers separately: it adds this repo as a local marketplace, then places `plugins/codex-hooks` in the temporary Codex plugin cache and enables `codex-hooks@skogai` to confirm that Codex loads the plugin skill.
