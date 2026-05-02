#!/usr/bin/env python3
"""Handle the bare project-continuity plugin prompt.

The runnable workflow is the bundled log-session-summary behavior, not the
plugin container. UserPromptSubmit hooks cannot rewrite a prompt into a true
host slash-command invocation, so the exact bare plugin prompt injects the
equivalent instructions as hook context and lets the model continue.
"""

import json
import os
import sys
import tempfile
from pathlib import Path


TARGET = "$project-continuity"
REPLACEMENT = "$project-continuity:log-session-summary"
ADDITIONAL_CONTEXT = """The user submitted exactly `$project-continuity`.

Treat this as an explicit invocation of `$project-continuity:log-session-summary`.
Do not ask the user to rerun a slash command. Invoke the `project-continuity:log-session-summary` Skill tool now and complete its workflow.
"""


def sentinel_path(session_id: str) -> Path:
    safe_session = "".join(
        char if char.isalnum() or char in "._-" else "_" for char in session_id
    )
    return Path(tempfile.gettempdir()) / "project-continuity-hooks" / (
        f"{safe_session}.allow-log-session-summary"
    )


def allow_next_skill_call(event: dict) -> None:
    session_id = event.get("session_id")
    if not isinstance(session_id, str) or not session_id:
        return

    path = sentinel_path(session_id)
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    with os.fdopen(os.open(path, flags, 0o600), "w", encoding="utf-8") as sentinel:
        sentinel.write(REPLACEMENT)


def main() -> int:
    try:
        event = json.load(sys.stdin)
    except json.JSONDecodeError:
        print("{}")
        return 0

    prompt = event.get("prompt")
    if isinstance(prompt, str) and prompt.strip() == TARGET:
        allow_next_skill_call(event)
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "UserPromptSubmit",
                        "additionalContext": ADDITIONAL_CONTEXT,
                        "sessionTitle": REPLACEMENT,
                    },
                }
            )
        )
        return 0

    print("{}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
