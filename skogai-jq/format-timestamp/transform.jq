# Format a Unix timestamp or the current time into a human-readable string
# Usage: jq -n -f format-timestamp/transform.jq --arg format "%H:%M:%S"
#        jq -f format-timestamp/transform.jq --arg path "created_at" --arg format "%Y-%m-%d" input.json
#
# Arguments:
#   format: strftime format string (default: "%H:%M:%S")
#   path: (optional) dot-separated path to a Unix timestamp field. If omitted, uses current time (now).
#
# Input: null (for current time with -n) or object with Unix timestamp at path
# Output: formatted time string, or modified object with formatted string at path

($ARGS.named.format // "%H:%M:%S") as $fmt |
($ARGS.named.path // "") as $path_str |

if $path_str == "" then
  # No path: format current time (or input number)
  if type == "number" then
    . | strftime($fmt)
  elif type == "null" then
    now | strftime($fmt)
  else
    .
  end
else
  ($path_str | split(".")) as $keys |
  getpath($keys) as $value |

  if $value != null and ($value | type) == "number" then
    setpath($keys; ($value | strftime($fmt)))
  else
    .
  end
end