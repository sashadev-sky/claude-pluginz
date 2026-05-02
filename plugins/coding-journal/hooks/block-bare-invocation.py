#!/usr/bin/env python3
"""Handle the bare coding-journal plugin prompt.

The runnable workflow is the bundled claude-code-wrapped skill, not the plugin
container. Codex UserPromptSubmit hooks cannot rewrite the prompt, so this hook
calls the replacement workflow directly and then stops the ambiguous bare
invocation from reaching the model.
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple


TARGET = "$coding-journal"
REPLACEMENT = "$coding-journal:claude-code-wrapped"
SKILL_ROOT = Path(__file__).resolve().parent.parent / "skills" / "claude-code-wrapped"
LAUNCHER = SKILL_ROOT / "scripts" / "launch.py"
SPAWN_WINDOW_ENV = "CLAUDE_WRAPPED_SPAWN_WINDOW"
DEFAULT_UV_CACHE = SKILL_ROOT / ".uv-cache"


def call_replacement() -> Tuple[bool, Optional[str]]:
    """Run the wrapped launcher while keeping hook stdout valid JSON."""
    runner = ["uv", "run"] if shutil.which("uv") else [sys.executable]
    env = os.environ.copy()
    env[SPAWN_WINDOW_ENV] = "1"
    env.setdefault("UV_CACHE_DIR", str(DEFAULT_UV_CACHE))

    try:
        result = subprocess.run(
            [*runner, str(LAUNCHER)],
            cwd=SKILL_ROOT,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=30,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        return False, str(exc)

    if result.returncode != 0:
        error = result.stderr.strip() or result.stdout.strip()
        return False, error or f"launcher exited with status {result.returncode}"

    return True, None


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("{}")
        return 0

    prompt = event.get("prompt")
    if isinstance(prompt, str) and prompt.strip() == TARGET:
        ok, error = call_replacement()
        reason = f"Called {REPLACEMENT}."
        if not ok:
            reason = f"Could not call {REPLACEMENT}: {error}"
        print(
            json.dumps(
                {
                    "decision": "block",
                    "reason": reason,
                }
            )
        )
        return 0

    print("{}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
