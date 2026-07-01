#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "jsonschema>=4.0",
#   "pyyaml>=6.0",
# ]
# ///
"""
Validate a single routing file (type: router) against router.schema.json.
Adapted from the older skogai-routing _validate_file.py, scoped to the one
document type this skill implements today.

Usage: _validate_router.py <schema_dir> <file>
Exits 0 on pass or warn, 1 on fail. Prints one PASS/FAIL/WARN line + details.
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
    print("ERROR: missing deps — run via: uv run _validate_router.py (or: pip install jsonschema pyyaml)")
    sys.exit(2)

SCHEMA_DIR = Path(sys.argv[1]).resolve()
FILE = Path(sys.argv[2]).resolve()


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


raw = FILE.read_text()
fm = parse_frontmatter(raw)

if fm is None:
    print(f"WARN  {FILE.name}: no frontmatter found — skipping")
    sys.exit(0)

doc_type = fm.get("type")
if doc_type != "router":
    print(f"WARN  {FILE.name}: frontmatter type is '{doc_type}', not 'router' — skipping")
    sys.exit(0)

sections = extract_xml_sections(raw)
doc = {"type": doc_type, "frontmatter": fm, "sections": sections}

schema = json.loads((SCHEMA_DIR / "router.schema.json").read_text())
validator = jsonschema.Draft202012Validator(schema)
errors = sorted(validator.iter_errors(doc), key=lambda e: list(e.path))

if errors:
    print(f"FAIL  {FILE.name}")
    for err in errors:
        path = " > ".join(str(p) for p in err.path) or "(root)"
        print(f"      {path}: {err.message}")
    sys.exit(1)

print(f"PASS  {FILE.name}")
sys.exit(0)
