#!/usr/bin/env bash
#
# Handle the bare $coding-journal plugin prompt.
#
# The runnable workflow is the bundled claude-code-wrapped skill, not the
# plugin container. UserPromptSubmit hooks cannot rewrite the prompt, so
# this hook calls the replacement launcher directly and then blocks the
# ambiguous bare invocation from reaching the model.

set -uo pipefail

TARGET='$coding-journal'
REPLACEMENT='$coding-journal:claude-code-wrapped'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SKILL_ROOT="$PLUGIN_ROOT/skills/claude-code-wrapped"
LAUNCHER="$SKILL_ROOT/scripts/launch.py"

input="$(cat)"
prompt="$(printf '%s' "$input" | jq -r '.prompt // "" | gsub("^\\s+|\\s+$"; "")' 2>/dev/null || true)"

if [ "$prompt" != "$TARGET" ]; then
  echo '{}'
  exit 0
fi

if command -v uv >/dev/null 2>&1; then
  cmd=(uv run "$LAUNCHER")
else
  cmd=(python3 "$LAUNCHER")
fi

if command -v timeout >/dev/null 2>&1; then
  cmd=(timeout 30 "${cmd[@]}")
elif command -v gtimeout >/dev/null 2>&1; then
  cmd=(gtimeout 30 "${cmd[@]}")
elif command -v perl >/dev/null 2>&1; then
  cmd=(perl -e 'alarm shift; exec @ARGV' 30 "${cmd[@]}")
fi

stdout_file="$(mktemp)"
stderr_file="$(mktemp)"
trap 'rm -f "$stdout_file" "$stderr_file"' EXIT

export CLAUDE_WRAPPED_SPAWN_WINDOW=1
export UV_CACHE_DIR="${UV_CACHE_DIR:-$SKILL_ROOT/.uv-cache}"

( cd "$SKILL_ROOT" && "${cmd[@]}" ) >"$stdout_file" 2>"$stderr_file"
rc=$?

if [ "$rc" -eq 0 ]; then
  reason="Called $REPLACEMENT."
else
  err="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$stderr_file")"
  if [ -z "$err" ]; then
    err="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$stdout_file")"
  fi
  if [ -z "$err" ]; then
    err="launcher exited with status $rc"
  fi
  reason="Could not call $REPLACEMENT: $err"
fi

jq -nc --arg reason "$reason" '{ decision: "block", reason: $reason }'
