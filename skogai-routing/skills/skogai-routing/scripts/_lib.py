"""Shared frontmatter/XML parsing used by validate_router.py, list_routers.py,
and list_xml_tags.py. Not a standalone script — imported as a sibling module
(its directory is on sys.path automatically since these are run directly)."""

import re


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return None
    import yaml
    try:
        return yaml.safe_load(m.group(1))
    except Exception:
        return None


def is_router(fm):
    return bool(fm) and fm.get("type") == "router"


def extract_xml_tags(text):
    """Unique top-level XML tag names in the order they first appear."""
    tags = []
    seen = set()
    for m in re.finditer(r"</?([A-Za-z][A-Za-z0-9_-]*)[^>]*>", text):
        name = m.group(1)
        if name not in seen:
            tags.append(name)
            seen.add(name)
    return tags


def extract_xml_sections(text):
    """Root-level XML sections as {kind, name, content}, one per unique tag name."""
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
