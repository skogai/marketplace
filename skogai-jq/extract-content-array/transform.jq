# Extract text from content arrays like [{type:"text", text:"..."}]
# Usage: jq -f extract-content-array/transform.jq --arg path "message.content" [--arg separator "\n"] input.json
#
# Arguments:
#   path: dot-separated path to the content array
#   separator: string to join multiple text items (default: "\n")
#
# Input: object containing a content array at the specified path
# Output: extracted text string, or null if path doesn't exist

($path | split(".")) as $keys |
($ARGS.named.separator // "\n") as $sep |
getpath($keys) as $content |

if ($content | type) == "array" then
  [
    $content[] |
    if type == "object" then
      if .type == "text" then
        .text // ""
      elif .type == "tool_use" then
        "[tool_use: " + (.name // "unknown") + "]"
      elif .type == "tool_result" then
        if (.content | type) == "array" then
          [.content[] | select(.type == "text") | .text] | join("")
        elif (.content | type) == "string" then
          .content
        else
          "[tool_result]"
        end
      else
        null
      end
    elif type == "string" then
      .
    else
      null
    end
  ] | map(select(. != null)) | join($sep)
elif ($content | type) == "string" then
  $content
else
  null
end
