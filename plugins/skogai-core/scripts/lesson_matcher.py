#!/usr/bin/env python3
"""Lesson matcher for Claude Code hooks.

Reads lesson files (gptme format: YAML frontmatter + markdown body),
matches against context (session start, user prompt, tool use),
and outputs matched lessons for injection via hooks' additionalContext.

CLI:
    python3 lesson_matcher.py --mode <session-start|prompt|tool> [--text "..."] [--tool "..."]

Stdout: formatted lesson markdown (empty if no matches)
Stderr: diagnostics
Exit:   always 0 (fail-open)
"""

import argparse
import os
import re
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# YAML parsing (try real yaml, fall back to regex)
# ---------------------------------------------------------------------------

try:
    import yaml as _yaml

    def _parse_yaml(text):
        return _yaml.safe_load(text) or {}
except ImportError:
    def _parse_yaml(text):
        return _fallback_parse_yaml(text)


def _fallback_parse_yaml(text):
    """Minimal YAML parser for lesson frontmatter.

    Handles:
      key: value
      key: true/false
      key: ["a", "b"]           (inline list)
      key:                      (block list)
        - a
        - b
      nested:
        subkey: value
    """
    result = {}
    lines = text.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i]
        # Skip blank/comment lines
        if not line.strip() or line.strip().startswith("#"):
            i += 1
            continue

        # Match key: value at current indent
        m = re.match(r'^(\s*)([a-zA-Z_][a-zA-Z0-9_]*):\s*(.*)', line)
        if not m:
            i += 1
            continue

        indent = len(m.group(1))
        key = m.group(2)
        value_str = m.group(3).strip()

        if value_str:
            # Inline value
            result[key] = _parse_value(value_str)
            i += 1
        else:
            # Check if next lines are block list or nested map
            i += 1
            child_lines = []
            while i < len(lines):
                cl = lines[i]
                if not cl.strip() or cl.strip().startswith("#"):
                    i += 1
                    continue
                cl_indent = len(cl) - len(cl.lstrip())
                if cl_indent <= indent:
                    break
                child_lines.append(cl)
                i += 1

            if child_lines and child_lines[0].strip().startswith("- "):
                # Block list
                items = []
                for cl in child_lines:
                    lm = re.match(r'\s*-\s*(.*)', cl)
                    if lm:
                        items.append(_parse_value(lm.group(1).strip()))
                result[key] = items
            else:
                # Nested map
                child_text = "\n".join(child_lines)
                result[key] = _fallback_parse_yaml(child_text)

    return result


def _parse_value(s):
    """Parse a YAML scalar or inline list."""
    s = s.strip()
    # Inline list: ["a", "b"]
    if s.startswith("[") and s.endswith("]"):
        inner = s[1:-1]
        items = []
        for item in re.findall(r'"([^"]*)"', inner):
            items.append(item)
        if not items:
            # Try unquoted
            for item in inner.split(","):
                item = item.strip().strip("'\"")
                if item:
                    items.append(item)
        return items
    # Boolean
    if s.lower() == "true":
        return True
    if s.lower() == "false":
        return False
    # Quoted string
    if (s.startswith('"') and s.endswith('"')) or (s.startswith("'") and s.endswith("'")):
        return s[1:-1]
    return s


# ---------------------------------------------------------------------------
# Lesson parsing
# ---------------------------------------------------------------------------

SKIP_FILENAMES = {"README.md", "TEMPLATE.md"}


def parse_lesson(content):
    """Parse a lesson file into (metadata_dict, body_str).

    Returns ({}, body) if no frontmatter found.
    """
    if not content.startswith("---"):
        return {}, content

    # Find closing ---
    end = content.find("---", 3)
    if end == -1:
        return {}, content

    fm_text = content[3:end].strip()
    body = content[end + 3:].strip()

    try:
        meta = _parse_yaml(fm_text)
    except Exception:
        meta = {}

    return meta, body


def extract_title(body):
    """Extract the first # heading from body."""
    for line in body.split("\n"):
        m = re.match(r'^#\s+(.+)', line)
        if m:
            return m.group(1).strip()
    return "Untitled"


# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

def discover_lessons(dirs):
    """Find all lesson .md files in given directories.

    Returns list of dicts: {path, meta, body, title, keywords, tools, always_apply, status}
    """
    lessons = []
    seen = set()

    for d in dirs:
        p = Path(d)
        if not p.is_dir():
            continue
        for md_file in sorted(p.rglob("*.md")):
            if md_file.name in SKIP_FILENAMES:
                continue
            real = str(md_file.resolve())
            if real in seen:
                continue
            seen.add(real)

            try:
                content = md_file.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            meta, body = parse_lesson(content)
            match_block = meta.get("match", {}) if isinstance(meta.get("match"), dict) else {}

            lessons.append({
                "path": str(md_file),
                "meta": meta,
                "body": body,
                "title": extract_title(body),
                "keywords": match_block.get("keywords", []),
                "tools": match_block.get("tools", []),
                "always_apply": bool(meta.get("always_apply", False)),
                "status": meta.get("status", "active"),
            })

    return lessons


# ---------------------------------------------------------------------------
# Scoring
# ---------------------------------------------------------------------------

def score_keywords(keywords, text):
    """Score keyword matches against text. +1.0 per keyword hit (case-insensitive)."""
    if not keywords or not text:
        return 0.0
    text_lower = text.lower()
    score = 0.0
    for kw in keywords:
        if kw.lower() in text_lower:
            score += 1.0
    return score


def score_tools(lesson_tools, tool_name):
    """Score tool match. +2.0 per tool name hit (case-insensitive)."""
    if not lesson_tools or not tool_name:
        return 0.0
    tool_lower = tool_name.lower()
    score = 0.0
    for t in lesson_tools:
        if t.lower() == tool_lower:
            score += 2.0
    return score


# ---------------------------------------------------------------------------
# Matching
# ---------------------------------------------------------------------------

def match_lessons(lessons, text=None, tool=None, mode="prompt", max_results=None):
    """Match lessons based on mode.

    Modes:
        session-start: returns lessons with always_apply=True (max 3)
        prompt: keyword match against text (max 3)
        tool: tool name match (max 2)

    Returns list of dicts sorted by score descending.
    """
    if max_results is None:
        max_results = {"session-start": 3, "prompt": 3, "tool": 2}.get(mode, 3)

    results = []

    for lesson in lessons:
        # Skip deprecated
        if lesson["status"] == "deprecated":
            continue

        if mode == "session-start":
            if lesson["always_apply"]:
                results.append({
                    "title": lesson["title"],
                    "body": lesson["body"],
                    "score": 1.0,
                    "always_apply": True,
                    "path": lesson["path"],
                })
        elif mode == "prompt":
            s = score_keywords(lesson["keywords"], text)
            if s > 0:
                results.append({
                    "title": lesson["title"],
                    "body": lesson["body"],
                    "score": s,
                    "always_apply": lesson["always_apply"],
                    "path": lesson["path"],
                })
        elif mode == "tool":
            s = score_tools(lesson["tools"], tool)
            # Also add keyword score if text provided
            if text:
                s += score_keywords(lesson["keywords"], text)
            if s > 0:
                results.append({
                    "title": lesson["title"],
                    "body": lesson["body"],
                    "score": s,
                    "always_apply": lesson["always_apply"],
                    "path": lesson["path"],
                })

    results.sort(key=lambda r: r["score"], reverse=True)
    return results[:max_results]


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

def format_output(results):
    """Format matched lessons as markdown for injection."""
    if not results:
        return ""

    parts = []
    for r in results:
        parts.append(r["body"])

    return "\n\n---\n\n".join(parts)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def get_lesson_dirs():
    """Get lesson directories from env or defaults."""
    env_dirs = os.environ.get("LESSON_DIRS", "")
    if env_dirs:
        return [d for d in env_dirs.split(":") if d]

    home = Path.home()
    cwd = Path.cwd()
    return [
        str(home / "skogai" / "dot" / "lessons"),
        str(home / ".config" / "gptme" / "lessons"),
        str(cwd / "lessons"),
        str(cwd / ".claude" / "lessons"),
    ]


def main():
    parser = argparse.ArgumentParser(description="Lesson matcher for Claude Code hooks")
    parser.add_argument("--mode", required=True, choices=["session-start", "prompt", "tool"])
    parser.add_argument("--text", default=None)
    parser.add_argument("--tool", default=None)
    args = parser.parse_args()

    try:
        dirs = get_lesson_dirs()
        lessons = discover_lessons(dirs)

        results = match_lessons(
            lessons,
            text=args.text,
            tool=args.tool,
            mode=args.mode,
        )

        output = format_output(results)
        if output:
            print(output)

    except Exception as e:
        print(f"lesson_matcher error: {e}", file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
