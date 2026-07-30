# Collapse newlines in a string to single spaces
# Usage: jq -f collapse-newlines/transform.jq --arg path "data" input.json
#        echo '"multi\nline"' | jq -f collapse-newlines/transform.jq --arg path ""
#
# Arguments:
#   path: dot-separated path to string field (e.g., "message.text"). Empty string for raw string input.
#
# Input: object containing a string at path, or raw string (with path="")
# Output: modified object/string with newlines replaced by spaces

if $path == "" then
  # Raw string input
  if type == "string" then
    gsub("\n"; " ")
  else
    .
  end
else
  ($path | split(".")) as $keys |
  getpath($keys) as $value |

  if $value != null and ($value | type) == "string" then
    setpath($keys; ($value | gsub("\n"; " ")))
  else
    .
  end
end