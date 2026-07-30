#!/usr/bin/env bash
set -euo pipefail

# Convert Claude Code JSONL chat history to skogchat format
# Usage: claude-to-skogchat.sh <input.jsonl> [output.jsonl] [--agent NAME] [--stats]
#
# Options:
#   --agent NAME    Agent name (default: claude)
#   --stats         Show statistics instead of converting
#   --tools         Extract tool usage summary
#   --help          Show this help

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

show_help() {
    cat << 'EOF'
claude-to-skogchat - Convert Claude Code JSONL to skogchat format

USAGE:
    claude-to-skogchat.sh <input.jsonl> [output.jsonl] [OPTIONS]

OPTIONS:
    --agent NAME    Set agent name (default: claude)
    --stats         Show message statistics
    --tools         Show tool usage summary
    --help          Show this help

EXAMPLES:
    # Convert to stdout
    claude-to-skogchat.sh chat.jsonl

    # Convert to file
    claude-to-skogchat.sh chat.jsonl output.jsonl

    # Show statistics
    claude-to-skogchat.sh chat.jsonl --stats

    # Show tool usage
    claude-to-skogchat.sh chat.jsonl --tools

    # Use different agent name
    claude-to-skogchat.sh chat.jsonl --agent gptme
EOF
}

# Defaults
AGENT="claude"
STATS=false
TOOLS=false
INPUT=""
OUTPUT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent)
            AGENT="$2"
            shift 2
            ;;
        --stats)
            STATS=true
            shift
            ;;
        --tools)
            TOOLS=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$INPUT" ]]; then
                INPUT="$1"
            elif [[ -z "$OUTPUT" ]]; then
                OUTPUT="$1"
            else
                echo "Too many arguments" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input
if [[ -z "$INPUT" ]]; then
    echo "Error: Input file required" >&2
    show_help
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: File not found: $INPUT" >&2
    exit 1
fi

# Show statistics
if [[ "$STATS" == "true" ]]; then
    echo "=== Message Statistics ==="
    echo ""
    echo "File: $INPUT"
    echo "Total lines: $(wc -l < "$INPUT")"
    echo ""
    echo "By type:"
    jq -s '[.[].type] | group_by(.) | map({type: .[0], count: length}) | sort_by(-.count)' "$INPUT"
    exit 0
fi

# Show tool usage
if [[ "$TOOLS" == "true" ]]; then
    echo "=== Tool Usage Summary ==="
    echo ""
    grep '"tool_use"' "$INPUT" 2>/dev/null | \
    while read -r line; do
        echo "$line" | jq -c -f "$SCRIPT_DIR/extract-tool-calls/transform.jq" --arg path "message.content" 2>/dev/null
    done | jq -s 'flatten | group_by(.name) | map({tool: .[0].name, count: length}) | sort_by(-.count)'
    exit 0
fi

# Convert to skogchat
convert() {
    while IFS= read -r line; do
        result=$(echo "$line" | jq -c -f "$SCRIPT_DIR/to-skogchat/transform.jq" --arg agent "$AGENT" 2>/dev/null)
        if [[ "$result" != "null" ]]; then
            echo "$result"
        fi
    done < "$INPUT"
}

if [[ -n "$OUTPUT" ]]; then
    convert > "$OUTPUT"
    count=$(wc -l < "$OUTPUT")
    echo "Converted $count messages to $OUTPUT" >&2
else
    convert
fi
