#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/skogai-jq.sh"

# echo "HOOK_INPUT: $HOOK_INPUT"
# echo "HOOK_SESSION_ID: $HOOK_SESSION_ID"
# echo "HOOK_EVENT: $HOOK_EVENT"
# echo "HOOK_LOG: $HOOK_LOG"
# echo "HOOK_PROMPT: $HOOK_PROMPT"
# #
# PROMPT=$(skogai_jq_field ".prompt" "default_prompt")                       #  — extract field from input
# PERMISSION_MODE=$(skogai_jq_field ".permission_mode" "default_permission") #  — extract field from input
# A=$(skogai_jq_field ".path" "default")                                     #  — extract field from input
# B=$(skogai_jq_log "this is a summary of the chat or whatever")             # — append structured JSONL debug entry
# C=$(skogai_jq_context "event" "text")                                      #— output hookSpecificOutput JSON
# D=$(skogai_jq_decision "decision" "reason")                                # — output decision JSON
# E=$(skogai_jq_context "foobar" "baz")                                      #— output context JSON"
# EMPTY1=$(skogai_jq_bool "is-empty-string" "")                              #— output context JSON"
# EMPTY1=$(skogai_jq_bool "is-empty-string" "nope")                          #— output context JSON"
# TIMESTAMP1=$(skogai_jq_bool "is-timestamp" "2025-01-01")                   #— output context JSON"
# TIMESTAMP2=$(skogai_jq_bool "is-timestamp" "imorgon")                      #— output context JSON"
#
# echo "$A"
# echo "$B"
# echo "$C"
# echo "$D"
# echo "$E"
# echo "$PROMPT"
# echo "$PERMISSION_MODE"
# echo "$EMPTY1"
# echo "$EMPTY1"
# echo "$TIMESTAMP1"
# echo "$TIMESTAMP2"

skogai_jq_log "example-log"
