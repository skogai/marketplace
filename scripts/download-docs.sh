#!/usr/bin/env bash
set -euo pipefail

DIR="${CLAUDE_PLUGIN_DATA}/docs/"
BASE="https://code.claude.com/docs/en"

if [ -d "$DIR" ] && [ -n "$(ls -A "$DIR" 2>/dev/null)" ]; then
  echo "claude-docs: docs already present at $DIR, skipping download"
  exit 0
fi

mkdir -p "$DIR"

for page in \
  agent-teams agent-view agents artifacts \
  authentication auto-mode-config best-practices changelog channels \
  channels-reference checkpointing claude-code-on-the-web \
  cli-reference code-review commands common-workflows \
  context-window costs data-usage debug-your-config deep-links desktop \
  desktop-linux desktop-quickstart desktop-scheduled-tasks devcontainer \
  discover-plugins env-vars errors feature-availability \
  features-overview fullscreen github-actions goal \
  headless hooks hooks-guide how-claude-code-works \
  interactive-mode keybindings large-codebases \
  llm-gateway mcp memory \
  model-config monitoring-usage network-config output-styles overview \
  permission-modes permissions platforms plugin-dependencies \
  plugin-hints plugin-marketplaces plugin-relevance plugins \
  plugins-reference quickstart remote-control routines \
  server-managed-settings sessions \
  settings setup skills statusline sub-agents terminal-config \
  third-party-integrations tools-reference troubleshoot-install \
  troubleshooting ultraplan ultrareview \
  web-quickstart workflows worktrees; do
  echo "claude-docs: fetching $page"
  curl -sL "$BASE/${page}.md" -o "$DIR/$page.md"
done
