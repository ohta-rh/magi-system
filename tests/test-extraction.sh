#!/usr/bin/env bash
# MAGI_OUTPUT Extraction Test Suite
# Runs validate-output.sh against all fixtures and asserts expected results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-output.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

PASS=0
FAIL=0
TOTAL=0

assert_valid() {
  local file="$1"
  local label="$2"
  TOTAL=$((TOTAL + 1))
  if bash "$VALIDATOR" "$file" >/dev/null 2>&1; then
    echo "  PASS  $label (expected: valid, got: valid)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $label (expected: valid, got: INVALID)"
    FAIL=$((FAIL + 1))
  fi
}

assert_invalid() {
  local file="$1"
  local label="$2"
  TOTAL=$((TOTAL + 1))
  if bash "$VALIDATOR" "$file" >/dev/null 2>&1; then
    echo "  FAIL  $label (expected: invalid, got: VALID)"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS  $label (expected: invalid, got: invalid)"
    PASS=$((PASS + 1))
  fi
}

echo "━━━ MAGI_OUTPUT Extraction Tests ━━━"
echo ""

# Valid outputs — should pass
echo "--- Valid Outputs ---"
assert_valid "$FIXTURES/valid-output-v1.0.txt" "v1.0 standard (Approve)"
assert_valid "$FIXTURES/valid-output-v1.1.txt" "v1.1 comparison mode"
assert_valid "$FIXTURES/valid-output-conditional.txt" "v1.0 Conditional Approval"

echo ""

# Malformed outputs — should fail
echo "--- Malformed Outputs ---"
assert_invalid "$FIXTURES/malformed-no-block.txt" "no MAGI_OUTPUT block"
assert_invalid "$FIXTURES/malformed-bad-json.txt" "invalid JSON"
assert_invalid "$FIXTURES/malformed-missing-fields.txt" "missing required fields"
assert_invalid "$FIXTURES/malformed-bad-score-range.txt" "score out of 1-5 range"
assert_invalid "$FIXTURES/malformed-conditions-mismatch.txt" "Conditional Approval with null conditions"

echo ""
echo "━━━ Results: $PASS/$TOTAL passed, $FAIL failed ━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
