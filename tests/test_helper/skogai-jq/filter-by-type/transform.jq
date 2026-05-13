# Filter object by top-level type field
# Usage: jq -f filter-by-type/transform.jq --arg type "user" input.json
#
# Arguments:
#   type: the type value to match (e.g., "user", "assistant", "system")
#   invert: if "true", return objects that do NOT match the type (optional)
#
# Input: single JSON object with a "type" field
# Output: the object if type matches (or null if it doesn't)
#
# For JSONL streams, use with: jq -c -f ... | while read line; do ...

($ARGS.named.invert // "false") as $invert |

if has("type") then
  if $invert == "true" then
    if .type != $type then . else null end
  else
    if .type == $type then . else null end
  end
else
  null
end
