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
