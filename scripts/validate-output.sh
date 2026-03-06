#!/usr/bin/env bash
# MAGI_OUTPUT JSON Schema Validator
# Validates agent output against schema.md rules
# Usage: validate-output.sh <file_or_stdin>
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

# Step 1: Extract <!-- MAGI_OUTPUT {...} --> block
MAGI_BLOCK=$(echo "$INPUT" | grep -oP '<!-- MAGI_OUTPUT \K\{.*?\}(?= -->)' 2>/dev/null || true)

if [ -z "$MAGI_BLOCK" ]; then
  # Try multiline extraction (some outputs may have newlines)
  MAGI_BLOCK=$(echo "$INPUT" | sed -n 's/.*<!-- MAGI_OUTPUT \(.*\) -->.*/\1/p' | head -1)
fi

if [ -z "$MAGI_BLOCK" ]; then
  fail "No <!-- MAGI_OUTPUT {...} --> block found"
fi

pass "MAGI_OUTPUT block found"

# Step 2: Validate JSON
if ! echo "$MAGI_BLOCK" | jq . >/dev/null 2>&1; then
  fail "Invalid JSON in MAGI_OUTPUT block"
fi

pass "Valid JSON"

# Step 3: Check schema_version
VERSION=$(echo "$MAGI_BLOCK" | jq -r '.schema_version // empty')
if [ -z "$VERSION" ]; then
  fail "Missing schema_version field"
fi
if [ "$VERSION" != "1.0" ] && [ "$VERSION" != "1.1" ]; then
  fail "Invalid schema_version: $VERSION (expected 1.0 or 1.1)"
fi

pass "schema_version: $VERSION"

# Step 4: Branch by schema version
if [ "$VERSION" = "1.1" ]; then
  # Comparison mode validation
  MODE=$(echo "$MAGI_BLOCK" | jq -r '.mode // empty')
  [ "$MODE" = "comparison" ] || fail "v1.1 requires mode: comparison (got: $MODE)"
  pass "mode: comparison"

  REC=$(echo "$MAGI_BLOCK" | jq -r '.recommendation // empty')
  [ -n "$REC" ] || fail "Missing recommendation field"
  pass "recommendation: $REC"

  REC_RAT=$(echo "$MAGI_BLOCK" | jq -r '.recommendation_rationale // empty')
  [ -n "$REC_RAT" ] || fail "Missing recommendation_rationale field"
  pass "recommendation_rationale present"

  OPT_COUNT=$(echo "$MAGI_BLOCK" | jq '.options | length')
  [ "$OPT_COUNT" -ge 2 ] && [ "$OPT_COUNT" -le 4 ] || fail "options count must be 2-4 (got: $OPT_COUNT)"
  pass "options count: $OPT_COUNT"

  # Validate each option
  for i in $(seq 0 $((OPT_COUNT - 1))); do
    OPT=$(echo "$MAGI_BLOCK" | jq ".options[$i]")
    OPT_NAME=$(echo "$OPT" | jq -r '.name // empty')
    [ -n "$OPT_NAME" ] || fail "options[$i] missing name"

    OPT_VERDICT=$(echo "$OPT" | jq -r '.verdict // empty')
    case "$OPT_VERDICT" in
      Approve|Reject|"Conditional Approval") ;;
      *) fail "options[$i] invalid verdict: $OPT_VERDICT" ;;
    esac

    SCORE_COUNT=$(echo "$OPT" | jq '.scores | length')
    [ "$SCORE_COUNT" -eq 4 ] || fail "options[$i] must have exactly 4 scores (got: $SCORE_COUNT)"

    echo "$OPT" | jq -r '.scores | to_entries[] | "\(.key) \(.value.score)"' | while read -r key score; do
      [ "$score" -ge 1 ] && [ "$score" -le 5 ] || fail "options[$i] score $key out of range: $score"
    done

    pass "options[$i] ($OPT_NAME): valid"
  done

  # Check recommendation matches an option name
  REC_MATCH=$(echo "$MAGI_BLOCK" | jq --arg rec "$REC" '[.options[].name] | index($rec)')
  [ "$REC_MATCH" != "null" ] || fail "recommendation '$REC' does not match any option name"
  pass "recommendation matches option"
else
  # v1.0 standard mode validation
  VERDICT=$(echo "$MAGI_BLOCK" | jq -r '.verdict // empty')
  if [ -z "$VERDICT" ]; then
    fail "Missing verdict field"
  fi
  case "$VERDICT" in
    Approve|Reject|"Conditional Approval") ;;
    *) fail "Invalid verdict: $VERDICT (expected Approve/Reject/Conditional Approval)" ;;
  esac
  pass "verdict: $VERDICT"

  # Check conditions logic
  CONDITIONS=$(echo "$MAGI_BLOCK" | jq -r '.conditions // "null"')
  if [ "$VERDICT" = "Conditional Approval" ] && [ "$CONDITIONS" = "null" ]; then
    fail "Conditional Approval requires non-null conditions"
  fi
  if [ "$VERDICT" != "Conditional Approval" ] && [ "$CONDITIONS" != "null" ]; then
    fail "conditions must be null when verdict is not Conditional Approval"
  fi
  pass "conditions logic consistent"

  # Check scores: exactly 4 axes, each with score (1-5) and rationale
  SCORE_COUNT=$(echo "$MAGI_BLOCK" | jq '.scores | length')
  if [ "$SCORE_COUNT" -ne 4 ]; then
    fail "Expected exactly 4 score axes (got: $SCORE_COUNT)"
  fi
  pass "4 score axes present"

  # Validate each score
  echo "$MAGI_BLOCK" | jq -r '.scores | to_entries[] | "\(.key) \(.value.score) \(.value.rationale)"' | while read -r key score rationale; do
    if [ "$score" -lt 1 ] || [ "$score" -gt 5 ]; then
      fail "Score $key out of range: $score (expected 1-5)"
    fi
    if [ -z "$rationale" ]; then
      fail "Score $key missing rationale"
    fi
  done
  pass "All scores valid (1-5 range with rationales)"

  # Check risks array
  RISKS_TYPE=$(echo "$MAGI_BLOCK" | jq -r '.risks | type')
  if [ "$RISKS_TYPE" != "array" ]; then
    fail "risks must be an array (got: $RISKS_TYPE)"
  fi
  pass "risks is array"
fi

echo ""
echo -e "${GREEN}VALID${NC}  MAGI_OUTPUT conforms to schema v${VERSION}"
exit 0
