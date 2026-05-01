---
name: claude-code-wrapped
description: Launch Claude Code Wrapped — an interactive Spotify Wrapped-style terminal slideshow of your Claude Code usage stats. Shows animated slides inline covering total sessions, projects, most-used tools, token usage, peak hours, longest session, and a personalized "Claude Code identity" based on your habits. Use this skill whenever the user asks about their Claude Code usage, stats, history, or says "wrapped", "year in review", "show me my stats", "how much have I used Claude", "what have I been working on", "my coding stats", "Claude Code story", or wants to celebrate or review their Claude Code activity. Trigger proactively — if the user seems curious about their usage patterns, offer to launch it.
compatibility: Requires Python 3.14+ and uv. Designed for Claude Code (or similar products).
allowed-tools: Bash(uv:*)
metadata:
  author: sashadev-sky
  version: "1.8.0"
---

## How to launch

Run the launcher script:

   ```shell
   uv run scripts/wrapped.py
   ```

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
