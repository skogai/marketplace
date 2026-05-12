# Extract tool_use blocks from content arrays
# Usage: jq -f extract-tool-calls/transform.jq --arg path "message.content" input.json
#
# Arguments:
#   path: dot-separated path to the content array
#
# Input: object containing a content array with tool_use items
# Output: array of tool call objects with name, id, and input fields

($path | split(".")) as $keys |
getpath($keys) as $content |

if ($content | type) == "array" then
  [
    $content[] |
    select(type == "object" and .type == "tool_use") |
    {
      name: .name,
      id: .id,
      input: .input
    }
  ]
else
  []
end
