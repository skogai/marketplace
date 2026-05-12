# Convert Claude Code message to skogchat format
# Usage: jq -f to-skogchat/transform.jq --arg agent "claude" input.json
#
# Arguments:
#   agent: the agent name (e.g., "claude", "gptme", "goose")
#
# Input: Claude Code message object with type, uuid, timestamp, message fields
# Output: skogchat message object with eid, from, to, content, created-at, parent

($ARGS.named.agent // "claude") as $agent |

# Helper to extract content from message.content array
def extract_content:
  if type == "array" then
    [
      .[] |
      if type == "object" then
        if .type == "text" then .text // ""
        elif .type == "tool_use" then "[tool_use: " + (.name // "unknown") + "]"
        elif .type == "tool_result" then
          if (.content | type) == "array" then
            [.content[] | select(.type == "text") | .text] | join("")
          elif (.content | type) == "string" then .content
          else "[tool_result]"
          end
        else null
        end
      elif type == "string" then .
      else null
      end
    ] | map(select(. != null)) | join("\n")
  elif type == "string" then .
  else ""
  end;

# Skip non-message types
if .type == "user" or .type == "assistant" then
  {
    eid: .uuid,
    from: (if .type == "user" then "user" else $agent end),
    to: (if .type == "user" then $agent else "user" end),
    content: (.message.content | extract_content),
    "created-at": .timestamp,
    parent: .parentUuid
  }
else
  null
end
