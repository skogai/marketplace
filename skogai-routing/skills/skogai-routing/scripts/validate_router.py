#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "jsonschema>=4.0",
#   "pyyaml>=6.0",
# ]
# ///
"""
Validate routing file(s) (type: router) against router.schema.json.

Usage: validate_router.py <file> [file...]
Exits 0 if all files passed or warned, 1 if any failed. Prints one
PASS/FAIL/WARN line per file (+ details on FAIL).
"""

import sys
import re
import json
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", category=DeprecationWarning)

try:
    import yaml
    import jsonschema
except ImportError:
    print("ERROR: missing deps — run via: uv run validate_router.py (or: pip install jsonschema pyyaml)")
    sys.exit(2)

SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schemas" / "router.schema.json"


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return None
    return yaml.safe_load(m.group(1))


def extract_xml_sections(text):
    sections = []
    seen = set()
    for m in re.finditer(r"<([a-z][a-z0-9_]*)(?:\s[^>]*)?>", text):
        name = m.group(1)
        if name in seen:
            continue
        close = re.search(rf"</{re.escape(name)}>", text[m.end():])
        content = text[m.end():m.end() + close.start()].strip() if close else ""
        sections.append({"kind": "xml", "name": name, "content": content})
        seen.add(name)
    return sections


def validate_file(path, schema):
    raw = path.read_text()
    fm = parse_frontmatter(raw)

    if fm is None:
        print(f"WARN  {path.name}: no frontmatter found — skipping")
        return 0

    doc_type = fm.get("type")
    if doc_type != "router":
        print(f"WARN  {path.name}: frontmatter type is '{doc_type}', not 'router' — skipping")
        return 0

    sections = extract_xml_sections(raw)
    doc = {"type": doc_type, "frontmatter": fm, "sections": sections}

    validator = jsonschema.Draft202012Validator(schema)
    errors = sorted(validator.iter_errors(doc), key=lambda e: list(e.path))

    if errors:
        print(f"FAIL  {path.name}")
        for err in errors:
            err_path = " > ".join(str(p) for p in err.path) or "(root)"
            print(f"      {err_path}: {err.message}")
        return 1

    print(f"PASS  {path.name}")
    return 0


def main():
    if len(sys.argv) < 2:
        print("Usage: validate_router.py <file> [file...]", file=sys.stderr)
        sys.exit(1)

    schema = json.loads(SCHEMA_PATH.read_text())
    fail = 0
    for arg in sys.argv[1:]:
        if validate_file(Path(arg).resolve(), schema):
            fail = 1
    sys.exit(fail)


if __name__ == "__main__":
    main()
