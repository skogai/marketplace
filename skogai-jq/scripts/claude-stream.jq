#!/usr/bin/env -S jq -n -r --unbuffered -f

# Stream viewer for Claude's --output-format stream-json
# Turns stream-json into human-readable text showing progress in real-time.
#
# Usage:
#   claude --verbose --output-format stream-json -p "prompt" | ./claude-stream.jq
#
# Output format:
#   [HH:MM:SS] Starting Claude...
#   [HH:MM:SS] 🧠 <thinking summary>
#   [HH:MM:SS] 🔧 ToolName: <detail>
#
#   <assistant text>
#
#   [HH:MM:SS] Finished.
#
# This script reuses patterns from the skogai-jq transform library:
#   - collapse-newlines: one_line() collapses \n to spaces
#   - string-truncate: trunc() truncates with ellipsis
#   - summarize-tool-call: tool_detail() extracts relevant field per tool
#   - format-timestamp: ts_str uses strftime for HH:MM:SS
#   - join-todos: join_todos() formats todo arrays

def trunc($s):
  if $s == null then ""
  else ($s | tostring | if length > 280 then .[0:280] + "…" else . end)
  end;

def one_line($s):
  $s | tostring | gsub("\n"; " ");

def ts_str:
  (now | strftime("%H:%M:%S"));

def join_todos($todos):
  $todos
  | map(.content + " (" + (.status // "pending") + ")")
  | join(", ");

def tool_detail($name; $input):
  if ($name == "Read" or $name == "Edit" or $name == "Write") then
    ($input.file_path // $input.filepath // $input.file // $input.filename // $input.path // "")
  elif $name == "Bash" then
    ($input.command // $input.cmd // "")
  elif $name == "TodoWrite" and ($input.todos // null | type) == "array" then
    "todos: " + join_todos($input.todos)
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
  | one_line(.)
  | trunc(.);

def format_tool($name; $input):
  tool_detail($name; $input) as $detail |
  "[" + ts_str + "] 🔧 " + $name
  + (if ($detail | length) > 0 then ": " + $detail else "" end);

def emit($s):
  if $s == null or $s == "" then empty else $s end;

("[" + ts_str + "] Starting Claude..."),

(inputs |
  if .type == "assistant" then
    .message.content[]? |
      if .type == "text" then
        emit("\n" + .text + "\n")
      elif .type == "thinking" then
        emit("[" + ts_str + "] 🧠 " + (.thinking | one_line(.) | trunc(.)))
      elif .type == "tool_use" then
        emit(format_tool(.name; .input))
      else
        empty
      end
  else
    empty
  end
),

("[" + ts_str + "] Finished.")