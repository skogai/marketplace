#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import json, sys
from pathlib import Path
from datetime import datetime


def append_log(path: Path, entry: dict) -> None:
    try:
        data = json.loads(path.read_text()) if path.exists() else []
    except (json.JSONDecodeError, ValueError):
        data = []
    if not isinstance(data, list):
        data = []
    data.append(entry)
    path.write_text(json.dumps(data, indent=2))


def main():
    try:
        input_data = json.load(sys.stdin)
        input_data["logged_at"] = datetime.now().isoformat()
        log_dir = Path("logs")
        log_dir.mkdir(parents=True, exist_ok=True)
        append_log(log_dir / "subagent_start.json", input_data)
    except Exception:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
