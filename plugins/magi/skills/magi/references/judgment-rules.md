# Judgment Rules

Default rules for 3 voting agents. For generalized N-agent rules, see [voting-engine.md](voting-engine.md).

- **Unanimous** (3:0): Final verdict matches. Confidence: High
- **Majority** (2:1): Adopt majority verdict. Confidence: Medium. Minority concerns noted in conditions
- **Conditional Approval** counts as Approve. However, conditions are aggregated in the final verdict
- **Three-way split** (all different verdicts): Indeterminate. Confidence: Low. Present all views and defer to user
- Advisory agents do not participate in the vote tally

## Risk Summary

Consolidate "Risks and Concerns" from all three MAGI, deduplicate, and reflect in recommended actions.

## Comparison Mode — Recommendation Tally

- **Unanimous recommendation** (3:0): All agents recommend the same option. Confidence: High
- **Majority recommendation** (2:1): Two agents agree on the recommended option. Confidence: Medium. Note the dissenter's alternative
- **Three-way split** (1:1:1 with 3+ options): No consensus. Confidence: Low. Present all recommendations and defer to user
- Per-option verdicts (Approve/Reject) are secondary information — displayed for completeness but the primary signal is the Recommendation tally
- If 2+ options receive identical recommendation counts, compare average scores across recommending agents to break the tie

## MAGI_JUDGMENT Schema — Synthesis Agent Output

MAGI Core emits `<!-- MAGI_JUDGMENT {...} -->` at the end of its response. The orchestrator parses this for Phase 5 decisions.

```json
{
  "overall_verdict": "Approve | Reject | Conditional Approval | Indeterminate",
  "vote_tally": "string — e.g. '3:0', '2:1'",
  "confidence": "High | Medium | Low",
  "bias_flags": ["string — detected bias patterns. Empty array if none"],
  "conditions": "string or null — aggregated conditions if any",
  "agents": [
    {
      "name": "string — agent display name",
      "verdict": "Approve | Reject | Conditional Approval",
      "avg_score": "number — mean of 4 axis scores (1.0-5.0)",
      "summary": "string — 1-2 line summary of agent's position"
    }
  ]
}
```

### Field Rules

- `overall_verdict`: Determined by voting engine. Must be one of the four values.
- `vote_tally`: Format `X:Y` for majority or `X:Y:Z` for three-way split.
- `confidence`: May be reduced by one level if `bias_flags` is non-empty.
- `bias_flags`: Array of strings describing detected sycophancy or overcorrection patterns. Use `[]` if none.
- `conditions`: Non-empty string if any agent issued Conditional Approval, otherwise `null`.
- `agents`: Array with one entry per voting agent (advisory agents excluded).
- `agents[].avg_score`: Arithmetic mean of the agent's 4 axis scores, rounded to 1 decimal.
- The entire block MUST be valid JSON enclosed in `<!-- MAGI_JUDGMENT ... -->` HTML comment markers.
