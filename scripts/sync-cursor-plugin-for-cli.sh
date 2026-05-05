#!/usr/bin/env bash
#
# Fan plugin components out into the locations where the Cursor CLI
# (`cursor-agent`) actually discovers them. Empirically verified: cursor-agent
# does not load components from `.cursor/plugins/local/` — it only sees
# `.cursor/skills/<skill>/SKILL.md`, `.cursor/rules/*.mdc`, and
# `.cursor/mcp.json`. The IDE's plugin loader is separate.
#
# This script writes into the project's own `.cursor/` directory (workspace
# scope), so the synced skills/rules are only active when running cursor-agent
# from inside this repo.
#
# This script:
#   1. Iterates every plugin under $REPO/plugins/.
#   2. Copies each `<plugin>/skills/<skill>/` (must contain SKILL.md) into
#      `$REPO/.cursor/skills/<skill>/` (one level deep, plugin wrapper stripped).
#   3. Copies each `<plugin>/rules/*` rule file into `$REPO/.cursor/rules/`,
#      prefixed with the plugin name to avoid collisions.
#   4. Warns about `mcp.json` and `hooks/` — those need manual handling.
#
# Idempotent: tracks every path it creates in a manifest so re-runs remove
# stale items first. Files outside the manifest are left untouched.
#
# Usage:
#   ./scripts/sync-cursor-plugin-for-cli.sh           # sync all plugins
#   ./scripts/sync-cursor-plugin-for-cli.sh <name>    # sync just plugins/<name>

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_ROOT="$PROJECT_DIR/plugins"
CURSOR_DEST_DIR="$PROJECT_DIR/.cursor"
SKILLS_DEST="$CURSOR_DEST_DIR/skills"
RULES_DEST="$CURSOR_DEST_DIR/rules"
MANIFEST="$CURSOR_DEST_DIR/.claude-plugins-cli-sync.manifest"

mkdir -p "$CURSOR_DEST_DIR"

# Remove anything we created on a previous run, then start a fresh manifest.
if [[ -f "$MANIFEST" ]]; then
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    rm -rf "$p"
  done < "$MANIFEST"
fi
: > "$MANIFEST"

record() { printf '%s\n' "$1" >> "$MANIFEST"; }

sync_skills() {
  local plugin_dir="$1"
  local plugin_name="$2"
  local skills_src="$plugin_dir/skills"

  [[ -d "$skills_src" ]] || return 0

  local skill_dir skill_name target
  for skill_dir in "$skills_src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"

    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
      echo "  skip:  skills/$skill_name (no SKILL.md)"
      continue
    fi

    mkdir -p "$SKILLS_DEST"
    target="$SKILLS_DEST/$skill_name"
    rm -rf "$target"
    rsync -a \
      --exclude '__pycache__' \
      --exclude '.DS_Store' \
      --exclude 'agents' \
      "$skill_dir" "$target/"
    record "$target"
    echo "  skill: $skill_name -> $target"
  done
}

sync_rules() {
  local plugin_dir="$1"
  local plugin_name="$2"
  local rules_src="$plugin_dir/rules"

  [[ -d "$rules_src" ]] || return 0

  shopt -s nullglob
  local rule rule_name target
  for rule in "$rules_src"/*.{md,mdc,markdown}; do
    [[ -f "$rule" ]] || continue
    rule_name="$(basename "$rule")"
    mkdir -p "$RULES_DEST"
    target="$RULES_DEST/${plugin_name}-${rule_name}"
    cp "$rule" "$target"
    record "$target"
    echo "  rule:  $rule_name -> $target"
  done
  shopt -u nullglob
}

warn_unsupported() {
  local plugin_dir="$1"

  if [[ -f "$plugin_dir/mcp.json" || -f "$plugin_dir/.mcp.json" ]]; then
    echo "  WARN:  mcp.json present — merge manually into $CURSOR_DEST_DIR/mcp.json"
  fi
  if [[ -d "$plugin_dir/hooks" ]]; then
    echo "  WARN:  hooks/ present — cursor-agent CLI hook support is unverified; skipping"
  fi
  if [[ -d "$plugin_dir/commands" ]]; then
    echo "  WARN:  commands/ present — CLI commands are not auto-discovered; skipping"
  fi
  if [[ -d "$plugin_dir/agents" ]]; then
    echo "  WARN:  agents/ present — CLI agent file support is unverified; skipping"
  fi
}

sync_plugin() {
  local plugin_dir="$1"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  echo "Plugin: $plugin_name"
  sync_skills "$plugin_dir" "$plugin_name"
  sync_rules "$plugin_dir" "$plugin_name"
  warn_unsupported "$plugin_dir"
}

# Resolve which plugins to sync.
declare -a PLUGINS=()
if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    candidate="$PLUGINS_ROOT/$arg"
    if [[ ! -d "$candidate" ]]; then
      echo "error: $candidate is not a plugin directory" >&2
      exit 1
    fi
    PLUGINS+=("$candidate")
  done
else
  for entry in "$PLUGINS_ROOT"/*/; do
    [[ -d "$entry" ]] && PLUGINS+=("${entry%/}")
  done
fi

if [[ ${#PLUGINS[@]} -eq 0 ]]; then
  echo "error: no plugins found under $PLUGINS_ROOT" >&2
  exit 1
fi

for plugin in "${PLUGINS[@]}"; do
  sync_plugin "$plugin"
done

echo
echo "Synced ${#PLUGINS[@]} plugin(s) into $CURSOR_DEST_DIR"
echo "Manifest: $MANIFEST"
