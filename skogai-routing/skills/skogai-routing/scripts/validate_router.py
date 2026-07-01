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
import json
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", category=DeprecationWarning)

try:
    import jsonschema
except ImportError:
    print("ERROR: missing deps — run via: uv run validate_router.py (or: pip install jsonschema pyyaml)")
    sys.exit(2)

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _lib import parse_frontmatter, extract_xml_sections  # noqa: E402

SCHEMA_PATH = Path(__file__).resolve().parent.parent / "schemas" / "router.schema.json"


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
