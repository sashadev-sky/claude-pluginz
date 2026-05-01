---
name: claude-code-wrapped
description: Launch Claude Code Wrapped — an interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats. Opens a new terminal window showing animated slides covering total sessions, projects, most-used tools, token usage, peak hours, longest session, and a personalized "Claude Code identity" based on your habits. Use this skill whenever the user asks about their Claude Code usage, stats, history, or says "wrapped", "year in review", "show me my stats", "how much have I used Claude", "what have I been working on", "my coding stats", "Claude Code story", or wants to celebrate or review their Claude Code activity. Trigger proactively — if the user seems curious about their usage patterns, offer to launch it.
compatibility: Requires uv (https://docs.astral.sh/uv/). Reads ~/.claude/ for session transcripts and the stats cache. Launches in a new terminal window on macOS (Terminal.app) and Linux (gnome-terminal, konsole, xterm). Falls back to inline if no GUI terminal is available.
metadata:
  author: sashadev-sky
  version: "1.6.0"
---

## How to launch

1. Run the slideshow script directly using the plugin root path:

   ```bash
   uv run "${CLAUDE_PLUGIN_ROOT}scripts/wrapped.py
   ```

   `${CLAUDE_PLUGIN_ROOT}` is set automatically by Claude Code and resolves to the plugin's installed location. Using it (instead of an absolute `~/.claude/plugins/...` path) avoids tripping the auto-mode permission classifier.

2. The script launches the slideshow in a new terminal window and prints a confirmation.
3. Tell the user: "Opening Claude Code Wrapped in a new terminal window! Press any key to advance through the slides, or Q to quit."

On headless or SSH sessions the slideshow runs inline automatically.

## What the user sees

Slides advance on any keypress (Q or Esc to quit):

| Slide | Content |
| ----- | ------- |
| Opening | Total sessions + messages |
| Projects | Number of projects worked across |
| Sessions | Session count + weekly average |
| Top project | Most-visited project + session count |
| Tools | #1 tool + top 3 breakdown |
| Tokens | Total tokens generated + cache savings % |
| Peak hour | Most active hour of the day |
| Longest session | Record message count + duration |
| Origin story | First session date + days since |
| Identity | Personalized title based on usage patterns |
| Closing | Sign-off |

## Data sources

- `~/.claude/stats-cache.json` — pre-aggregated totals (sessions, tokens, model usage, hourly patterns)
- `~/.claude/projects/**/*.jsonl` — session transcripts scanned for tool call counts and file edits

## Permissions

To pre-approve the launch command without user prompts, ship a `.claude-plugin/settings.json` with:

```json
{
  "permissions": {
    "allow": [
      "Bash(uv run ${CLAUDE_PLUGIN_ROOT}/scripts/wrapped.py)"
    ]
  }
}
