#!/usr/bin/env bash
#
# Handle the bare $project-continuity plugin prompt.
#
# UserPromptSubmit hooks cannot rewrite a prompt into a true host
# slash-command invocation, so the exact bare plugin prompt injects
# equivalent instructions as additional context and lets the model
# continue. A one-shot sentinel is dropped so block-model-skill.sh
# allows the subsequent log-session-summary Skill call.

set -uo pipefail

TARGET='$project-continuity'
REPLACEMENT='$project-continuity:log-session-summary'
ADDITIONAL_CONTEXT='The user submitted exactly `$project-continuity`.

Treat this as an explicit invocation of `$project-continuity:log-session-summary`.
Do not ask the user to rerun a slash command. Invoke the `project-continuity:log-session-summary` Skill tool now and complete its workflow.
'

input="$(cat)"

prompt="$(printf '%s' "$input" | jq -r '.prompt // "" | gsub("^\\s+|\\s+$"; "")' 2>/dev/null || true)"

if [ "$prompt" != "$TARGET" ]; then
  echo '{}'
  exit 0
fi

session_id="$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null || true)"
if [ -n "$session_id" ]; then
  safe_session="${session_id//[^A-Za-z0-9_.-]/_}"
  sentinel_dir="${TMPDIR:-/tmp}/project-continuity-hooks"
  mkdir -p "$sentinel_dir"
  chmod 700 "$sentinel_dir" 2>/dev/null || true
  sentinel="$sentinel_dir/$safe_session.allow-log-session-summary"
  printf '%s' "$REPLACEMENT" > "$sentinel"
  chmod 600 "$sentinel"
fi

jq -nc \
  --arg context "$ADDITIONAL_CONTEXT" \
  --arg title "$REPLACEMENT" \
  '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $context,
      sessionTitle: $title
    }
  }'
