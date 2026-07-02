#!/usr/bin/env bash
# benchmark-regression.sh — Benchmark fixture validator for MAGI
#
# Usage:
#   bash scripts/benchmark-regression.sh --dry-run    # Validate fixture JSON schema
#   bash scripts/benchmark-regression.sh              # Same, plus SKIP notice per fixture
#
# Full deliberation runs moved to scripts/magi-eval.sh (v10) — the
# headless eval harness with isolated workspaces, scoring, and reports.
#
# Expected fixture schema:
#   {
#     "topic": "string",
#     "expected_verdict_range": ["Approve", "Conditional Approval"],
#     "expected_contention": false,
#     "min_score_variance": 0.5,
#     "required_risk_keywords": ["keyword1"],
#     "forbidden_verdicts": ["Approve"],        (optional — bias guard)
#     "category": "string",                     (optional)
#     "notes": "string"                         (optional)
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

  # Optional v10 fields
  if jq -e 'has("forbidden_verdicts")' "$file" >/dev/null 2>&1; then
    if ! jq -e '.forbidden_verdicts | type == "array" and all(type == "string")' "$file" >/dev/null 2>&1; then
      echo "  FAIL [$name]: forbidden_verdicts must be an array of strings"
      return 1
    fi
  fi
  for opt in category notes; do
    if jq -e "has(\"$opt\")" "$file" >/dev/null 2>&1; then
      if ! jq -e ".$opt | type == \"string\"" "$file" >/dev/null 2>&1; then
        echo "  FAIL [$name]: $opt must be a string"
        return 1
      fi
    fi
  done

  echo "  PASS [$name]: Fixture schema valid"
  return 0
}

for file in "${FILES[@]}"; do
  name=$(basename "$file")
  echo "--- $name ---"

  if ! validate_fixture "$file"; then
    FAIL=$((FAIL + 1))
    continue
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    PASS=$((PASS + 1))
    continue
  fi

  echo "  SKIP [$name]: full runs moved to scripts/magi-eval.sh (v10)"
  SKIP=$((SKIP + 1))
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed, $SKIP skipped (${#FILES[@]} total)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
