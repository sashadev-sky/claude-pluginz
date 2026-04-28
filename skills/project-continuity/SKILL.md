---
name: log-session-summary
description: Append a structured summary of the current session to SESSION_LOG.md
metadata:
  author: sashadev-sky
  version: "1.2.0"
disable-model-invocation: true
---

When invoked, review the conversation and create a summary with these sections:

- **Date/time**: Current timestamp
- **Tasks completed**: What was accomplished
- **Files modified**: List of files created or changed
- **Decisions made**: Architectural or implementation choices
- **Open questions**: Unresolved items for future sessions

Append the summary to SESSION_LOG.md in the project root. Create the file if it doesn't exist.
