#!/usr/bin/env bash
#
# Block model-initiated invocations of a named skill.
#
# This is intentionally agent/model-agnostic: it depends only on POSIX
# shell + jq and the convention that the hook event JSON exposes
# .tool_name and .tool_input.skill on stdin, and that the host respects
# a `{ hookSpecificOutput: { permissionDecision: "deny" } }` reply for
# its PreToolUse-equivalent event.
#
# User-driven invocations (slash commands like /<plugin>:<skill>) do not
# flow through the generic Skill tool path, so they are not affected by
# this hook.
#
# Usage: block-model-skill.sh <skill_name>

set -euo pipefail

target_skill="${1:?skill name required}"

input="$(cat)"
session_id="$(printf '%s' "$input" | jq -r '.session_id // empty')"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
skill="$(printf '%s' "$input" | jq -r '.tool_input.skill // empty')"

skill="${skill##*:}"

if [ "$tool_name" = "Skill" ] && [ "$skill" = "$target_skill" ]; then
  if [ -n "$session_id" ]; then
    safe_session="${session_id//[^A-Za-z0-9_.-]/_}"
    sentinel_dir="${TMPDIR:-/tmp}/project-continuity-hooks"
    sentinel="${sentinel_dir}/${safe_session}.allow-log-session-summary"
    if [ -f "$sentinel" ]; then
      rm -f "$sentinel"
      jq -nc \
        '{
          hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "allow",
            permissionDecisionReason: "Allowed one log-session-summary invocation requested by the exact bare $project-continuity prompt."
          }
        }'
      exit 0
    fi
  fi

  jq -nc \
    --arg skill "$target_skill" \
    '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: ("Policy: the \"" + $skill + "\" skill is reserved for explicit user invocation via its slash command, parsed by the host as a slash command (not as text in a prompt). Do NOT work around this block: do not read its SKILL.md or scripts in order to replay them, and do not yourself create, write, append to, or modify any session-log artifact (e.g., SESSION_LOG.md). Stop the current action. If a session log is wanted, respond with a single sentence telling the user to invoke the slash command on its own line; do not produce the summary content.")
      }
    }'
  exit 0
fi

echo '{}'
exit 0
