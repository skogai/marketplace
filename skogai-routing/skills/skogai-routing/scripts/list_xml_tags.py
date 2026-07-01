#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "pyyaml>=6.0",
# ]
# ///
"""
Find router files under a directory and print the XML tags each one contains.

Usage: list_xml_tags.py [root_dir] [-o output_file]

For every *.md file under root_dir with frontmatter `type: router` (same
discovery as list_routers.py — .git/node_modules skipped), prints:

    <relative-path>: <tag1> <tag2> ...

one line per file, tags in first-appearance order. Files with no XML tags
print "(no xml tags)". With -o, also writes the same lines to a file.
"""

import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", category=DeprecationWarning)

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _lib import parse_frontmatter, is_router, extract_xml_tags  # noqa: E402

SKIP_DIRS = {".git", "node_modules"}


def find_router_files(root):
    for path in sorted(root.rglob("*.md")):
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        try:
            raw = path.read_text()
        except (UnicodeDecodeError, OSError):
            continue
        if is_router(parse_frontmatter(raw)):
            yield path, raw


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

    lines = []
    for path, raw in find_router_files(root):
        tags = extract_xml_tags(raw)
        rel = path.relative_to(root)
        lines.append(f"{rel}: {' '.join(tags) if tags else '(no xml tags)'}")

    for line in lines:
        print(line)

    if output_file:
        Path(output_file).write_text("\n".join(lines) + ("\n" if lines else ""))
        print(f"\n({len(lines)} router file(s) written to {output_file})", file=sys.stderr)


if __name__ == "__main__":
    main()
