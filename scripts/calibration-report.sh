#!/usr/bin/env bash
# calibration-report.sh — Score calibration analysis for MAGI agents
#
# Usage: bash scripts/calibration-report.sh
#
# Analyzes outcome-annotated deliberation logs to identify systematic
# scoring biases per agent. Produces a human-readable report.
#
# Minimum 30 annotated logs required. This is a read-only analysis tool —
# no automated prompt modification.
#
# Predecessor: #73 (Self-Calibration Report) — closed. This issue produces
# a read-only report for human consumption only.
# Predecessor: #61 (File-Based Deliberation Memory) — closed. This reads
# from deliberation logs but does not create a memory system.

set -euo pipefail

HISTORY_DIR=".magi/history"
MIN_ANNOTATED=30

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required." >&2
  exit 1
fi

if [[ ! -d "$HISTORY_DIR" ]]; then
  echo "No deliberation logs found in $HISTORY_DIR"
  exit 0
fi

# Count annotated logs
ANNOTATED_FILES=()
for f in "$HISTORY_DIR"/*.json; do
  [[ -f "$f" ]] || continue
  if jq -e '.outcome != null' "$f" &>/dev/null; then
    ANNOTATED_FILES+=("$f")
  fi
done

ANNOTATED_COUNT=${#ANNOTATED_FILES[@]}

if [[ $ANNOTATED_COUNT -lt $MIN_ANNOTATED ]]; then
  echo "Insufficient annotated logs: $ANNOTATED_COUNT / $MIN_ANNOTATED required."
  echo "Use 'bash scripts/magi-annotate.sh <file> <outcome>' to annotate deliberation logs."
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  MAGI Score Calibration Analysis"
echo "  Annotated logs: $ANNOTATED_COUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Per-agent analysis
# Extract unique agent names from first file
AGENT_NAMES=$(jq -r '.judgment.agents[].name' "${ANNOTATED_FILES[0]}" 2>/dev/null)

for agent_name in $AGENT_NAMES; do
  echo "--- $agent_name ---"

  # Scores when outcome = correct
  CORRECT_SCORES=$(for f in "${ANNOTATED_FILES[@]}"; do
    jq -r "select(.outcome == \"correct\") | .judgment.agents[] | select(.name == \"$agent_name\") | .avg_score" "$f" 2>/dev/null
  done)

  # Scores when outcome = incorrect
  INCORRECT_SCORES=$(for f in "${ANNOTATED_FILES[@]}"; do
    jq -r "select(.outcome == \"incorrect\") | .judgment.agents[] | select(.name == \"$agent_name\") | .avg_score" "$f" 2>/dev/null
  done)

  # Compute means
  CORRECT_MEAN=$(echo "$CORRECT_SCORES" | awk 'NF{s+=$1; n++} END {if(n>0) printf "%.2f", s/n; else print "N/A"}')
  INCORRECT_MEAN=$(echo "$INCORRECT_SCORES" | awk 'NF{s+=$1; n++} END {if(n>0) printf "%.2f", s/n; else print "N/A"}')
  CORRECT_N=$(echo "$CORRECT_SCORES" | awk 'NF{n++} END {print n+0}')
  INCORRECT_N=$(echo "$INCORRECT_SCORES" | awk 'NF{n++} END {print n+0}')

  printf "  Mean score (correct outcomes):    %s (n=%s)\n" "$CORRECT_MEAN" "$CORRECT_N"
  printf "  Mean score (incorrect outcomes):  %s (n=%s)\n" "$INCORRECT_MEAN" "$INCORRECT_N"

  # Verdict accuracy (did this agent's verdict align with outcome?)
  AGENT_CORRECT=0
  AGENT_TOTAL=0
  for f in "${ANNOTATED_FILES[@]}"; do
    OUTCOME=$(jq -r '.outcome // empty' "$f" 2>/dev/null)
    AGENT_VERDICT=$(jq -r ".judgment.agents[] | select(.name == \"$agent_name\") | .verdict" "$f" 2>/dev/null)
    [[ -z "$OUTCOME" || -z "$AGENT_VERDICT" ]] && continue

    ((AGENT_TOTAL++))
    # Approve/Conditional Approval + correct = alignment
    # Reject + incorrect = alignment
    if [[ ("$OUTCOME" == "correct" || "$OUTCOME" == "partial") && ("$AGENT_VERDICT" == "Approve" || "$AGENT_VERDICT" == "Conditional Approval") ]]; then
      ((AGENT_CORRECT++))
    elif [[ "$OUTCOME" == "incorrect" && "$AGENT_VERDICT" == "Reject" ]]; then
      ((AGENT_CORRECT++))
    fi
  done

  if [[ $AGENT_TOTAL -gt 0 ]]; then
    ACCURACY=$(echo "scale=0; $AGENT_CORRECT * 100 / $AGENT_TOTAL" | bc)
    printf "  Verdict-outcome alignment:       %d%% (%d/%d)\n" "$ACCURACY" "$AGENT_CORRECT" "$AGENT_TOTAL"
  fi

  # Bias flag frequency for this agent
  BIAS_COUNT=0
  for f in "${ANNOTATED_FILES[@]}"; do
    if jq -e ".judgment.bias_flags[]? | select(contains(\"$agent_name\"))" "$f" &>/dev/null; then
      ((BIAS_COUNT++))
    fi
  done
  printf "  Bias flags triggered:            %d / %d deliberations\n" "$BIAS_COUNT" "$ANNOTATED_COUNT"

  # Calibration suggestion
  if [[ "$CORRECT_MEAN" != "N/A" && "$INCORRECT_MEAN" != "N/A" ]]; then
    SEPARATION=$(echo "$CORRECT_MEAN - $INCORRECT_MEAN" | bc -l 2>/dev/null || echo "0")
    if (( $(echo "$SEPARATION < 0.5" | bc -l 2>/dev/null || echo 0) )); then
      echo "  >> Investigation suggested: Low score separation between correct/incorrect outcomes."
      echo "     Scores may not be discriminating well. Review axis scoring rationale."
    fi
  fi

  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Analysis complete. All findings are suggestive."
echo "  No automated prompt modification performed."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
