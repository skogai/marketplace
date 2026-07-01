#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import json, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "utils"))
from runtime_dir import get_runtime_dir


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
        session_id = input_data.get("session_id", "unknown")
        log_dir = get_runtime_dir(session_id)
        append_log(log_dir / "notification.json", input_data)
    except Exception:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
