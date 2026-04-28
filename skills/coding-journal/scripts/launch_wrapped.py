#!/usr/bin/env python3

import platform
import subprocess
import sys
from pathlib import Path


def main() -> None:
    script = Path(__file__).resolve().parent / "wrapped.py"
    system = platform.system()

    if system == "Windows":
        subprocess.Popen(
            [sys.executable, str(script)],
            creationflags=subprocess.CREATE_NEW_CONSOLE,
        )
        return

    if system == "Darwin":
        subprocess.Popen(
            [
                "osascript",
                "-e",
                (
                    'tell application "Terminal" to do script '
                    f'"{sys.executable} {script}"'
                ),
            ]
        )
        return

    subprocess.Popen([sys.executable, str(script)])


if __name__ == "__main__":
    main()
