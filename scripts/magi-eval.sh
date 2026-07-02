#!/usr/bin/env bash
# magi-eval.sh — Headless MAGI evaluation harness (MAGI v10)
#
# Runs benchmark fixtures through a real headless MAGI deliberation
# (claude -p --plugin-dir) and scores results against fixture ground
# truth. The deliberation log written by the skill (Phase 3 Step 4.5)
# is the primary result artifact; captured stdout is the fallback for
# keyword checks.
#
# Usage:
#   bash scripts/magi-eval.sh [--run-id NAME] [--fixtures PREFIX]
#                             [--runs N] [--concurrency N]
#   PREFIX matches fixture basenames, e.g. '01' or '1'.
#
# Results: .magi/eval/runs/<run-id>/{<fixture>/,report.md,summary.json}
# Annotated logs (calibration input): .magi/eval/history/
#
# WARNING: one full council deliberation per fixture per run. Never
# wire full runs into CI. bash 3.2 compatible.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BENCHMARK_DIR="${MAGI_EVAL_BENCHMARK_DIR:-$REPO_ROOT/tests/fixtures/benchmarks}"
PLUGIN_DIR="$REPO_ROOT/plugins/magi"
EVAL_ROOT="${MAGI_EVAL_ROOT:-$REPO_ROOT/.magi/eval}"
CLAUDE_BIN="${MAGI_EVAL_CLAUDE_BIN:-claude}"
TIMEOUT_SECS="${MAGI_EVAL_TIMEOUT:-900}"
ALLOWED_TOOLS='Agent,Read,Write,Glob,Grep,WebSearch,WebFetch,Bash(mkdir:*),Bash(ls:*),Bash(date:*)'

# derive_contention <log_file>
# Groups judgment.agents[].verdict into Reject vs Approve-ish and prints
# "split" when both groups are present. The free-form vote_tally string
# is never parsed (real logs vary, e.g. "2 Conditional Approval : 1 Approve").
derive_contention() {
  local log_file="$1"
  jq -r '
    [.judgment.agents[].verdict | if . == "Reject" then "R" else "A" end] as $g
    | if ($g | index("A")) and ($g | index("R")) then "split" else "no-split" end
  ' "$log_file"
}

# score_fixture <fixture_file> <log_file> <stdout_file>
# Prints a one-line JSON result; never returns non-zero.
score_fixture() {
  local fixture_file="$1" log_file="$2" stdout_file="$3"
  local name
  name="$(basename "$fixture_file" .json)"

  if [[ ! -s "$log_file" ]] || ! jq -e '.judgment.overall_verdict' "$log_file" >/dev/null 2>&1; then
    jq -cn --arg f "$name" \
      '{fixture:$f, status:"error", verdict:null, reasons:["no valid deliberation log"], warnings:[]}'
    return 0
  fi

  local verdict reasons='[]' warnings='[]'
  verdict="$(jq -r '.judgment.overall_verdict' "$log_file")"

  if [[ "$(jq --arg v "$verdict" '.expected_verdict_range | index($v)' "$fixture_file")" == "null" ]]; then
    reasons="$(jq -c --arg r "verdict '$verdict' not in expected range" '. + [$r]' <<<"$reasons")"
  fi

  if [[ "$(jq --arg v "$verdict" '(.forbidden_verdicts // []) | index($v)' "$fixture_file")" != "null" ]]; then
    reasons="$(jq -c --arg r "verdict '$verdict' is forbidden for this fixture (bias guard)" '. + [$r]' <<<"$reasons")"
  fi

  # `|| echo false` — a malformed agents array (e.g. empty → divide by zero)
  # must degrade to a scoring failure, not crash the whole background job
  # and silently drop this fixture's result.json from the aggregate.
  local variance_ok
  variance_ok="$(jq --slurpfile fx "$fixture_file" '
    [.judgment.agents[].avg_score] as $s
    | ($s | add / length) as $m
    | ($s | map((. - $m) * (. - $m)) | add / length) >= $fx[0].min_score_variance
  ' "$log_file" 2>/dev/null || echo false)"
  if [[ "$variance_ok" != "true" ]]; then
    reasons="$(jq -c '. + ["score variance below fixture minimum"]' <<<"$reasons")"
  fi

  local kw
  while IFS= read -r kw; do
    [[ -z "$kw" ]] && continue
    if ! grep -qi -- "$kw" "$stdout_file" "$log_file" 2>/dev/null; then
      reasons="$(jq -c --arg r "required keyword '$kw' not found" '. + [$r]' <<<"$reasons")"
    fi
  done < <(jq -r '.required_risk_keywords[]' "$fixture_file")

  local expected_contention actual
  expected_contention="$(jq -r '.expected_contention' "$fixture_file")"
  actual="$(derive_contention "$log_file")"
  if [[ "$expected_contention" == "true" && "$actual" != "split" ]]; then
    warnings="$(jq -c '. + ["expected contention but verdicts grouped unanimously"]' <<<"$warnings")"
  elif [[ "$expected_contention" == "false" && "$actual" == "split" ]]; then
    warnings="$(jq -c '. + ["unexpected contention"]' <<<"$warnings")"
  fi

  local status="pass"
  if [[ "$(jq 'length' <<<"$reasons")" -gt 0 ]]; then
    status="fail"
  fi

  jq -cn --arg f "$name" --arg s "$status" --arg v "$verdict" \
    --argjson reasons "$reasons" --argjson warnings "$warnings" \
    '{fixture:$f, status:$s, verdict:$v, reasons:$reasons, warnings:$warnings}'
}

# annotate_log <log_file> <fixture_file> <dest_dir>
# Archives an annotated copy of the deliberation log for calibration
# analysis. Outcome is ground-truth verdict-range membership.
annotate_log() {
  local log_file="$1" fixture_file="$2" dest_dir="$3"
  jq -e '.judgment.overall_verdict' "$log_file" >/dev/null 2>&1 || return 0

  local verdict outcome ts fixture_name
  verdict="$(jq -r '.judgment.overall_verdict' "$log_file")"
  fixture_name="$(basename "$fixture_file" .json)"
  if [[ "$(jq --arg v "$verdict" '.expected_verdict_range | index($v)' "$fixture_file")" != "null" ]]; then
    outcome="correct"
  else
    outcome="incorrect"
  fi
  ts="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  mkdir -p "$dest_dir"
  jq --arg o "$outcome" --arg ts "$ts" --arg fx "$fixture_name" \
    '.outcome = $o | .annotated_at = $ts | .source = "benchmark" | .fixture = $fx' \
    "$log_file" > "$dest_dir/${fixture_name}-$(date -u +%Y%m%dT%H%M%S)-$$-$RANDOM.json"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
