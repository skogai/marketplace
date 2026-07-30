# Join an array of todo objects into a human-readable summary string
# Usage: jq -f join-todos/transform.jq input.json
#        jq -f join-todos/transform.jq --arg separator " | " input.json
#        jq -f join-todos/transform.jq --arg path "input.todos" input.json
#
# Arguments:
#   path: (optional) dot-separated path to the todos array. If omitted, input must be the array directly.
#   separator: (optional) string to join items (default: ", ")
#
# Input: array of todo objects [{content, status}], or object containing such array at path
# Output: string like "Task one (completed), Task two (pending), Task three (in_progress)"

($ARGS.named.separator // ", ") as $sep |
($ARGS.named.path // "") as $path_str |

# Get the todos array
(
  if $path_str == "" then
    .
  else
    ($path_str | split(".")) as $keys |
    getpath($keys)
  end
) as $todos |

if ($todos | type) == "array" then
  [
    $todos[] |
    if type == "object" and (.content // null) != null then
      (.content | tostring) + " (" + (.status // "pending") + ")"
    elif type == "object" and (.text // null) != null then
      (.text | tostring) + " (" + (.status // "pending") + ")"
    elif type == "string" then
      . + " (pending)"
    else
      empty
    end
  ] | join($sep)
else
  ""
end