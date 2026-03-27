#!/usr/bin/env bash
# magi-annotate.sh — Annotate a MAGI deliberation log with an outcome verdict
#
# Usage: bash scripts/magi-annotate.sh <log-filename> <outcome>
#   <log-filename>  Name of a JSON file in .magi/history/ (e.g., 2026-03-24T14-30-00.json)
#   <outcome>       One of: correct, incorrect, partial, na
#
# The script appends "outcome" and "annotated_at" fields to the log JSON.
# Re-annotation overwrites the previous outcome with an updated timestamp.

set -euo pipefail

HISTORY_DIR=".magi/history"
VALID_OUTCOMES=("correct" "incorrect" "partial" "na")

usage() {
  echo "Usage: bash scripts/magi-annotate.sh <log-filename> <outcome>"
  echo "  outcome: correct | incorrect | partial | na"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

LOG_FILE="${HISTORY_DIR}/$1"
OUTCOME="$2"

# Validate log file exists
if [[ ! -f "$LOG_FILE" ]]; then
  echo "Error: Log file not found: $LOG_FILE" >&2
  exit 1
fi

# Validate outcome value
valid=false
for v in "${VALID_OUTCOMES[@]}"; do
  if [[ "$OUTCOME" == "$v" ]]; then
    valid=true
    break
  fi
done

if [[ "$valid" != "true" ]]; then
  echo "Error: Invalid outcome '$OUTCOME'. Must be one of: ${VALID_OUTCOMES[*]}" >&2
  exit 1
fi

# Check jq is available
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# Validate existing JSON
if ! jq empty "$LOG_FILE" 2>/dev/null; then
  echo "Error: $LOG_FILE is not valid JSON." >&2
  exit 1
fi

# Add outcome and annotated_at fields
ANNOTATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TEMP_FILE=$(mktemp)

jq --arg outcome "$OUTCOME" --arg ts "$ANNOTATED_AT" \
  '.outcome = $outcome | .annotated_at = $ts' \
  "$LOG_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$LOG_FILE"

echo "Annotated $1 with outcome=$OUTCOME at $ANNOTATED_AT"
