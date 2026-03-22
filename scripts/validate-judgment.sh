#!/usr/bin/env bash
# MAGI_JUDGMENT JSON Schema Validator
# Validates MAGI Core judgment output against judgment-rules.md schema
# Usage: validate-judgment.sh <file_or_stdin>
# Exit 0 = valid, Exit 1 = invalid

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

fail() { echo -e "${RED}FAIL${NC}  $1"; exit 1; }
pass() { echo -e "${GREEN}PASS${NC}  $1"; }

# Read input from file argument or stdin
if [ $# -ge 1 ] && [ -f "$1" ]; then
  INPUT=$(cat "$1")
else
  INPUT=$(cat)
fi

# Step 1: Extract <!-- MAGI_JUDGMENT {...} --> block (macOS compatible — no grep -oP)
MAGI_BLOCK=$(echo "$INPUT" | sed -n 's/.*<!-- MAGI_JUDGMENT \(.*\) -->.*/\1/p' | head -1)

if [ -z "$MAGI_BLOCK" ]; then
  fail "No <!-- MAGI_JUDGMENT {...} --> block found"
fi

pass "MAGI_JUDGMENT block found"

# Step 2: Validate JSON
if ! echo "$MAGI_BLOCK" | jq . >/dev/null 2>&1; then
  fail "Invalid JSON in MAGI_JUDGMENT block"
fi

pass "Valid JSON"

# Step 3: Check overall_verdict
VERDICT=$(echo "$MAGI_BLOCK" | jq -r '.overall_verdict // empty')
if [ -z "$VERDICT" ]; then
  fail "Missing overall_verdict field"
fi
case "$VERDICT" in
  Approve|Reject|"Conditional Approval"|Indeterminate) ;;
  *) fail "Invalid overall_verdict: $VERDICT (expected Approve/Reject/Conditional Approval/Indeterminate)" ;;
esac
pass "overall_verdict: $VERDICT"

# Step 4: Check vote_tally
TALLY=$(echo "$MAGI_BLOCK" | jq -r '.vote_tally // empty')
if [ -z "$TALLY" ]; then
  fail "Missing vote_tally field"
fi
# Validate format: X:Y or X:Y:Z (digits separated by colons)
if ! echo "$TALLY" | grep -qE '^[0-9]+:[0-9]+(:[0-9]+)?$'; then
  fail "Invalid vote_tally format: $TALLY (expected X:Y or X:Y:Z)"
fi
pass "vote_tally: $TALLY"

# Step 5: Check confidence
CONFIDENCE=$(echo "$MAGI_BLOCK" | jq -r '.confidence // empty')
if [ -z "$CONFIDENCE" ]; then
  fail "Missing confidence field"
fi
case "$CONFIDENCE" in
  High|Medium|Low) ;;
  *) fail "Invalid confidence: $CONFIDENCE (expected High/Medium/Low)" ;;
esac
pass "confidence: $CONFIDENCE"

# Step 5.5: Check reversibility (optional — backward compatible)
REVERSIBILITY=$(echo "$MAGI_BLOCK" | jq -r '.reversibility // empty')
if [ -n "$REVERSIBILITY" ]; then
  case "$REVERSIBILITY" in
    High|Medium|Low) ;;
    *) fail "Invalid reversibility: $REVERSIBILITY (expected High/Medium/Low)" ;;
  esac
  pass "reversibility: $REVERSIBILITY"
fi

# Step 6: Check bias_flags (must be array)
BIAS_TYPE=$(echo "$MAGI_BLOCK" | jq -r '.bias_flags | type')
if [ "$BIAS_TYPE" != "array" ]; then
  fail "bias_flags must be an array (got: $BIAS_TYPE)"
fi
BIAS_COUNT=$(echo "$MAGI_BLOCK" | jq '.bias_flags | length')
pass "bias_flags: array with $BIAS_COUNT entries"

# Step 7: Check conditions (string or null)
CONDITIONS_TYPE=$(echo "$MAGI_BLOCK" | jq -r '.conditions | type')
case "$CONDITIONS_TYPE" in
  string|null) ;;
  *) fail "conditions must be string or null (got: $CONDITIONS_TYPE)" ;;
esac
pass "conditions: $CONDITIONS_TYPE"

# Step 8: Check agents array
AGENTS_TYPE=$(echo "$MAGI_BLOCK" | jq -r '.agents | type')
if [ "$AGENTS_TYPE" != "array" ]; then
  fail "agents must be an array (got: $AGENTS_TYPE)"
fi
AGENT_COUNT=$(echo "$MAGI_BLOCK" | jq '.agents | length')
if [ "$AGENT_COUNT" -lt 1 ]; then
  fail "agents array must have at least 1 entry"
fi
pass "agents: array with $AGENT_COUNT entries"

# Step 9: Validate each agent entry
for i in $(seq 0 $((AGENT_COUNT - 1))); do
  AGENT=$(echo "$MAGI_BLOCK" | jq ".agents[$i]")

  AGENT_NAME=$(echo "$AGENT" | jq -r '.name // empty')
  [ -n "$AGENT_NAME" ] || fail "agents[$i] missing name"

  AGENT_VERDICT=$(echo "$AGENT" | jq -r '.verdict // empty')
  case "$AGENT_VERDICT" in
    Approve|Reject|"Conditional Approval") ;;
    *) fail "agents[$i] invalid verdict: $AGENT_VERDICT" ;;
  esac

  AGENT_SCORE=$(echo "$AGENT" | jq -r '.avg_score // empty')
  [ -n "$AGENT_SCORE" ] || fail "agents[$i] missing avg_score"
  # Validate avg_score is a number in range 1.0-5.0
  SCORE_VALID=$(echo "$AGENT_SCORE" | awk '{if ($1 >= 1.0 && $1 <= 5.0) print "yes"; else print "no"}')
  [ "$SCORE_VALID" = "yes" ] || fail "agents[$i] avg_score out of range: $AGENT_SCORE (expected 1.0-5.0)"

  AGENT_SUMMARY=$(echo "$AGENT" | jq -r '.summary // empty')
  [ -n "$AGENT_SUMMARY" ] || fail "agents[$i] missing summary"

  pass "agents[$i] ($AGENT_NAME): valid"
done

echo ""
echo -e "${GREEN}VALID${NC}  MAGI_JUDGMENT conforms to schema"
exit 0
