#!/usr/bin/env bash
# magi-metrics.sh — Quality metrics reporter for MAGI deliberation logs
#
# Usage: bash scripts/magi-metrics.sh
#
# Reads all .magi/history/*.json files and produces a summary report:
#   - Total deliberation count
#   - Verdict distribution
#   - Mean scores per agent per axis
#   - Consensus rate
#   - Bias flag frequency
#   - Annotation coverage and accuracy rate
#
# Output format: plain text, greppable, suitable for commit messages or PR descriptions.
# Exit code: always 0 (informational tool).

set -euo pipefail

HISTORY_DIR=".magi/history"

if [[ ! -d "$HISTORY_DIR" ]] || [[ -z "$(ls -A "$HISTORY_DIR" 2>/dev/null)" ]]; then
  echo "No deliberation logs found in $HISTORY_DIR"
  exit 0
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# Collect all valid JSON files
FILES=("$HISTORY_DIR"/*.json)
TOTAL=${#FILES[@]}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MAGI Deliberation Quality Metrics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Total deliberations: $TOTAL"
echo ""

# Verdict distribution
echo "--- Verdict Distribution ---"
jq -r '.judgment.overall_verdict // "unknown"' "${FILES[@]}" 2>/dev/null | sort | uniq -c | sort -rn | while read -r count verdict; do
  printf "  %-30s %d\n" "$verdict" "$count"
done
echo ""

# Consensus rate
echo "--- Consensus Rate ---"
UNANIMOUS=$(jq -r '.judgment.vote_tally // ""' "${FILES[@]}" 2>/dev/null | grep -c "3:0" || true)
SPLIT=$(jq -r '.judgment.vote_tally // ""' "${FILES[@]}" 2>/dev/null | grep -c "2:1" || true)
INDETERMINATE=$(jq -r '.judgment.vote_tally // ""' "${FILES[@]}" 2>/dev/null | grep -c "1:1:1" || true)
printf "  Unanimous (3:0):    %d\n" "$UNANIMOUS"
printf "  Split (2:1):        %d\n" "$SPLIT"
printf "  Indeterminate:      %d\n" "$INDETERMINATE"
echo ""

# Confidence distribution
echo "--- Confidence Distribution ---"
jq -r '.judgment.confidence // "unknown"' "${FILES[@]}" 2>/dev/null | sort | uniq -c | sort -rn | while read -r count level; do
  printf "  %-20s %d\n" "$level" "$count"
done
echo ""

# Mean scores per agent
echo "--- Mean Scores per Agent ---"
for agent_idx in 0 1 2; do
  AGENT_NAME=$(jq -r ".judgment.agents[$agent_idx].name // empty" "${FILES[0]}" 2>/dev/null)
  if [[ -z "$AGENT_NAME" ]]; then continue; fi
  AVG=$(jq -r ".judgment.agents[$agent_idx].avg_score // empty" "${FILES[@]}" 2>/dev/null | awk '{s+=$1; n++} END {if(n>0) printf "%.2f", s/n; else print "N/A"}')
  printf "  %-20s avg_score: %s\n" "$AGENT_NAME" "$AVG"
done
echo ""

# Bias flag frequency
echo "--- Bias Flags ---"
BIAS_COUNT=$(jq -r '.judgment.bias_flags[]? // empty' "${FILES[@]}" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$BIAS_COUNT" -gt 0 ]]; then
  jq -r '.judgment.bias_flags[]? // empty' "${FILES[@]}" 2>/dev/null | sort | uniq -c | sort -rn | while read -r count flag; do
    printf "  %-40s %d\n" "$flag" "$count"
  done
else
  echo "  No bias flags detected"
fi
echo ""

# Annotation coverage
echo "--- Annotation Coverage ---"
ANNOTATED=$(jq -r 'select(.outcome != null) | .outcome' "${FILES[@]}" 2>/dev/null | wc -l | tr -d ' ')
printf "  Annotated:     %d / %d (%.0f%%)\n" "$ANNOTATED" "$TOTAL" "$(echo "scale=0; $ANNOTATED * 100 / $TOTAL" | bc 2>/dev/null || echo 0)"

if [[ "$ANNOTATED" -gt 0 ]]; then
  CORRECT=$(jq -r 'select(.outcome == "correct") | .outcome' "${FILES[@]}" 2>/dev/null | wc -l | tr -d ' ')
  INCORRECT=$(jq -r 'select(.outcome == "incorrect") | .outcome' "${FILES[@]}" 2>/dev/null | wc -l | tr -d ' ')
  PARTIAL=$(jq -r 'select(.outcome == "partial") | .outcome' "${FILES[@]}" 2>/dev/null | wc -l | tr -d ' ')
  printf "  Correct:       %d\n" "$CORRECT"
  printf "  Incorrect:     %d\n" "$INCORRECT"
  printf "  Partial:       %d\n" "$PARTIAL"
  ACCURACY=$(echo "scale=0; $CORRECT * 100 / $ANNOTATED" | bc 2>/dev/null || echo 0)
  printf "  Accuracy rate: %s%%\n" "$ACCURACY"
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
