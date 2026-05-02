---
name: claude-code-wrapped
description: Launch Claude Code Wrapped — an interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats. For Codex, invoke this skill only as $coding-journal:claude-code-wrapped; $coding-journal alone is not a valid invocation. Shows animated slides inline covering total sessions, projects, most-used tools, token usage, peak hours, longest session, and a personalized "Claude Code identity" based on your habits. Use this skill whenever the user asks about their Claude Code usage, stats, history, or says "wrapped", "year in review", "show me my stats", "how much have I used Claude", "what have I been working on", "my coding stats", "Claude Code story", or wants to celebrate or review their Claude Code activity. Trigger proactively — if the user seems curious about their usage patterns, offer to launch it.
compatibility: Requires Python 3.14+ and uv. Designed for Claude Code (or similar products).
allowed-tools: Bash
---

## How to launch

  Run the launcher script from this skill directory (`skills/claude-code-wrapped`):

  ```shell
  CLAUDE_WRAPPED_SPAWN_WINDOW=1 uv run scripts/launch.py
  ```

  If your current working directory is the plugin root instead, run the
  compatibility launcher:

  ```shell
  CLAUDE_WRAPPED_SPAWN_WINDOW=1 uv run scripts/launch.py
  ```

  Run this as a normal foreground command without opening a managed PTY
  session. The launcher opens the wrapped slideshow in a separate terminal
  window and then exits. The user advances slides with SPACE or ENTER in
  that separate terminal window; Codex should not send keystrokes to a
  background terminal session.

## What the user sees

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
