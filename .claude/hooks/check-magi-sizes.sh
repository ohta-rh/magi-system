#!/bin/bash
# PostToolUse hook: Run MAGI plugin size governance check
# Fires after Edit/Write on files under plugins/magi/

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *"/plugins/magi/"* ]]; then
  bash "$CLAUDE_PROJECT_DIR"/scripts/check-sizes.sh
fi

exit 0
