# Summarize a Claude tool_use block into a human-readable one-liner
# Usage: jq -f summarize-tool-call/transform.jq input.json
#        jq -f summarize-tool-call/transform.jq --argjson max_length 280 input.json
#
# Arguments:
#   max_length: maximum length of the detail string (default: 280, passed as JSON number)
#
# Input: a tool_use object with {name, input} fields (from Claude's content array)
# Output: object with {name, detail, summary} where summary is "name: detail" or just "name"

($ARGS.named // {}) as $args |
(try ($args.max_length | tonumber) catch 280) as $max |

def trunc($s; $m):
  if $s == null then ""
  elif ($s | tostring | length) > $m then ($s | tostring | .[0:$m] + "…")
  else ($s | tostring)
  end;

def one_line:
  tostring | gsub("\n"; " ");

.name as $name |
.input as $input |

# Extract the most relevant field per tool type
(
  if ($name == "Read" or $name == "Edit" or $name == "Write") then
    ($input.file_path // $input.filepath // $input.file // $input.filename // $input.path // "")
  elif $name == "Bash" then
    ($input.command // $input.cmd // "")
  elif $name == "TodoWrite" and ($input.todos // null | type) == "array" then
    "todos: " + ([$input.todos[] | .content + " (" + (.status // "pending") + ")"] | join(", "))
  elif ($name == "Task" or $name == "Agent") then
    ($input.prompt // $input.description // "")
  elif ($name == "WebFetch" or $name == "web_search" or $name == "WebSearch") then
    ($input.url // $input.query // "")
  elif ($name == "Grep" or $name == "Glob") then
    ($input.pattern // $input.query // "")
  elif $name == "NotebookEdit" then
    ($input.notebook_path // "")
  else
    ($input.command // $input.cmd // $input.query // $input.file // $input.filename // $input.path // $input.filepath // $input.description // "")
  end
  | one_line
  | trunc(.; $max)
) as $detail |

{
  name: $name,
  detail: $detail,
  summary: (
    if ($detail | length) > 0 then
      $name + ": " + $detail
    else
      $name
    end
  )
}