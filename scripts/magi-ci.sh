#!/usr/bin/env bash
# MAGI CI Integration Hook
# Headless MAGI invocation for automated PR review
# Usage: magi-ci.sh <topic_description> [--strict]
# Exit 0 = Approve, Exit 1 = Reject/Conditional, Exit 2 = Error

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: magi-ci.sh <topic_description> [--strict]"
  echo ""
  echo "Runs MAGI deliberation in headless mode via Claude Code."
  echo "  --strict: Exit 1 on Conditional Approval (default: exit 0)"
  exit 2
fi

TOPIC="$1"
STRICT=false
if [ "${2:-}" = "--strict" ]; then
  STRICT=true
fi

echo "━━━ MAGI CI Mode ━━━"
echo "Topic: $TOPIC"
echo "Strict: $STRICT"
echo ""

# Run MAGI via Claude Code headless mode
OUTPUT=$(claude -p "Run /magi $TOPIC" \
  --allowedTools "Agent,Read,Glob,Grep,WebSearch,WebFetch,AskUserQuestion" \
  2>&1) || {
  echo "ERROR: Claude Code invocation failed"
  exit 2
}

# Extract overall verdict from output
VERDICT=$(echo "$OUTPUT" | grep -oP '(?<=\*\*Overall Verdict:\*\*\s).*' | head -1 || true)

if [ -z "$VERDICT" ]; then
  echo "ERROR: Could not extract verdict from MAGI output"
  echo "$OUTPUT"
  exit 2
fi

echo "Verdict: $VERDICT"

# Determine exit code
case "$VERDICT" in
  *Approve*)
    if [ "$STRICT" = true ] && [[ "$VERDICT" == *"Conditional"* ]]; then
      echo "STRICT MODE: Conditional Approval treated as failure"
      exit 1
    fi
    echo "PASS"
    exit 0
    ;;
  *Reject*|*Indeterminate*)
    echo "FAIL"
    exit 1
    ;;
  *)
    echo "UNKNOWN VERDICT: $VERDICT"
    exit 2
    ;;
esac
