#!/usr/bin/env bash
# MAGI deliberation log validation hook (PostToolUse on Write).
#
# Receives the hook event JSON on stdin. If the written file is a MAGI
# deliberation log (.magi/history/*.json), validate its structure and feed
# errors back to Claude (exit 2) so the log can be self-corrected.
# Any other file — or any missing tooling — exits 0 silently: this hook
# must never break unrelated writes.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

EVENT=$(cat)
FILE_PATH=$(printf '%s' "$EVENT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0

case "$FILE_PATH" in
  *.magi/history/*.json) ;;
  *) exit 0 ;;
esac

[ -f "$FILE_PATH" ] || exit 0

if ! jq empty "$FILE_PATH" >/dev/null 2>&1; then
  echo "MAGI log validation: $FILE_PATH is not valid JSON. Rewrite the deliberation log with valid JSON." >&2
  exit 2
fi

ERRORS=$(jq -r '
  [
    (if .schema_version == null then "missing schema_version" else empty end),
    (if .timestamp == null then "missing timestamp" else empty end),
    (if .topic == null then "missing topic" else empty end),
    (if .judgment == null then "missing judgment object"
     elif .judgment.overall_verdict == null then "missing judgment.overall_verdict"
     else empty end)
  ] | join("; ")
' "$FILE_PATH" 2>/dev/null)

if [ -n "$ERRORS" ]; then
  echo "MAGI log validation: $FILE_PATH failed schema check — $ERRORS. Fix the deliberation log (see SKILL.md Phase 3 Step 4.5 for the expected structure)." >&2
  exit 2
fi

exit 0
