#!/usr/bin/env bash
# magi-eval-diff.sh — Compare two magi-eval summary.json files.
# Usage: bash scripts/magi-eval-diff.sh <baseline-summary.json> <candidate-summary.json>
# Prints pass-rate delta and per-fixture status flips. Exits 1 if the
# candidate pass rate regressed.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: bash scripts/magi-eval-diff.sh <baseline.json> <candidate.json>" >&2
  exit 1
fi

OUT="$(jq -n --slurpfile a "$1" --slurpfile b "$2" '
  ($a[0].results | map({key: .fixture, value: .status}) | from_entries) as $A
  | ($b[0].results | map({key: .fixture, value: .status}) | from_entries) as $B
  | {
      baseline_pass_rate: $a[0].pass_rate,
      candidate_pass_rate: $b[0].pass_rate,
      delta: ($b[0].pass_rate - $a[0].pass_rate),
      flips: [
        (($A + $B) | keys[]) as $k
        | select(($A[$k] // "absent") != ($B[$k] // "absent"))
        | {fixture: $k, baseline: ($A[$k] // "absent"), candidate: ($B[$k] // "absent")}
      ]
    }
')"
printf '%s\n' "$OUT"
jq -e '.delta >= 0' <<<"$OUT" >/dev/null
