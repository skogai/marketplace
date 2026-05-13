# Plan: skogai-lessons plugin

## Goal

Create `plugins/skogai-lessons` as a first-class plugin. Move `concepts/` and the lesson-related hook logic from `hooks/` into the plugin. Register it in the Claude Code marketplace catalog. Then interview the user about the plugin's future direction from inside the plugin itself.

## What exists today

- `hooks/lesson_matcher.py` — the core matcher: reads lesson files (YAML frontmatter + markdown body), matches against context (session-start, prompt, tool), and outputs formatted markdown for hook injection.
- `hooks/test_lesson_matcher.py` — unit tests for the matcher.
- `hooks/session-start.sh` — calls `lesson_matcher.py --mode session-start` and injects matched lessons as `additionalContext`.
- `hooks/user-prompt-submit.sh` — calls `lesson_matcher.py --mode prompt --text "$prompt"` and merges into context output.
- `concepts/` — 39 markdown lesson files in gptme format (YAML frontmatter + markdown body).

The hooks above do more than lessons (skogparse, workflow-memory, session-context scripts). Extract only the lesson-relevant pieces.

## Target structure

```
plugins/skogai-lessons/
├── concepts/                    ← moved from repo root ./concepts/
│   └── *.md
├── hooks/
│   ├── session-start.sh         ← lesson-only; sources scripts/skogai-jq.sh
│   └── user-prompt-submit.sh    ← lesson-only; sources scripts/skogai-jq.sh
├── scripts/
│   ├── skogai-jq.sh             ← copy/vendor from repo scripts/skogai-jq.sh
│   └── lesson_matcher.py        ← moved from hooks/lesson_matcher.py
└── tests/
    └── test_lesson_matcher.py   ← moved from hooks/test_lesson_matcher.py
```

No `plugin.json` needed — Claude Code auto-discovers hooks from `hooks/`.

## Steps

1. Create the directory structure above.
2. Copy `scripts/skogai-jq.sh` into `plugins/skogai-lessons/scripts/skogai-jq.sh` (vendored — each plugin owns its copy).
3. Move `hooks/lesson_matcher.py` → `plugins/skogai-lessons/scripts/lesson_matcher.py`.
4. Move `hooks/test_lesson_matcher.py` → `plugins/skogai-lessons/tests/test_lesson_matcher.py`. Update any relative paths.
5. Move `concepts/` → `plugins/skogai-lessons/concepts/`.
6. Write `plugins/skogai-lessons/hooks/session-start.sh` — lean version: source `skogai-jq.sh`, call `lesson_matcher.py --mode session-start`, output via `skogai_jq_context`.
7. Write `plugins/skogai-lessons/hooks/user-prompt-submit.sh` — lean version: source `skogai-jq.sh`, call `lesson_matcher.py --mode prompt --text "$HOOK_PROMPT"`, output via `skogai_jq_context`.
8. Add `skogai-lessons` entry to `.claude-plugin/marketplace.json`.
9. Run `argc marketplace update` and `claude plugin install skogai-lessons` to verify it loads.
10. Verify `lesson_matcher.py` resolves lesson paths relative to the plugin — the `LESSON_DIR` default must point to `plugins/skogai-lessons/concepts/`, not the old repo-root `concepts/`.
11. Run `python3 plugins/skogai-lessons/tests/test_lesson_matcher.py` to confirm tests pass.
12. Remove `concepts/` from repo root and strip lesson calls from the original `hooks/session-start.sh` and `hooks/user-prompt-submit.sh` (leave non-lesson logic intact there until hooks/ is fully migrated).

## After it works

Interview the user about the plugin's future. Questions to ask from inside the plugin context:

- What types of lessons should be auto-matched vs always-injected vs on-demand?
- Should lessons live in `concepts/` (generic) and allow per-project lesson dirs too?
- Is the gptme YAML frontmatter format the right long-term format, or should it change?
- Should lesson matching extend to `PreToolUse` events (match on tool name + input)?
- Is `lesson_matcher.py` the right implementation, or should this become a compiled tool?
