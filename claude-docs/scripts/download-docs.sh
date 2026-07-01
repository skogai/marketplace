#!/usr/bin/env bash
set -euo pipefail

DIR="${CLAUDE_PLUGIN_ROOT}/tmp/docs"
BASE="https://code.claude.com/docs/en"

if [ -d "$DIR" ] && [ -n "$(ls -A "$DIR" 2>/dev/null)" ]; then
  echo "claude-docs: docs already present at $DIR, skipping download"
  exit 0
fi

mkdir -p "$DIR"

for page in \
  agent-teams amazon-bedrock analytics authentication best-practices \
  changelog checkpointing chrome claude-code-on-the-web cli-reference \
  common-workflows costs data-usage desktop desktop-quickstart \
  devcontainer discover-plugins fast-mode features-overview \
  github-actions gitlab-ci-cd google-vertex-ai headless hooks \
  hooks-guide how-claude-code-works interactive-mode jetbrains \
  keybindings legal-and-compliance llm-gateway mcp memory \
  microsoft-foundry model-config monitoring-usage network-config \
  output-styles overview permissions plugin-marketplaces plugins \
  plugins-reference quickstart remote-control sandboxing security \
  server-managed-settings settings setup skills slack statusline \
  sub-agents terminal-config third-party-integrations troubleshooting \
  vs-code zero-data-retention; do
  echo "claude-docs: fetching $page"
  curl -sL "$BASE/${page}.md" -o "$DIR/$page.md"
done
