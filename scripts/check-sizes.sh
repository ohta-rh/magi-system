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
fi

# Governance verification: compare governance.md "Current" values with actual counts
GOVERNANCE="$PLUGIN_DIR/references/governance.md"
if [ -f "$GOVERNANCE" ]; then
  echo ""
  echo "━━━ Governance Current-Value Verification ━━━"
  echo ""
  GOV_WARNS=0

  verify_governance() {
    local file="$1"
    local label="$2"
    local gov_value="$3"

    if [ ! -f "$file" ]; then
      return
    fi

    local actual
    actual=$(wc -l < "$file" | tr -d ' ')

    if [ "$actual" != "$gov_value" ]; then
      echo "WARN  $label: governance.md says $gov_value, actual is $actual"
      GOV_WARNS=$((GOV_WARNS + 1))
    else
      echo "  OK  $label: governance.md matches ($actual)"
    fi
  }

  # Parse "Current" column values from governance.md table rows
  # Table format: | File Category | Max Lines | Current | Rationale |
  while IFS='|' read -r _ category _ current _; do
    # Trim whitespace
    category=$(echo "$category" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    current=$(echo "$current" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip header/separator rows
    [ -z "$current" ] && continue
    echo "$current" | grep -qE '^[0-9]' || continue

    case "$category" in
      *SKILL.md*)
        verify_governance "$PLUGIN_DIR/SKILL.md" "SKILL.md" "$current"
        ;;
      *magi-core.md*)
        verify_governance "$PLUGIN_DIR/agents/magi-core.md" "magi-core.md" "$current"
        ;;
      *comparison-format.md*)
        verify_governance "$PLUGIN_DIR/references/comparison-format.md" "comparison-format.md" "$current"
        ;;
      *voting-engine.md*)
        verify_governance "$PLUGIN_DIR/references/voting-engine.md" "voting-engine.md" "$current"
        ;;
      *dialectic-format.md*)
        verify_governance "$PLUGIN_DIR/references/dialectic-format.md" "dialectic-format.md" "$current"
        ;;
      *sample-deliberation*)
        verify_governance "$PLUGIN_DIR/examples/sample-deliberation.md" "sample-deliberation.md" "$current"
        ;;
    esac
  done < "$GOVERNANCE"

  if [ "$GOV_WARNS" -gt 0 ]; then
    echo ""
    echo "WARN: $GOV_WARNS governance.md Current value(s) out of date. Update governance.md."
  else
    echo ""
    echo "All governance.md Current values match actual file sizes."
  fi
fi

exit 0
