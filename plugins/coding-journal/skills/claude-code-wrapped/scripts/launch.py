#!/usr/bin/env python3
"""Launcher for Claude Code Wrapped.

Decides where the slideshow should run based on the calling environment:
  - real terminal      → exec wrapped.py in place
  - agent / piped      → spawn a new Terminal window, exit cleanly
  - SSH / headless     → exec wrapped.py inline (caller sees output)

Always invoked instead of wrapped.py directly. wrapped.py is the renderer;
this script is the dispatcher.
"""

import os
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

WRAPPED = Path(__file__).resolve().parent / "wrapped.py"
PLUGIN_ROOT = WRAPPED.parent.parent  # scripts/ → plugin root
DEFAULT_CACHE = PLUGIN_ROOT / ".uv-cache"
SPAWN_FLAG = "--spawned"
SPAWN_WINDOW_ENV = "CLAUDE_WRAPPED_SPAWN_WINDOW"


def host_environment() -> str:
    """Returns one of: 'terminal', 'iterm', 'cursor', 'vscode', 'jetbrains',
       'tmux', 'ssh', 'agent', 'unknown'."""

    # Agent contexts (no TTY, piped stdout)
    if not sys.stdout.isatty():
        return "agent"

    # SSH session
    if os.environ.get("SSH_CONNECTION") or os.environ.get("SSH_TTY"):
        return "ssh"

    # tmux/screen
    if os.environ.get("TMUX") or os.environ.get("STY"):
        return "tmux"

    # Editor-integrated terminals (TERM_PROGRAM is the most reliable signal)
    term_program = os.environ.get("TERM_PROGRAM", "")
    if term_program == "vscode":
        # Both VS Code and Cursor identify as "vscode" via this var
        # Use the more specific check:
        if "Cursor" in os.environ.get("VSCODE_GIT_ASKPASS_NODE", "") or \
           "Cursor" in os.environ.get("__CFBundleIdentifier", ""):
            return "cursor"
        return "vscode"
    if term_program == "iTerm.app":
        return "iterm"
    if term_program == "Apple_Terminal":
        return "terminal"
    if "JetBrains" in term_program or "IntelliJ" in term_program:
        return "jetbrains"

    return "unknown"


def can_spawn_window() -> bool:
    """Can we open a new visible terminal window on this OS?"""
    if sys.platform == "darwin":
        return shutil.which("osascript") is not None
    if sys.platform.startswith("linux"):
        if not (os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY")):
            return False
        return any(
            shutil.which(t)
            for t in ("gnome-terminal", "konsole", "xterm", "kitty", "alacritty")
        )
    return False


def build_command() -> str:
    """The command the new terminal window will run."""
    runner = ["uv", "run"] if shutil.which("uv") else [sys.executable]
    return shlex.join([*runner, str(WRAPPED), SPAWN_FLAG])


def _applescript_string(s: str) -> str:
    """Escape a Python string for use inside an AppleScript string literal."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def spawn_macos(cmd: str) -> bool:
    osa = f'''
    tell application "Terminal"
        activate
        do script "{_applescript_string(cmd)}"
    end tell
    '''
    try:
        result = subprocess.run(
            ["osascript", "-e", osa],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=5,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    return result.returncode == 0


def spawn_linux(cmd: str) -> bool:
    for term, args in [
        ("gnome-terminal", ["--", "sh", "-c", cmd]),
        ("konsole",        ["-e", "sh", "-c", cmd]),
        ("kitty",          ["sh", "-c", cmd]),
        ("alacritty",      ["-e", "sh", "-c", cmd]),
        ("xterm",          ["-e", cmd]),
    ]:
        if shutil.which(term):
            try:
                subprocess.Popen(
                    [term, *args],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return True
            except OSError:
                continue
    return False


def run_inline() -> None:
    """Replace this process with wrapped.py. No subprocess overhead."""
    runner = ["uv", "run"] if shutil.which("uv") else [sys.executable]
    os.execvp(runner[0], [*runner, str(WRAPPED), SPAWN_FLAG])


def main() -> None:
    os.environ.setdefault("UV_CACHE_DIR", str(DEFAULT_CACHE))
    if SPAWN_FLAG in sys.argv:
        run_inline()
        return

    host = host_environment()

    # Hosts where running inline is the right thing:
    # - real TTY in Terminal.app / iTerm: just render here
    # - integrated editor terminals: render in the pane, user expects this
    # - tmux/screen: definitely don't spawn a separate window
    # - ssh: can't spawn windows, render inline
    if host in ("terminal", "iterm", "vscode", "cursor", "jetbrains", "tmux", "ssh"):
        run_inline()
        return

    # Agent/API sessions print all slides and exit by default. Spawning a
    # separate terminal is opt-in only.
    if host == "agent":
        if os.environ.get(SPAWN_WINDOW_ENV) == "1" and can_spawn_window():
            cmd = build_command()
            spawned = False
            if sys.platform == "darwin":
                spawned = spawn_macos(cmd)
            elif sys.platform.startswith("linux"):
                spawned = spawn_linux(cmd)
            if spawned:
                print("Opening Claude Code Wrapped in a new terminal window.")
                sys.exit(0)
        run_inline()
        return

    # Headless / unknown: dump slides inline.
    run_inline()


if __name__ == "__main__":
    main()
