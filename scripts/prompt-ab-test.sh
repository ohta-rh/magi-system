#!/usr/bin/env bash
# prompt-ab-test.sh — A/B comparison tool for MAGI agent prompts
#
# Usage:
#   bash scripts/prompt-ab-test.sh <agent-file-A> <agent-file-B> [--fixture <fixture-file>]
#
# Runs MAGI with each prompt version against benchmark fixtures and produces
# a side-by-side comparison report. All results are informational — the human
# decides which version to keep.
#
# WARNING: This is expensive — runs full MAGI deliberation twice per fixture.
# Use sparingly for validating prompt changes.
#
# Prerequisites: Benchmark Fixture Suite (tests/fixtures/benchmarks/)
# Predecessor: #73 (Self-Calibration Report) — closed. This is narrower: compares
# two specific prompt versions on known benchmarks with human review only.

set -euo pipefail

BENCHMARK_DIR="tests/fixtures/benchmarks"

usage() {
  echo "Usage: bash scripts/prompt-ab-test.sh <agent-file-A> <agent-file-B> [--fixture <fixture>]"
  echo ""
  echo "  <agent-file-A>   Path to the baseline agent file (e.g., plugins/magi/skills/magi/agents/melchior.md)"
  echo "  <agent-file-B>   Path to the variant agent file (e.g., melchior-v2.md)"
  echo "  --fixture <file> Run against a specific fixture only (default: all in $BENCHMARK_DIR)"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

FILE_A="$1"
FILE_B="$2"
SPECIFIC_FIXTURE=""

shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fixture)
      SPECIFIC_FIXTURE="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Validate files exist
for f in "$FILE_A" "$FILE_B"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: File not found: $f" >&2
    exit 1
  fi
done

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required." >&2
  exit 1
fi

# Determine which agent slot this is (detect by content patterns)
AGENT_NAME=""
if grep -q "MELCHIOR" "$FILE_A"; then AGENT_NAME="melchior"
elif grep -q "BALTHASAR" "$FILE_A"; then AGENT_NAME="balthasar"
elif grep -q "CASPAR" "$FILE_A"; then AGENT_NAME="caspar"
else
  echo "Warning: Could not detect agent name from $FILE_A, proceeding anyway."
  AGENT_NAME="unknown"
fi

# Determine target path for swapping
TARGET_PATH=""
if [[ "$AGENT_NAME" == "melchior" ]]; then TARGET_PATH="plugins/magi/skills/magi/agents/melchior.md"
elif [[ "$AGENT_NAME" == "balthasar" ]]; then TARGET_PATH="plugins/magi/skills/magi/agents/balthasar.md"
elif [[ "$AGENT_NAME" == "caspar" ]]; then TARGET_PATH="plugins/magi/skills/magi/agents/caspar.md"
fi

# Collect fixtures
if [[ -n "$SPECIFIC_FIXTURE" ]]; then
  if [[ ! -f "$SPECIFIC_FIXTURE" ]]; then
    echo "Error: Fixture not found: $SPECIFIC_FIXTURE" >&2
    exit 1
  fi
  FIXTURES=("$SPECIFIC_FIXTURE")
else
  FIXTURES=("$BENCHMARK_DIR"/*.json)
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MAGI Prompt A/B Comparison"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Agent:    $AGENT_NAME"
echo "  Version A: $FILE_A"
echo "  Version B: $FILE_B"
echo "  Fixtures:  ${#FIXTURES[@]}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Safety: backup original if we need to swap
BACKUP=""
if [[ -n "$TARGET_PATH" && -f "$TARGET_PATH" ]]; then
  BACKUP=$(mktemp)
  cp "$TARGET_PATH" "$BACKUP"
fi

cleanup() {
  if [[ -n "$BACKUP" && -n "$TARGET_PATH" ]]; then
    cp "$BACKUP" "$TARGET_PATH"
    rm -f "$BACKUP"
    echo ""
    echo "Working tree restored to original state."
  fi
}
trap cleanup EXIT

run_magi() {
  local topic="$1"
  local output
  output=$(claude -p "/magi $topic" --output-format text 2>/dev/null || true)
  echo "$output"
}

extract_judgment() {
  local output="$1"
  echo "$output" | grep -o '<!-- MAGI_JUDGMENT {.*} -->' | sed 's/<!-- MAGI_JUDGMENT //;s/ -->//' || echo "{}"
}

for fixture in "${FIXTURES[@]}"; do
  fname=$(basename "$fixture")
  TOPIC=$(jq -r '.topic' "$fixture")

  echo "=== $fname ==="
  echo "Topic: $TOPIC"
  echo ""

  # Run with Version A (original — should already be in place)
  if [[ -n "$TARGET_PATH" ]]; then
    cp "$FILE_A" "$TARGET_PATH"
  fi
  echo "  Running Version A..."
  OUTPUT_A=$(run_magi "$TOPIC")
  JUDGMENT_A=$(extract_judgment "$OUTPUT_A")

  # Run with Version B
  if [[ -n "$TARGET_PATH" ]]; then
    cp "$FILE_B" "$TARGET_PATH"
  fi
  echo "  Running Version B..."
  OUTPUT_B=$(run_magi "$TOPIC")
  JUDGMENT_B=$(extract_judgment "$OUTPUT_B")

  # Extract key metrics
  VERDICT_A=$(echo "$JUDGMENT_A" | jq -r '.overall_verdict // "N/A"')
  VERDICT_B=$(echo "$JUDGMENT_B" | jq -r '.overall_verdict // "N/A"')
  CONFIDENCE_A=$(echo "$JUDGMENT_A" | jq -r '.confidence // "N/A"')
  CONFIDENCE_B=$(echo "$JUDGMENT_B" | jq -r '.confidence // "N/A"')

  # Agent-specific scores
  AGENT_SCORE_A=$(echo "$JUDGMENT_A" | jq -r ".agents[] | select(.name | ascii_downcase | contains(\"$AGENT_NAME\")) | .avg_score // \"N/A\"" 2>/dev/null || echo "N/A")
  AGENT_SCORE_B=$(echo "$JUDGMENT_B" | jq -r ".agents[] | select(.name | ascii_downcase | contains(\"$AGENT_NAME\")) | .avg_score // \"N/A\"" 2>/dev/null || echo "N/A")

  echo ""
  printf "  %-25s %-20s %-20s\n" "" "Version A" "Version B"
  printf "  %-25s %-20s %-20s\n" "Overall Verdict" "$VERDICT_A" "$VERDICT_B"
  printf "  %-25s %-20s %-20s\n" "Confidence" "$CONFIDENCE_A" "$CONFIDENCE_B"
  printf "  %-25s %-20s %-20s\n" "$AGENT_NAME avg_score" "$AGENT_SCORE_A" "$AGENT_SCORE_B"

  # Highlight significant differences
  if [[ "$AGENT_SCORE_A" != "N/A" && "$AGENT_SCORE_B" != "N/A" ]]; then
    DELTA=$(echo "$AGENT_SCORE_B - $AGENT_SCORE_A" | bc -l 2>/dev/null || echo "0")
    ABS_DELTA=$(echo "${DELTA#-}" | bc -l 2>/dev/null || echo "0")
    if (( $(echo "$ABS_DELTA >= 1.0" | bc -l 2>/dev/null || echo 0) )); then
      echo "  >>> SIGNIFICANT DELTA: $DELTA on $AGENT_NAME avg_score"
    fi
  fi

  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  A/B comparison complete."
echo "  Human review required — no automated selection."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
