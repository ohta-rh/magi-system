#!/usr/bin/env bash
# MAGI E2E Integration Test
# Tests extraction, vote tally, and dissenter identification from mock agent responses
# No agent execution — tests extraction and voting logic only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_VALIDATOR="$SCRIPT_DIR/../scripts/validate-output.sh"
FIXTURE="$SCRIPT_DIR/fixtures/e2e-agent-responses.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

PASS=0
FAIL=0
TOTAL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$expected" = "$actual" ]; then
    echo -e "  ${GREEN}PASS${NC}  $label (expected: $expected)"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC}  $label (expected: $expected, got: $actual)"
    FAIL=$((FAIL + 1))
  fi
}

echo "━━━ MAGI E2E Integration Test ━━━"
echo ""

# Step 1: Extract the 3 MAGI_OUTPUT blocks
echo "--- Step 1: Extract MAGI_OUTPUT blocks ---"

BLOCKS=$(sed -n 's/.*<!-- MAGI_OUTPUT \(.*\) -->.*/\1/p' "$FIXTURE")
BLOCK_COUNT=$(echo "$BLOCKS" | wc -l | tr -d ' ')

assert_eq "Extracted 3 MAGI_OUTPUT blocks" "3" "$BLOCK_COUNT"

# Step 2: Validate each block with validate-output.sh
echo ""
echo "--- Step 2: Validate each MAGI_OUTPUT block ---"

AGENT_NAMES=("MELCHIOR-1" "BALTHASAR-2" "CASPAR-3")
IDX=0

# Split fixture by agent headers and validate each
for agent_name in "${AGENT_NAMES[@]}"; do
  # Extract this agent's section from header to EOF, then trim at next header
  AGENT_SECTION=$(awk "/^#### \[$agent_name\]/{found=1; next} /^#### \[/{if(found) exit} found{print}" "$FIXTURE")

  TOTAL=$((TOTAL + 1))
  if echo "$AGENT_SECTION" | bash "$OUTPUT_VALIDATOR" >/dev/null 2>&1; then
    echo -e "  ${GREEN}PASS${NC}  $agent_name MAGI_OUTPUT validates"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC}  $agent_name MAGI_OUTPUT validation failed"
    FAIL=$((FAIL + 1))
  fi
  IDX=$((IDX + 1))
done

# Step 3: Verify vote tally (2 Approve, 1 Reject = 2:1)
echo ""
echo "--- Step 3: Verify vote tally ---"

APPROVE_COUNT=$(echo "$BLOCKS" | jq -r '.verdict' | grep -c "Approve" || true)
REJECT_COUNT=$(echo "$BLOCKS" | jq -r '.verdict' | grep -c "Reject" || true)

assert_eq "Approve count" "2" "$APPROVE_COUNT"
assert_eq "Reject count" "1" "$REJECT_COUNT"

TALLY="${APPROVE_COUNT}:${REJECT_COUNT}"
assert_eq "Vote tally" "2:1" "$TALLY"

# Step 4: Identify the dissenter
echo ""
echo "--- Step 4: Identify dissenter ---"

# The dissenter is the agent whose verdict differs from the majority
# Parse each block's verdict and find the Reject
DISSENTER_IDX=0
LINE_NUM=0
DISSENTER_NAME=""
while IFS= read -r line; do
  VERDICT=$(echo "$line" | jq -r '.verdict')
  if [ "$VERDICT" = "Reject" ]; then
    DISSENTER_NAME="${AGENT_NAMES[$LINE_NUM]}"
    break
  fi
  LINE_NUM=$((LINE_NUM + 1))
done <<< "$BLOCKS"

assert_eq "Dissenter identified" "BALTHASAR-2" "$DISSENTER_NAME"

echo ""
echo "━━━ Results: $PASS/$TOTAL passed, $FAIL failed ━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
else
  exit 0
fi
