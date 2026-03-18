#!/usr/bin/env bash
# MAGI Plugin Size Governance Check
# Run before committing changes to plugins/magi/

set -euo pipefail

PLUGIN_DIR="plugins/magi/skills/magi"
ERRORS=0

check_file() {
  local file="$1"
  local max="$2"
  local label="$3"

  if [ ! -f "$file" ]; then
    return
  fi

  local lines
  lines=$(wc -l < "$file")
  local pct=$((lines * 100 / max))

  if [ "$lines" -gt "$max" ]; then
    echo "FAIL  $label: $lines/$max lines (${pct}%) — OVER LIMIT"
    ERRORS=$((ERRORS + 1))
  elif [ "$pct" -ge 80 ]; then
    echo "WARN  $label: $lines/$max lines (${pct}%) — approaching limit"
  else
    echo "  OK  $label: $lines/$max lines (${pct}%)"
  fi
}

echo "━━━ MAGI Plugin Size Check ━━━"
echo ""

# SKILL.md
check_file "$PLUGIN_DIR/SKILL.md" 500 "SKILL.md (orchestrator)"

# Meta-agent (MAGI Core)
check_file "$PLUGIN_DIR/agents/magi-core.md" 160 "magi-core.md (meta-agent)"

# Persona agent files
for agent in "$PLUGIN_DIR"/agents/*.md; do
  [ "$(basename "$agent")" = "magi-core.md" ] && continue
  check_file "$agent" 130 "$(basename "$agent") (persona agent)"
done

# Reference files
for ref in "$PLUGIN_DIR"/references/*.md; do
  check_file "$ref" 100 "$(basename "$ref") (reference)"
done

# Example files
for ex in "$PLUGIN_DIR"/examples/*.md; do
  check_file "$ex" 100 "$(basename "$ex") (example)"
done

echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo "RESULT: $ERRORS file(s) over limit. See governance.md for split strategies."
  exit 1
else
  echo "RESULT: All files within limits."
  exit 0
fi
