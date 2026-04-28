---
name: claude-code-wrapped
description: Launch Claude Code Wrapped — an interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats. Opens a new terminal window showing animated slides covering total sessions, projects, most-used tools, token usage, peak hours, longest session, and a personalized "Claude Code identity" based on your habits. Use this skill whenever the user asks about their Claude Code usage, stats, history, or says "wrapped", "year in review", "show me my stats", "how much have I used Claude", "what have I been working on", "my coding stats", "Claude Code story", or wants to celebrate or review their Claude Code activity. Trigger proactively — if the user seems curious about their usage patterns, offer to launch it.
compatibility: Requires uv (https://docs.astral.sh/uv/). Reads ~/.claude/ for session transcripts and the stats cache. Launches in a new terminal window on macOS (Terminal.app) and Linux (gnome-terminal, konsole, xterm). Falls back to inline if no GUI terminal is available.
metadata:
  author: sashadev-sky
  version: "1.4.0"
---

## How to launch

1. Find the absolute path of this SKILL.md and note its parent directory as `<skill_dir>`.
2. Run:

   ```bash
   uv run scripts/wrapped.py
   ```

3. The script launches the slideshow in a new terminal window and prints a confirmation.
4. Tell the user: "Opening Claude Code Wrapped in a new terminal window! Press any key to advance through the slides, or Q to quit."

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
