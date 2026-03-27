#!/usr/bin/env bash
# benchmark-regression.sh — Prompt regression test harness for MAGI
#
# Usage:
#   bash scripts/benchmark-regression.sh              # Run all benchmarks (full MAGI deliberation)
#   bash scripts/benchmark-regression.sh --dry-run    # Validate fixture JSON only, no MAGI invocation
#
# Reads tests/fixtures/benchmarks/*.json, invokes MAGI for each topic,
# and validates output against fixture expectations.
#
# WARNING: Full runs are expensive (one MAGI deliberation per fixture).
# Not for CI — use for manual pre-merge validation of prompt changes.
#
# Expected fixture schema:
#   {
#     "topic": "string",
#     "expected_verdict_range": ["Approve", "Conditional Approval"],
#     "expected_contention": false,
#     "min_score_variance": 0.5,
#     "required_risk_keywords": ["keyword1"]
#   }

set -euo pipefail

BENCHMARK_DIR="tests/fixtures/benchmarks"
DRY_RUN=false
PASS=0
FAIL=0
SKIP=0

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

if [[ ! -d "$BENCHMARK_DIR" ]]; then
  echo "Error: Benchmark directory not found: $BENCHMARK_DIR" >&2
  exit 1
fi

FILES=("$BENCHMARK_DIR"/*.json)
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "Error: No benchmark fixtures found in $BENCHMARK_DIR" >&2
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MAGI Benchmark Regression Test"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  Mode: DRY RUN (fixture validation only)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

validate_fixture() {
  local file="$1"
  local name
  name=$(basename "$file")

  # Check valid JSON
  if ! jq empty "$file" 2>/dev/null; then
    echo "  FAIL [$name]: Invalid JSON"
    return 1
  fi

  # Check required fields
  for field in topic expected_verdict_range expected_contention min_score_variance required_risk_keywords; do
    if jq -e ".$field == null" "$file" 2>/dev/null | grep -q "true"; then
      echo "  FAIL [$name]: Missing required field '$field'"
      return 1
    fi
  done

  # Check expected_verdict_range is non-empty array
  local vcount
  vcount=$(jq '.expected_verdict_range | length' "$file")
  if [[ "$vcount" -eq 0 ]]; then
    echo "  FAIL [$name]: expected_verdict_range is empty"
    return 1
  fi

  # Check min_score_variance is a number
  if ! jq -e '.min_score_variance | type == "number"' "$file" &>/dev/null; then
    echo "  FAIL [$name]: min_score_variance must be a number"
    return 1
  fi

  echo "  PASS [$name]: Fixture schema valid"
  return 0
}

for file in "${FILES[@]}"; do
  name=$(basename "$file")
  echo "--- $name ---"

  if ! validate_fixture "$file"; then
    ((FAIL++))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    ((PASS++))
    continue
  fi

  # Full run: invoke MAGI via claude CLI
  TOPIC=$(jq -r '.topic' "$file")
  echo "  Running MAGI deliberation for: $TOPIC"
  echo "  (This may take several minutes...)"

  # Capture MAGI output — expect MAGI_JUDGMENT in the output
  OUTPUT=$(claude -p "/magi $TOPIC" --output-format text 2>/dev/null || true)

  # Extract MAGI_JUDGMENT
  JUDGMENT=$(echo "$OUTPUT" | grep -o '<!-- MAGI_JUDGMENT {.*} -->' | sed 's/<!-- MAGI_JUDGMENT //;s/ -->//' || true)

  if [[ -z "$JUDGMENT" ]]; then
    echo "  FAIL [$name]: No MAGI_JUDGMENT block found in output"
    ((FAIL++))
    continue
  fi

  fixture_pass=true

  # Check verdict in expected range
  VERDICT=$(echo "$JUDGMENT" | jq -r '.overall_verdict')
  EXPECTED_RANGE=$(jq -r '.expected_verdict_range[]' "$file")
  verdict_match=false
  while IFS= read -r expected; do
    if [[ "$VERDICT" == "$expected" ]]; then
      verdict_match=true
      break
    fi
  done <<< "$EXPECTED_RANGE"

  if [[ "$verdict_match" != "true" ]]; then
    echo "  FAIL [$name]: Verdict '$VERDICT' not in expected range"
    fixture_pass=false
  fi

  # Check score variance
  MIN_VARIANCE=$(jq '.min_score_variance' "$file")
  VARIANCE=$(echo "$JUDGMENT" | jq '[.agents[].avg_score] | (map(. - (add / length)) | map(. * .) | add / length)' 2>/dev/null || echo "0")
  if (( $(echo "$VARIANCE < $MIN_VARIANCE" | bc -l 2>/dev/null || echo 1) )); then
    echo "  FAIL [$name]: Score variance $VARIANCE < minimum $MIN_VARIANCE"
    fixture_pass=false
  fi

  # Check contention
  EXPECTED_CONTENTION=$(jq '.expected_contention' "$file")
  TALLY=$(echo "$JUDGMENT" | jq -r '.vote_tally')
  is_split=false
  if [[ "$TALLY" == *"2:1"* ]] || [[ "$TALLY" == *"1:1:1"* ]]; then
    is_split=true
  fi
  if [[ "$EXPECTED_CONTENTION" == "true" && "$is_split" == "false" ]]; then
    echo "  WARN [$name]: Expected contention but got unanimous ($TALLY)"
  fi

  # Check required risk keywords in full output
  KEYWORDS=$(jq -r '.required_risk_keywords[]' "$file")
  while IFS= read -r kw; do
    if ! echo "$OUTPUT" | grep -qi "$kw"; then
      echo "  FAIL [$name]: Required risk keyword '$kw' not found in output"
      fixture_pass=false
    fi
  done <<< "$KEYWORDS"

  if [[ "$fixture_pass" == "true" ]]; then
    echo "  PASS [$name]"
    ((PASS++))
  else
    ((FAIL++))
  fi

  echo ""
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed, $SKIP skipped (${#FILES[@]} total)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
