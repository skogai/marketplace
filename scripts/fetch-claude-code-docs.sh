#!/usr/bin/env bash
set -euo pipefail

AGENT_DIR="$(./find-agent-root.sh)"
DIR="$AGENT_DIR/docs/claude-code"
mkdir -p "$DIR"
BASE="https://code.claude.com/docs/en"

for page in \
    admin-setup agent-teams analytics authentication \
    auto-mode-config best-practices \
    champion-kit changelog channels channels-reference checkpointing \
    chrome claude-code-on-the-web claude-directory cli-reference \
    code-review commands common-workflows communications-kit computer-use \
    context-window costs data-usage debug-your-config deep-links \
    desktop desktop-quickstart desktop-scheduled-tasks devcontainer \
    discover-plugins env-vars errors fast-mode features-overview \
    fullscreen github-actions github-enterprise-server gitlab-ci-cd \
    glossary google-vertex-ai headless hooks hooks-guide \
    how-claude-code-works interactive-mode jetbrains keybindings \
    legal-and-compliance llm-gateway mcp memory microsoft-foundry \
    model-config monitoring-usage network-config output-styles overview \
    permission-modes permissions plugin-dependencies plugin-marketplaces \
    plugins plugins-reference quickstart remote-control routines \
    sandboxing scheduled-tasks security server-managed-settings settings \
    setup skills slack statusline sub-agents terminal-config \
    third-party-integrations tools-reference troubleshoot-install \
    troubleshooting ultraplan ultrareview vs-code voice-dictation \
    web-quickstart zero-data-retention; do
    echo "$page"
    curl -sL "$BASE/${page}.md" -o "$DIR/$page.md"
done
