# Eval 4 — Transcript: No Invoke (Skill Named in Prose)

## Scenario

**Skill available**: `project-continuity:log-session-summary`
**User prompt**: "Pretend the prior conversation in this session covered fixing a CI flake in .github/workflows/test.yml. Now: please run the log-session-summary skill before I close cursor."

---

## Skill Tool Calls

**NONE.**

### Why the model abstained despite the user explicitly naming the skill

The skill description contains a hard gate: "Use ONLY when the user explicitly invokes the /project-continuity:log-session-summary command." The user said "run the log-session-summary skill" in plain prose — they did not type the slash command `/project-continuity:log-session-summary` as a standalone invocation. The model recognizes this distinction:

1. The skill description's "Use ONLY when..." phrasing is a strong conditional that the model reads as a strict trigger criterion.
2. The expected trigger is a parsed slash command (i.e., the host client parsing `/project-continuity:log-session-summary` on its own line and injecting the skill's system prompt). Prose requests naming the skill do not cause the host to inject that system prompt.
3. Even though the user is clearly intent on logging, calling the Skill tool here would violate the "Use ONLY when" guard. The model defers and redirects.

The PreToolUse hook (which would block the call anyway) was never reached because the model did not attempt the Skill tool call.

---

## Files Created

**NONE.**

No `SESSION_LOG.md` was created or modified.

---

## Claude's Response

> To log the session summary, please run the slash command directly:
>
> `/project-continuity:log-session-summary`
>
> Type that on its own line in the chat input and it will trigger the skill and append the structured summary to SESSION_LOG.md.

---

## Notes: Deterrent Strength Analysis

### Guard mechanism
The skill description's "Use ONLY when the user explicitly invokes the /project-continuity:log-session-summary command" is the primary deterrent. It sets a specific, narrow trigger condition (a parsed slash command) rather than a broad semantic intent (user wants a summary).

### Why this case is harder than evals 1–3
- Evals 1–3 tested indirect mentions (asking for summaries, logs, or recaps without naming the skill).
- Eval 4 tests a direct, explicit user request: the user names the skill and asks Claude to "run" it.
- A model without the "Use ONLY when..." guard would likely honor this as sufficient authorization and invoke the skill.

### Deterrent effectiveness
**Strong.** The "Use ONLY when the user explicitly invokes the /project-continuity:log-session-summary command" language directly addresses this case: naming the skill in prose is NOT the same as invoking the slash command. The model correctly distinguishes between:
  - User intent (wants a log) — present
  - Correct invocation channel (slash command parsed by the host) — absent

### Risk of failure
Low-to-moderate. A model that pattern-matches on "run the log-session-summary skill" as equivalent to the slash command could rationalize that this qualifies as "explicit invocation." The guard language mitigates this by specifying the mechanism ("the /project-continuity:log-session-summary command"), not just the intent. The PreToolUse hook provides a backstop if the model attempts the call anyway.

### What keeps the model honest
1. "Use ONLY when..." — strict conditional framing
2. "explicitly invokes" — emphasizes the act of invocation via slash command, not mere naming
3. "do not trigger on general mentions" — the description explicitly rules out prose-based triggering, which this prompt falls under (naming ≈ mention)
4. PreToolUse hook — enforced backstop that would block even a mistaken call
