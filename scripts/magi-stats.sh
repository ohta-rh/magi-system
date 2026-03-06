#!/usr/bin/env bash
# MAGI Decision Log Statistics
# Reads docs/magi-decisions.jsonl and reports summary statistics

set -euo pipefail

DECISION_LOG="${1:-docs/magi-decisions.jsonl}"

if [ ! -f "$DECISION_LOG" ]; then
  echo "No decision log found at $DECISION_LOG"
  echo "Run MAGI deliberations to start accumulating data."
  exit 0
fi

TOTAL=$(wc -l < "$DECISION_LOG" | tr -d ' ')

echo "━━━ MAGI Decision Log Statistics ━━━"
echo ""
echo "Total deliberations: $TOTAL"
echo ""

if [ "$TOTAL" -eq 0 ]; then
  echo "No records to analyze."
  exit 0
fi

echo "--- Verdict Distribution ---"
jq -r '.overall' "$DECISION_LOG" | sort | uniq -c | sort -rn | while read -r count verdict; do
  printf "  %-25s %d (%d%%)\n" "$verdict" "$count" "$((count * 100 / TOTAL))"
done

echo ""
echo "--- Confidence Distribution ---"
jq -r '.confidence' "$DECISION_LOG" | sort | uniq -c | sort -rn | while read -r count confidence; do
  printf "  %-25s %d (%d%%)\n" "$confidence" "$count" "$((count * 100 / TOTAL))"
done

echo ""
echo "--- Average Scores by Agent ---"
for agent in MELCHIOR BALTHASAR CASPAR; do
  key="${agent}_avg"
  avg=$(jq -r ".scores_summary.${key} // empty" "$DECISION_LOG" | awk '{s+=$1; n++} END {if(n>0) printf "%.2f", s/n; else print "N/A"}')
  printf "  %-15s avg: %s\n" "$agent" "$avg"
done

echo ""
echo "--- Most Recent Deliberations ---"
tail -5 "$DECISION_LOG" | jq -r '"  \(.timestamp | split("T")[0]) | \(.overall) (\(.confidence)) | \(.topic[:60])"'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
