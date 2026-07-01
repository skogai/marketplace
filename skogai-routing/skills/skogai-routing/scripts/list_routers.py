#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "pyyaml>=6.0",
# ]
# ///
"""
Scan a directory tree for router files (markdown with frontmatter type: router).

Usage: list_routers.py [root_dir] [-o output_file]

Prints one path per line (relative to root_dir) for every .md file whose
frontmatter has `type: router`. Directories named .git or node_modules are
skipped. With -o, also writes the same list (newline-separated) to a file.
"""

import sys
import re
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", category=DeprecationWarning)

try:
    import yaml
except ImportError:
    print("ERROR: missing deps — run via: uv run list_routers.py (or: pip install pyyaml)")
    sys.exit(2)

SKIP_DIRS = {".git", "node_modules"}


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        return None
    try:
        return yaml.safe_load(m.group(1))
    except yaml.YAMLError:
        return None


def is_router(path):
    try:
        raw = path.read_text()
    except (UnicodeDecodeError, OSError):
        return False
    fm = parse_frontmatter(raw)
    return bool(fm) and fm.get("type") == "router"


def find_routers(root):
    for path in sorted(root.rglob("*.md")):
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        if is_router(path):
            yield path.relative_to(root)


def main():
    args = sys.argv[1:]
    output_file = None
    if "-o" in args:
        i = args.index("-o")
        output_file = args[i + 1]
        del args[i:i + 2]

    root = Path(args[0]).resolve() if args else Path.cwd()
    if not root.is_dir():
        print(f"Error: not a directory: {root}", file=sys.stderr)
        sys.exit(1)

    routers = list(find_routers(root))
    lines = [str(p) for p in routers]

    for line in lines:
        print(line)

    if output_file:
        Path(output_file).write_text("\n".join(lines) + ("\n" if lines else ""))
        print(f"\n({len(lines)} router file(s) written to {output_file})", file=sys.stderr)


if __name__ == "__main__":
    main()
