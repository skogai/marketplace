#!/usr/bin/env python3
"""
Internal helper for validate-schema.sh.
Usage: _validate_file.py <schema_dir> <file>
Exits 0 on pass, 1 on fail. Prints structured findings to stdout.
"""

import sys
import json
import re
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
from pathlib import Path

try:
    import yaml
    import jsonschema
    from jsonschema import RefResolver
except ImportError:
    print("ERROR: missing deps — run: pip install jsonschema pyyaml --break-system-packages")
    sys.exit(2)

SCHEMA_DIR = Path(sys.argv[1]).resolve()
FILE = Path(sys.argv[2]).resolve()

TYPE_TO_SCHEMA = {
    "router":    "router.schema.json",
    "workflow":  "workflow.schema.json",
    "reference": "reference.schema.json",
    "template":  "template.schema.json",
    "script":    "script.schema.json",
    "lesson":    "lesson.schema.json",
}

def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return None
    return yaml.safe_load(m.group(1))

def extract_xml_sections(text):
    """Return list of xml section names present in the document body."""
    return re.findall(r"<([a-z][a-z0-9_]*)[\s>]", text)

def build_document(path, fm, raw):
    """Build a minimal document object for schema validation."""
    sections = []
    for name in dict.fromkeys(extract_xml_sections(raw)):  # deduplicated, order preserved
        sections.append({"kind": "xml", "name": name, "content": ""})

    headings = []
    for m in re.finditer(r"^(#{1,6})\s+(.+)$", raw, re.MULTILINE):
        headings.append({"level": len(m.group(1)), "title": m.group(2).strip()})

    doc = {
        "path": str(path),
        "type": fm.get("type", ""),
        "sections": sections,
    }
    if fm:
        doc["frontmatter"] = fm
    if headings:
        doc["headings"] = headings
    return doc

def load_schema(name):
    p = SCHEMA_DIR / name
    with open(p) as f:
        return json.load(f)

def make_resolver():
    store = {}
    for p in SCHEMA_DIR.glob("*.json"):
        s = json.loads(p.read_text())
        sid = s.get("$id", p.name)
        store[sid] = s
        store[p.name] = s
    base_uri = SCHEMA_DIR.as_uri() + "/"
    return RefResolver(base_uri=base_uri, referrer={}, store=store)

errors = []
warnings = []

raw = FILE.read_text()
fm = parse_frontmatter(raw)

XML_ROOT_TO_TYPE = {
    "workflow":  "workflow",
    "reference": "reference",
    "template":  "template",
    "script":    "script",
    "router":    "router",
    "lesson":    "lesson",
}

if fm is None:
    # fall back: infer type from first XML root tag
    m = re.match(r"^\s*<([a-z][a-z0-9_]*)[\s>]", raw)
    inferred = XML_ROOT_TO_TYPE.get(m.group(1)) if m else None
    if not inferred:
        warnings.append("no frontmatter and no recognised XML root tag — skipping")
        print(f"WARN  {FILE.name}: " + "; ".join(warnings))
        sys.exit(0)
    fm = {"type": inferred}

doc_type = fm.get("type")
if not doc_type:
    warnings.append("frontmatter missing 'type' field")
    print(f"WARN  {FILE.name}: " + "; ".join(warnings))
    sys.exit(0)

schema_name = TYPE_TO_SCHEMA.get(doc_type)
if not schema_name:
    warnings.append(f"no schema mapped for type '{doc_type}'")
    print(f"WARN  {FILE.name}: " + "; ".join(warnings))
    sys.exit(0)

schema = load_schema(schema_name)
resolver = make_resolver()
doc = build_document(FILE, fm, raw)

validator = jsonschema.Draft202012Validator(schema, resolver=resolver)
for err in sorted(validator.iter_errors(doc), key=lambda e: list(e.path)):
    path = " > ".join(str(p) for p in err.path) or "(root)"
    errors.append(f"{path}: {err.message}")

if errors:
    print(f"FAIL  {FILE.relative_to(FILE.parent.parent) if FILE.parent.name else FILE.name}")
    for e in errors:
        print(f"      {e}")
    sys.exit(1)
else:
    print(f"PASS  {FILE.name}")
    sys.exit(0)
