#!/usr/bin/env bash
# MAGI Extraction Test Suite
# Runs validate-output.sh and validate-judgment.sh against all fixtures

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_VALIDATOR="$SCRIPT_DIR/../scripts/validate-output.sh"
JUDGMENT_VALIDATOR="$SCRIPT_DIR/../scripts/validate-judgment.sh"
FIXTURES="$SCRIPT_DIR/fixtures"

PASS=0
FAIL=0
TOTAL=0

assert_valid() {
  local validator="$1"
  local file="$2"
  local label="$3"
  TOTAL=$((TOTAL + 1))
  if bash "$validator" "$file" >/dev/null 2>&1; then
    echo "  PASS  $label (expected: valid, got: valid)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $label (expected: valid, got: INVALID)"
    FAIL=$((FAIL + 1))
  fi
}

assert_invalid() {
  local validator="$1"
  local file="$2"
  local label="$3"
  TOTAL=$((TOTAL + 1))
  if bash "$validator" "$file" >/dev/null 2>&1; then
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
assert_valid "$OUTPUT_VALIDATOR" "$FIXTURES/valid-output-v1.0.txt" "v1.0 standard (Approve)"
assert_valid "$OUTPUT_VALIDATOR" "$FIXTURES/valid-output-v1.1.txt" "v1.1 comparison mode"
assert_valid "$OUTPUT_VALIDATOR" "$FIXTURES/valid-output-conditional.txt" "v1.0 Conditional Approval"
assert_valid "$OUTPUT_VALIDATOR" "$FIXTURES/valid-output-reject.txt" "v1.0 Reject verdict"
assert_valid "$OUTPUT_VALIDATOR" "$FIXTURES/valid-output-empty-risks.txt" "v1.0 empty risks array"

echo ""

# Malformed outputs — should fail
echo "--- Malformed Outputs ---"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-no-block.txt" "no MAGI_OUTPUT block"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-bad-json.txt" "invalid JSON"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-missing-fields.txt" "missing required fields"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-bad-score-range.txt" "score out of 1-5 range"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-conditions-mismatch.txt" "Conditional Approval with null conditions"
assert_invalid "$OUTPUT_VALIDATOR" "$FIXTURES/malformed-v1.1-bad-recommendation.txt" "v1.1 recommendation mismatch"

echo ""
echo "━━━ MAGI_JUDGMENT Extraction Tests ━━━"
echo ""

# Valid judgments — should pass
echo "--- Valid Judgments ---"
assert_valid "$JUDGMENT_VALIDATOR" "$FIXTURES/valid-judgment-unanimous.txt" "3:0 Approve (unanimous)"
assert_valid "$JUDGMENT_VALIDATOR" "$FIXTURES/valid-judgment-split.txt" "2:1 split with bias flags"
assert_valid "$JUDGMENT_VALIDATOR" "$FIXTURES/valid-judgment-reject.txt" "3:0 Reject with conditions"

echo ""

# Malformed judgments — should fail
echo "--- Malformed Judgments ---"
assert_invalid "$JUDGMENT_VALIDATOR" "$FIXTURES/malformed-judgment.txt" "invalid JSON in MAGI_JUDGMENT"

echo ""
echo "━━━ Results: $PASS/$TOTAL passed, $FAIL failed ━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
