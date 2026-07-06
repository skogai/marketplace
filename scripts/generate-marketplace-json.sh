#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the repository root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
EXTERNAL_REPOS_JSON="$REPO_ROOT/.claude-plugin/external-repos.json"
TEMP_FILE=$(mktemp)
CLONE_DIR=$(mktemp -d)
trap 'rm -rf "$CLONE_DIR"' EXIT

echo -e "${YELLOW}Generating marketplace.json from discovered plugins...${NC}"

# Calculate SHA256 of original file
ORIGINAL_SHA=$(shasum -a 256 "$MARKETPLACE_JSON" | awk '{print $1}')

# Extract the marketplace metadata (everything except plugins array)
MARKETPLACE_HEADER=$(jq 'del(.plugins)' "$MARKETPLACE_JSON")

# Build one marketplace plugin entry from a plugin.json's contents and a
# "source" value (a local "./relative/path" string, or a remote source object
# such as {"source":"url","url":"..."}).
build_plugin_entry() {
    local plugin_data="$1"
    local source_json="$2"

    local NAME VERSION DESCRIPTION AUTHOR LICENSE HOMEPAGE REPOSITORY
    local KEYWORDS COMMANDS AGENTS RAW_HOOKS HOOKS MCP_SERVERS SKILLS

    NAME=$(echo "$plugin_data" | jq -r '.name // empty')
    VERSION=$(echo "$plugin_data" | jq -r '.version // empty')
    DESCRIPTION=$(echo "$plugin_data" | jq -r '.description // empty')
    AUTHOR=$(echo "$plugin_data" | jq -c '.author // null')
    LICENSE=$(echo "$plugin_data" | jq -r '.license // empty')
    HOMEPAGE=$(echo "$plugin_data" | jq -r '.homepage // empty')
    REPOSITORY=$(echo "$plugin_data" | jq -r '.repository // empty')
    KEYWORDS=$(echo "$plugin_data" | jq -c '.keywords // []')
    COMMANDS=$(echo "$plugin_data" | jq -c '.commands // []')
    AGENTS=$(echo "$plugin_data" | jq -c '.agents // []')
    # hooks may be declared as a single string or an array; normalize to an array.
    RAW_HOOKS=$(echo "$plugin_data" | jq -c '.hooks // [] | if type == "array" then . else [.] end')
    # hooks/hooks.json is loaded automatically by Claude Code and must not be
    # declared in manifest.hooks (causes a "duplicate hooks file" error), so
    # strip it defensively instead of letting it leak into marketplace.json.
    HOOKS=$(echo "$RAW_HOOKS" | jq -c 'map(select(test("(^|/)hooks/hooks\\.json$") | not))')
    if [ "$RAW_HOOKS" != "$HOOKS" ]; then
        echo -e "${RED}  Warning: plugin '$NAME' declares the default hooks/hooks.json in manifest.hooks; remove it there, it's loaded automatically${NC}" >&2
    fi
    MCP_SERVERS=$(echo "$plugin_data" | jq -c '.mcpServers // []')
    SKILLS=$(echo "$plugin_data" | jq -c '.skills // []')

    if [ -z "$NAME" ]; then
        echo -e "${RED}  Warning: plugin.json has no name, skipping${NC}" >&2
        return 1
    fi

    jq -n \
        --arg name "$NAME" \
        --argjson source "$source_json" \
        --arg version "$VERSION" \
        --arg description "$DESCRIPTION" \
        --argjson author "$AUTHOR" \
        --arg license "$LICENSE" \
        --arg homepage "$HOMEPAGE" \
        --arg repository "$REPOSITORY" \
        --argjson keywords "$KEYWORDS" \
        --argjson commands "$COMMANDS" \
        --argjson agents "$AGENTS" \
        --argjson hooks "$HOOKS" \
        --argjson mcpServers "$MCP_SERVERS" \
        --argjson skills "$SKILLS" \
        '{
            name: $name,
            source: $source
        } +
        (if $version != "" then {version: $version} else {} end) +
        (if $description != "" then {description: $description} else {} end) +
        (if $author != null then {author: $author} else {} end) +
        (if $license != "" then {license: $license} else {} end) +
        (if $homepage != "" then {homepage: $homepage} else {} end) +
        (if $repository != "" then {repository: $repository} else {} end) +
        (if ($keywords | length) > 0 then {keywords: $keywords} else {} end) +
        (if ($commands | length) > 0 then {commands: $commands} else {} end) +
        (if ($agents | length) > 0 then {agents: $agents} else {} end) +
        (if ($hooks | length) > 0 then {hooks: $hooks} else {} end) +
        (if ($mcpServers | length) > 0 then {mcpServers: $mcpServers} else {} end) +
        (if ($skills | length) > 0 then {skills: $skills} else {} end)
    '
}

# --- Local plugins: discovered from */.claude-plugin/plugin.json ---

PLUGIN_FILES=$(find "$REPO_ROOT" -name "plugin.json" -path "*/.claude-plugin/plugin.json" -not -path "$REPO_ROOT/.worktrees/*" -not -path "$REPO_ROOT/.claude/worktrees/*" | \
    sort)

if [ -z "$PLUGIN_FILES" ]; then
    echo -e "${RED}No plugin.json files found!${NC}"
    exit 1
fi

echo -e "${GREEN}Found $(echo "$PLUGIN_FILES" | wc -l | tr -d ' ') local plugin(s)${NC}"

PLUGINS_JSON="[]"

while IFS= read -r plugin_file; do
    [ -f "$plugin_file" ] || continue

    echo "Processing: $plugin_file"

    PLUGIN_DIR=$(dirname "$(dirname "$plugin_file")")
    RELATIVE_PATH=$(realpath --relative-to="$REPO_ROOT" "$PLUGIN_DIR" 2>/dev/null || \
                    python3 -c "import os.path; print(os.path.relpath('$PLUGIN_DIR', '$REPO_ROOT'))")
    SOURCE_PATH="./$RELATIVE_PATH"

    PLUGIN_DATA=$(cat "$plugin_file")
    ENTRY=$(build_plugin_entry "$PLUGIN_DATA" "$(jq -n --arg s "$SOURCE_PATH" '$s')") || continue

    PLUGINS_JSON=$(echo "$PLUGINS_JSON" | jq --argjson entry "$ENTRY" '. + [$entry]')
    echo -e "${GREEN}  Added: $(echo "$ENTRY" | jq -r '.name')${NC}"
done <<< "$PLUGIN_FILES"

# --- External plugins: listed in .claude-plugin/external-repos.json ---
#
# Each entry declares where to clone a plugin from (a remote "source" object,
# same shape used in marketplace.json). The script clones it fresh every run
# and reads its plugin.json for metadata, exactly like a local plugin -- so
# these entries are never hand-edited in marketplace.json, only added to
# external-repos.json.

if [ -f "$EXTERNAL_REPOS_JSON" ]; then
    EXTERNAL_COUNT=$(jq 'length' "$EXTERNAL_REPOS_JSON")
    echo -e "${GREEN}Found $EXTERNAL_COUNT external repo(s)${NC}"

    for i in $(seq 0 $((EXTERNAL_COUNT - 1))); do
        REPO_CONF=$(jq -c ".[$i]" "$EXTERNAL_REPOS_JSON")
        REPO_NAME=$(echo "$REPO_CONF" | jq -r '.name')
        REPO_SOURCE_TYPE=$(echo "$REPO_CONF" | jq -r '.source')
        REPO_REF=$(echo "$REPO_CONF" | jq -r '.ref // empty')
        REPO_PATH=$(echo "$REPO_CONF" | jq -r '.path // empty')

        case "$REPO_SOURCE_TYPE" in
            url)
                CLONE_URL=$(echo "$REPO_CONF" | jq -r '.url')
                ;;
            github)
                CLONE_URL="https://github.com/$(echo "$REPO_CONF" | jq -r '.repo').git"
                ;;
            *)
                echo -e "${RED}  Warning: external repo '$REPO_NAME' has unknown source type '$REPO_SOURCE_TYPE', skipping${NC}"
                continue
                ;;
        esac

        echo "Cloning external repo: $REPO_NAME ($CLONE_URL)"
        DEST="$CLONE_DIR/$REPO_NAME"
        CLONE_ARGS=(--depth 1 --quiet)
        [ -n "$REPO_REF" ] && CLONE_ARGS+=(--branch "$REPO_REF")

        if ! git clone "${CLONE_ARGS[@]}" "$CLONE_URL" "$DEST" >/dev/null 2>&1; then
            echo -e "${RED}  Warning: failed to clone '$REPO_NAME' from $CLONE_URL, skipping${NC}"
            continue
        fi

        # Some external repos are themselves plugins (plugin.json at the
        # root), others are monorepos/marketplaces where the plugin lives at
        # a subpath (e.g. "plugins/codex") -- an explicit "path" in
        # external-repos.json points at that subdirectory.
        EXTERNAL_PLUGIN_FILE="$DEST/${REPO_PATH:+$REPO_PATH/}.claude-plugin/plugin.json"
        if [ ! -f "$EXTERNAL_PLUGIN_FILE" ]; then
            echo -e "${RED}  Warning: '$REPO_NAME' has no ${REPO_PATH:+$REPO_PATH/}.claude-plugin/plugin.json, skipping${NC}"
            continue
        fi

        # The marketplace "source" object only carries fields the plugin
        # loader understands. A repo with a "path" (the plugin lives in a
        # subdirectory, e.g. a monorepo/marketplace) needs Claude Code's
        # dedicated "git-subdir" source type rather than a bare url/github
        # source, since those assume the plugin sits at the repo root.
        if [ -n "$REPO_PATH" ]; then
            MARKETPLACE_SOURCE=$(jq -n --arg url "$CLONE_URL" --arg path "$REPO_PATH" --arg ref "$REPO_REF" \
                '{source: "git-subdir", url: $url, path: $path} + (if $ref != "" then {ref: $ref} else {} end)')
        else
            MARKETPLACE_SOURCE=$(echo "$REPO_CONF" | jq -c 'del(.name, .path, .ref)')
        fi

        PLUGIN_DATA=$(cat "$EXTERNAL_PLUGIN_FILE")
        ENTRY=$(build_plugin_entry "$PLUGIN_DATA" "$MARKETPLACE_SOURCE") || continue

        PLUGINS_JSON=$(echo "$PLUGINS_JSON" | jq --argjson entry "$ENTRY" '. + [$entry]')
        echo -e "${GREEN}  Added (external): $(echo "$ENTRY" | jq -r '.name')${NC}"
    done
else
    echo "No external-repos.json found, skipping external plugins"
fi

# Sort plugins alphabetically by name
PLUGINS_JSON=$(echo "$PLUGINS_JSON" | jq 'sort_by(.name)')

# Combine marketplace metadata with plugins array
FINAL_JSON=$(echo "$MARKETPLACE_HEADER" | jq --argjson plugins "$PLUGINS_JSON" '. + {plugins: $plugins}')

# Write to marketplace.json with proper formatting
echo "$FINAL_JSON" | jq '.' > "$TEMP_FILE"

# Calculate SHA256 of new file
NEW_SHA=$(shasum -a 256 "$TEMP_FILE" | awk '{print $1}')

# Check if content changed
if [ "$ORIGINAL_SHA" != "$NEW_SHA" ]; then
    echo -e "${YELLOW}Content changed, incrementing patch version...${NC}"

    # Extract current version
    CURRENT_VERSION=$(echo "$MARKETPLACE_HEADER" | jq -r '.version // "1.0.0"')

    # Parse version components (major.minor.patch)
    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

    # Increment patch version
    NEW_PATCH=$((PATCH + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"

    echo -e "${GREEN}Version: $CURRENT_VERSION -> $NEW_VERSION${NC}"

    # Update the marketplace header with new version
    MARKETPLACE_HEADER=$(echo "$MARKETPLACE_HEADER" | jq --arg version "$NEW_VERSION" '.version = $version')

    # Regenerate with new version
    FINAL_JSON=$(echo "$MARKETPLACE_HEADER" | jq --argjson plugins "$PLUGINS_JSON" '. + {plugins: $plugins}')
    echo "$FINAL_JSON" | jq '.' > "$TEMP_FILE"
fi

# Replace the original file
mv "$TEMP_FILE" "$MARKETPLACE_JSON"

echo -e "${GREEN}Successfully updated $MARKETPLACE_JSON${NC}"
echo -e "${GREEN}Total plugins: $(echo "$PLUGINS_JSON" | jq 'length')${NC}"
