#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import argparse, json, sys
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
        parser = argparse.ArgumentParser()
        parser.add_argument("--chat", action="store_true", help="Copy transcript to logs/chat.json")
        args = parser.parse_args()

        input_data = json.load(sys.stdin)

        session_id = input_data.get("session_id", "unknown")
        log_dir = get_runtime_dir(session_id)
        append_log(log_dir / "stop.json", input_data)

        if args.chat and "transcript_path" in input_data:
            tp = Path(input_data["transcript_path"])
            if tp.exists():
                chat_data = []
                for line in tp.read_text().splitlines():
                    line = line.strip()
                    if line:
                        try:
                            chat_data.append(json.loads(line))
                        except json.JSONDecodeError:
                            pass
                (log_dir / "chat.json").write_text(json.dumps(chat_data, indent=2))
    except Exception:
        pass
    sys.exit(0)


if __name__ == "__main__":
    main()
