#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import os
import tempfile
from pathlib import Path


def get_runtime_dir(session_id: str) -> Path:
    """<tmp_base>/skoghooks/<session_id>/, created if missing."""
    tmp_base = os.environ.get("CLAUDE_CODE_TMPDIR") or tempfile.gettempdir()
    runtime_dir = Path(tmp_base) / "skoghooks" / (session_id or "unknown")
    runtime_dir.mkdir(parents=True, exist_ok=True)
    return runtime_dir
