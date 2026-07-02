#!/usr/bin/env bash
# test-eval-harness.sh — offline tests for magi-eval.sh (no LLM calls)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $desc"; PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc — expected '$expected', got '$actual'"; FAIL=$((FAIL + 1))
  fi
}

# shellcheck disable=SC1091
source "$REPO_ROOT/scripts/magi-eval.sh"

# --- canned inputs ---------------------------------------------------------
cat > "$TMP/log-reject.json" <<'EOF'
{"schema_version":"1.0","timestamp":"2026-01-01T00:00:00Z","topic":"t","judgment":{
 "overall_verdict":"Reject","vote_tally":"3 Reject : 0","confidence":"High","reversibility":"High",
 "bias_flags":[],"conditions":null,"agents":[
  {"name":"MELCHIOR-1","verdict":"Reject","avg_score":1.5,"summary":"s"},
  {"name":"BALTHASAR-2","verdict":"Reject","avg_score":2.5,"summary":"s"},
  {"name":"CASPAR-3","verdict":"Reject","avg_score":2.0,"summary":"s"}]}}
EOF
cat > "$TMP/log-approve-flat.json" <<'EOF'
{"schema_version":"1.0","timestamp":"2026-01-01T00:00:00Z","topic":"t","judgment":{
 "overall_verdict":"Approve","vote_tally":"2 Approve : 1 Conditional Approval","confidence":"High","reversibility":"High",
 "bias_flags":[],"conditions":null,"agents":[
  {"name":"MELCHIOR-1","verdict":"Approve","avg_score":4.0,"summary":"s"},
  {"name":"BALTHASAR-2","verdict":"Approve","avg_score":4.0,"summary":"s"},
  {"name":"CASPAR-3","verdict":"Conditional Approval","avg_score":4.0,"summary":"s"}]}}
EOF
cat > "$TMP/log-split.json" <<'EOF'
{"schema_version":"1.0","timestamp":"2026-01-01T00:00:00Z","topic":"t","judgment":{
 "overall_verdict":"Conditional Approval","vote_tally":"2 Conditional Approval : 1 Reject","confidence":"Medium","reversibility":"Medium",
 "bias_flags":[],"conditions":"c","agents":[
  {"name":"MELCHIOR-1","verdict":"Conditional Approval","avg_score":3.5,"summary":"s"},
  {"name":"BALTHASAR-2","verdict":"Reject","avg_score":1.5,"summary":"s"},
  {"name":"CASPAR-3","verdict":"Conditional Approval","avg_score":3.0,"summary":"s"}]}}
EOF
echo "Critical security risk identified in the proposal." > "$TMP/stdout.txt"

fx() { printf '%s' "$1" > "$TMP/fx.json"; }

echo "--- score_fixture ---"

fx '{"topic":"t","expected_verdict_range":["Reject"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-reject.json" "$TMP/stdout.txt")"
assert_eq "matching verdict passes" "pass" "$(jq -r '.status' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Approve"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-reject.json" "$TMP/stdout.txt")"
assert_eq "verdict mismatch fails" "fail" "$(jq -r '.status' <<<"$R")"
assert_eq "mismatch reason recorded" "1" "$(jq '[.reasons[] | select(contains("not in expected range"))] | length' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Approve","Reject"],"forbidden_verdicts":["Approve"],"expected_contention":false,"min_score_variance":0.0,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-approve-flat.json" "$TMP/stdout.txt")"
assert_eq "forbidden verdict fails" "fail" "$(jq -r '.status' <<<"$R")"
assert_eq "forbidden reason recorded" "1" "$(jq '[.reasons[] | select(contains("forbidden"))] | length' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Approve"],"expected_contention":false,"min_score_variance":0.5,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-approve-flat.json" "$TMP/stdout.txt")"
assert_eq "low variance fails" "fail" "$(jq -r '.status' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Reject"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["kubernetes"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-reject.json" "$TMP/stdout.txt")"
assert_eq "missing keyword fails" "fail" "$(jq -r '.status' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Reject"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" /dev/null "$TMP/stdout.txt")"
assert_eq "missing log is error" "error" "$(jq -r '.status' <<<"$R")"

fx '{"topic":"t","expected_verdict_range":["Reject"],"expected_contention":true,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-reject.json" "$TMP/stdout.txt")"
assert_eq "contention mismatch stays pass" "pass" "$(jq -r '.status' <<<"$R")"
assert_eq "contention mismatch warns" "1" "$(jq '.warnings | length' <<<"$R")"

cat > "$TMP/log-comparison.json" <<'EOF'
{"schema_version":"1.0","timestamp":"2026-01-01T00:00:00Z","topic":"t","judgment":{
 "overall_verdict":"Approve","vote_tally":"3:0 PostgreSQL","confidence":"High","reversibility":"Medium",
 "bias_flags":[],"conditions":null,"agents":[
  {"name":"MELCHIOR-1","verdict":"Approve","recommendation":"PostgreSQL"},
  {"name":"BALTHASAR-2","verdict":"Approve","recommendation":"PostgreSQL"},
  {"name":"CASPAR-3","verdict":"Approve","recommendation":"PostgreSQL"}]}}
EOF
fx '{"topic":"t","expected_verdict_range":["Approve"],"expected_contention":false,"min_score_variance":0.0,"required_risk_keywords":["security"]}'
R="$(score_fixture "$TMP/fx.json" "$TMP/log-comparison.json" "$TMP/stdout.txt")"
assert_eq "zero floor skips variance on scoreless comparison log" "pass" "$(jq -r '.status' <<<"$R")"

echo "--- derive_contention ---"
assert_eq "unanimous reject: no-split" "no-split" "$(derive_contention "$TMP/log-reject.json")"
assert_eq "approve+CA group together: no-split" "no-split" "$(derive_contention "$TMP/log-approve-flat.json")"
assert_eq "CA vs Reject: split" "split" "$(derive_contention "$TMP/log-split.json")"

echo "--- annotate_log ---"
fx '{"topic":"t","expected_verdict_range":["Reject"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
annotate_log "$TMP/log-reject.json" "$TMP/fx.json" "$TMP/hist"
A="$(ls "$TMP/hist"/*.json | head -1)"
assert_eq "annotation outcome correct" "correct" "$(jq -r '.outcome' "$A")"
assert_eq "annotation source" "benchmark" "$(jq -r '.source' "$A")"
assert_eq "annotation fixture name" "fx" "$(jq -r '.fixture' "$A")"

fx '{"topic":"t","expected_verdict_range":["Approve"],"expected_contention":false,"min_score_variance":0.1,"required_risk_keywords":["security"]}'
annotate_log "$TMP/log-reject.json" "$TMP/fx.json" "$TMP/hist2"
A="$(ls "$TMP/hist2"/*.json | head -1)"
assert_eq "annotation outcome incorrect" "incorrect" "$(jq -r '.outcome' "$A")"

echo "--- runner (stub claude) ---"
export MAGI_EVAL_CLAUDE_BIN="$REPO_ROOT/tests/fixtures/eval/bin/claude-stub"
export MAGI_EVAL_BENCHMARK_DIR="$REPO_ROOT/tests/fixtures/eval/bench"
export MAGI_EVAL_ROOT="$TMP/eval-root"
export MAGI_EVAL_TIMEOUT=60
RC=0
bash "$REPO_ROOT/scripts/magi-eval.sh" --run-id stubrun --concurrency 2 > "$TMP/runner-out.txt" 2>&1 || RC=$?
assert_eq "runner exit code signals failures" "1" "$RC"
S="$TMP/eval-root/runs/stubrun/summary.json"
assert_eq "summary total" "2" "$(jq -r '.total' "$S")"
assert_eq "summary pass" "1" "$(jq -r '.pass' "$S")"
assert_eq "summary fail" "1" "$(jq -r '.fail' "$S")"
assert_eq "report rendered" "yes" "$([[ -s "$TMP/eval-root/runs/stubrun/report.md" ]] && echo yes || echo no)"
assert_eq "annotated logs archived" "2" "$(ls "$TMP/eval-root/history/"*.json | wc -l | tr -d ' ')"
unset MAGI_EVAL_CLAUDE_BIN MAGI_EVAL_BENCHMARK_DIR MAGI_EVAL_ROOT MAGI_EVAL_TIMEOUT

echo "--- eval diff ---"
cat > "$TMP/sum-a.json" <<'EOF'
{"run_id":"a","total":2,"pass":1,"fail":1,"error":0,"pass_rate":0.5,"results":[
 {"fixture":"f1","status":"pass"},{"fixture":"f2","status":"fail"}]}
EOF
cat > "$TMP/sum-b.json" <<'EOF'
{"run_id":"b","total":2,"pass":2,"fail":0,"error":0,"pass_rate":1.0,"results":[
 {"fixture":"f1","status":"pass"},{"fixture":"f2","status":"pass"}]}
EOF
D="$(bash "$REPO_ROOT/scripts/magi-eval-diff.sh" "$TMP/sum-a.json" "$TMP/sum-b.json")"
assert_eq "diff delta positive" "0.5" "$(jq -r '.delta' <<<"$D")"
assert_eq "diff flips count" "1" "$(jq '.flips | length' <<<"$D")"
assert_eq "diff flip fixture" "f2" "$(jq -r '.flips[0].fixture' <<<"$D")"
RC=0
bash "$REPO_ROOT/scripts/magi-eval-diff.sh" "$TMP/sum-b.json" "$TMP/sum-a.json" >/dev/null || RC=$?
assert_eq "regression exits 1" "1" "$RC"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
