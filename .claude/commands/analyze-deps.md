---
description: Analyze dependencies for outdated packages
argument-hint: [args...]
---

# /analyze-deps

## Purpose
Analyze dependencies for outdated packages

## Contract
**Inputs:** `[package-manager]` — optional: npm, yarn, pip, etc. (auto-detected if omitted)
**Outputs:** `STATUS=<OK|FAIL> [key=value ...]`

## Instructions

1. **Validate inputs:**
   - If a package manager is specified, verify it is supported (npm, yarn, pnpm, pip, cargo, go)
   - If omitted, detect from project files (package.json, requirements.txt, Cargo.toml, go.mod)

2. **Execute the command:**

```bash
# Detect and run the appropriate outdated check
if [ -f package.json ]; then
  npm outdated --json 2>/dev/null || yarn outdated 2>/dev/null || pnpm outdated 2>/dev/null
elif [ -f requirements.txt ]; then
  pip list --outdated 2>/dev/null
elif [ -f Cargo.toml ]; then
  cargo outdated 2>/dev/null
elif [ -f go.mod ]; then
  go list -u -m all 2>/dev/null
fi
```

3. **Output status:**
   - Print `STATUS=OK OUTDATED=<count>` on success
   - Print `STATUS=FAIL ERROR="message"` on failure

## Constraints
- Idempotent and deterministic
- No network tools by default
- Minimal console output (STATUS line only)
