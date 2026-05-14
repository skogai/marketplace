"""Tests for lesson_matcher.py - TDD: tests written before implementation."""

import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPT_DIR = Path(__file__).parent
MATCHER = SCRIPT_DIR / "lesson_matcher.py"


# ---------------------------------------------------------------------------
# Fixtures: create temp lesson files
# ---------------------------------------------------------------------------

ALWAYS_APPLY_LESSON = """\
---
match:
  keywords: ["guardrail", "safety"]
always_apply: true
---

# Always Active Guardrail

## Rule
This lesson always applies at session start.

## Pattern
Always check before acting.
"""

GIT_LESSON = """\
---
match:
  keywords: ["git", "commit", "workflow"]
---

# Git Workflow

## Rule
Stage only intended files explicitly.

## Pattern
```bash
git commit path1 path2 -m "message"
```
"""

BASH_LESSON = """\
---
match:
  keywords: ["shell"]
  tools: ["shell", "bash"]
---

# Shell Best Practices

## Rule
Use proper shell commands.

## Pattern
```bash
echo "content" > file.txt
```
"""

DEPRECATED_LESSON = """\
---
match:
  keywords: ["old", "legacy"]
status: deprecated
---

# Deprecated Lesson

## Rule
This should not appear in results.
"""

NO_FRONTMATTER_LESSON = """\
# Plain Lesson

## Rule
This lesson has no YAML frontmatter.

## Context
It should still be discoverable but have empty metadata.
"""

INLINE_LIST_LESSON = """\
---
match:
  keywords: ["inline", "list"]
---

# Inline List Lesson

## Rule
Test inline YAML list parsing.
"""

BLOCK_LIST_LESSON = """\
---
match:
  keywords:
    - block
    - list
    - yaml
---

# Block List Lesson

## Rule
Test block YAML list parsing.
"""

MULTI_KEYWORD_LESSON = """\
---
match:
  keywords: ["python", "execution", "script", "shebang"]
---

# Python Execution

## Rule
Choose correct Python execution method.
"""

ALWAYS_APPLY_2 = """\
---
match:
  keywords: ["safety"]
always_apply: true
---

# Second Always Apply

## Rule
Another always-apply lesson.
"""

ALWAYS_APPLY_3 = """\
---
match:
  keywords: ["context"]
always_apply: true
---

# Third Always Apply

## Rule
Yet another always-apply lesson.
"""

ALWAYS_APPLY_4 = """\
---
match:
  keywords: ["extra"]
always_apply: true
---

# Fourth Always Apply (should be cut off by max 3)

## Rule
This one should be excluded by the max count.
"""


@pytest.fixture
def lesson_dir(tmp_path):
    """Create a temp directory with fixture lesson files."""
    d = tmp_path / "lessons"
    d.mkdir()

    (d / "always-apply.md").write_text(ALWAYS_APPLY_LESSON)
    (d / "git-workflow.md").write_text(GIT_LESSON)
    (d / "shell-best-practices.md").write_text(BASH_LESSON)
    (d / "deprecated.md").write_text(DEPRECATED_LESSON)
    (d / "no-frontmatter.md").write_text(NO_FRONTMATTER_LESSON)
    (d / "inline-list.md").write_text(INLINE_LIST_LESSON)
    (d / "block-list.md").write_text(BLOCK_LIST_LESSON)
    (d / "multi-keyword.md").write_text(MULTI_KEYWORD_LESSON)
    (d / "README.md").write_text("# README\nThis should be skipped.")
    (d / "TEMPLATE.md").write_text("# TEMPLATE\nThis should be skipped.")

    return d


@pytest.fixture
def many_always_apply_dir(tmp_path):
    """Dir with 4 always_apply lessons (to test max 3 cap)."""
    d = tmp_path / "lessons"
    d.mkdir()
    (d / "always1.md").write_text(ALWAYS_APPLY_LESSON)
    (d / "always2.md").write_text(ALWAYS_APPLY_2)
    (d / "always3.md").write_text(ALWAYS_APPLY_3)
    (d / "always4.md").write_text(ALWAYS_APPLY_4)
    return d


# ---------------------------------------------------------------------------
# Import the module under test
# ---------------------------------------------------------------------------

@pytest.fixture(autouse=True)
def _add_script_dir_to_path():
    """Ensure we can import lesson_matcher."""
    sys.path.insert(0, str(SCRIPT_DIR))
    yield
    sys.path.pop(0)


def _import_matcher():
    """Import (or reimport) lesson_matcher module."""
    import importlib
    if "lesson_matcher" in sys.modules:
        return importlib.reload(sys.modules["lesson_matcher"])
    import lesson_matcher
    return lesson_matcher


# ===========================================================================
# Parsing tests
# ===========================================================================

class TestParsing:
    def test_parse_frontmatter_with_yaml(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(INLINE_LIST_LESSON)
        kw = meta.get("match", {}).get("keywords", [])
        assert "inline" in kw
        assert "list" in kw

    def test_parse_frontmatter_block_list(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(BLOCK_LIST_LESSON)
        kw = meta.get("match", {}).get("keywords", [])
        assert "block" in kw
        assert "list" in kw
        assert "yaml" in kw

    def test_parse_frontmatter_tools(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(BASH_LESSON)
        tools = meta.get("match", {}).get("tools", [])
        assert "shell" in tools
        assert "bash" in tools

    def test_parse_frontmatter_always_apply(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(ALWAYS_APPLY_LESSON)
        assert meta.get("always_apply") is True

    def test_parse_frontmatter_no_frontmatter(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(NO_FRONTMATTER_LESSON)
        assert meta == {} or meta.get("match") is None

    def test_parse_frontmatter_status(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(DEPRECATED_LESSON)
        assert meta.get("status") == "deprecated"

    def test_extract_title(self):
        m = _import_matcher()
        meta, body = m.parse_lesson(GIT_LESSON)
        title = m.extract_title(body)
        assert title == "Git Workflow"


# ===========================================================================
# Matching tests
# ===========================================================================

class TestMatching:
    def test_match_keyword_exact(self):
        m = _import_matcher()
        score = m.score_keywords(["git"], "I want to use git for version control")
        assert score >= 1.0

    def test_match_keyword_case_insensitive(self):
        m = _import_matcher()
        score = m.score_keywords(["Git"], "git workflow tips")
        assert score >= 1.0

    def test_match_keyword_no_match(self):
        m = _import_matcher()
        score = m.score_keywords(["docker"], "git workflow tips")
        assert score == 0.0

    def test_match_prompt_scores_multiple_keywords(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        # multi-keyword lesson has: python, execution, script, shebang
        text = "python script execution with shebang"
        results = m.match_lessons(lessons, text=text, mode="prompt")
        # The multi-keyword lesson should score highest (4 keywords match)
        top = results[0]
        assert top["score"] >= 3.0

    def test_match_prompt_sorts_by_score(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        text = "python script execution with shebang"
        results = m.match_lessons(lessons, text=text, mode="prompt")
        scores = [r["score"] for r in results]
        assert scores == sorted(scores, reverse=True)

    def test_match_tool_scores_2x(self):
        m = _import_matcher()
        score = m.score_tools(["shell", "bash"], "Bash")
        assert score >= 2.0

    def test_match_tool_case_insensitive(self):
        m = _import_matcher()
        score = m.score_tools(["bash"], "Bash")
        assert score >= 2.0

    def test_match_skips_deprecated(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        # "old" and "legacy" are keywords in deprecated lesson
        text = "old legacy code"
        results = m.match_lessons(lessons, text=text, mode="prompt")
        titles = [r["title"] for r in results]
        assert "Deprecated Lesson" not in titles


# ===========================================================================
# Mode tests
# ===========================================================================

class TestModes:
    def test_mode_session_start(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        results = m.match_lessons(lessons, mode="session-start")
        assert len(results) >= 1
        # All results should have always_apply
        for r in results:
            assert r["always_apply"] is True

    def test_mode_prompt(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        results = m.match_lessons(lessons, text="git commit workflow", mode="prompt")
        assert len(results) >= 1
        titles = [r["title"] for r in results]
        assert "Git Workflow" in titles

    def test_mode_tool(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        results = m.match_lessons(lessons, tool="Bash", mode="tool")
        assert len(results) >= 1
        titles = [r["title"] for r in results]
        assert "Shell Best Practices" in titles

    def test_mode_session_start_empty(self, tmp_path):
        """No always_apply lessons → empty result."""
        d = tmp_path / "lessons"
        d.mkdir()
        (d / "regular.md").write_text(GIT_LESSON)
        m = _import_matcher()
        lessons = m.discover_lessons([str(d)])
        results = m.match_lessons(lessons, mode="session-start")
        assert results == []


# ===========================================================================
# Integration tests
# ===========================================================================

class TestIntegration:
    def test_discover_lessons_from_dir(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        # Should find all .md files except README and TEMPLATE
        filenames = [Path(l["path"]).name for l in lessons]
        assert "git-workflow.md" in filenames
        assert "shell-best-practices.md" in filenames

    def test_discover_skips_readme(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        filenames = [Path(l["path"]).name for l in lessons]
        assert "README.md" not in filenames
        assert "TEMPLATE.md" not in filenames

    def test_format_output(self, lesson_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(lesson_dir)])
        results = m.match_lessons(lessons, text="git commit", mode="prompt")
        output = m.format_output(results)
        assert "Git Workflow" in output
        assert "Stage only intended files" in output

    def test_format_respects_max_count(self, many_always_apply_dir):
        m = _import_matcher()
        lessons = m.discover_lessons([str(many_always_apply_dir)])
        results = m.match_lessons(lessons, mode="session-start", max_results=3)
        assert len(results) <= 3


# ===========================================================================
# CLI tests (subprocess)
# ===========================================================================

class TestCLI:
    def test_cli_session_start(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "session-start"],
            capture_output=True, text=True, env=env,
        )
        assert result.returncode == 0
        assert "Always Active Guardrail" in result.stdout

    def test_cli_prompt(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "prompt", "--text", "git commit workflow"],
            capture_output=True, text=True, env=env,
        )
        assert result.returncode == 0
        assert "Git Workflow" in result.stdout

    def test_cli_tool(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "tool", "--tool", "Bash"],
            capture_output=True, text=True, env=env,
        )
        assert result.returncode == 0
        assert "Shell Best Practices" in result.stdout

    def test_cli_fail_open(self, tmp_path):
        """Bad lesson dir still exits 0 with empty output."""
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(tmp_path / "nonexistent")
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "session-start"],
            capture_output=True, text=True, env=env,
        )
        assert result.returncode == 0
        assert result.stdout.strip() == ""


# ===========================================================================
# Hook simulation tests
# ===========================================================================

class TestHookSimulation:
    def _wrap_as_hook_json(self, event_name, additional_context):
        """Simulate what a hook script would produce."""
        if not additional_context.strip():
            return None
        return {
            "hookSpecificOutput": {
                "hookEventName": event_name,
                "additionalContext": additional_context,
            }
        }

    def test_hook_session_start_json(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "session-start"],
            capture_output=True, text=True, env=env,
        )
        context = result.stdout.strip()
        assert context  # non-empty
        hook_json = self._wrap_as_hook_json("SessionStart", context)
        assert hook_json is not None
        assert "additionalContext" in hook_json["hookSpecificOutput"]
        assert "Always Active Guardrail" in hook_json["hookSpecificOutput"]["additionalContext"]

    def test_hook_prompt_json(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "prompt", "--text", "git"],
            capture_output=True, text=True, env=env,
        )
        context = result.stdout.strip()
        assert context
        hook_json = self._wrap_as_hook_json("UserPromptSubmit", context)
        assert hook_json is not None
        assert "additionalContext" in hook_json["hookSpecificOutput"]

    def test_hook_tool_json(self, lesson_dir):
        env = os.environ.copy()
        env["LESSON_DIRS"] = str(lesson_dir)
        result = subprocess.run(
            [sys.executable, str(MATCHER), "--mode", "tool", "--tool", "Bash"],
            capture_output=True, text=True, env=env,
        )
        context = result.stdout.strip()
        assert context
        hook_json = self._wrap_as_hook_json("PreToolUse", context)
        assert hook_json is not None
        assert "Shell Best Practices" in hook_json["hookSpecificOutput"]["additionalContext"]
