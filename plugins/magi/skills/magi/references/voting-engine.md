# Voting Engine — Parameterized Judgment Rules

Generalized voting logic for N voting agents. The default council has N=3.

## Definitions

- **Voting agent**: An agent whose verdict counts toward the final judgment. Default: MELCHIOR-1, BALTHASAR-2, CASPAR-3.
- **Advisory agent**: An agent whose analysis is included in the report but does NOT vote. Role: `"advisory"` in config.
- **N**: Number of voting agents. Must be odd (3, 5, 7) to avoid ties.

## Majority Rules (N agents)

| Tally | Verdict | Confidence |
|-------|---------|------------|
| N:0 Unanimous Approve | Approve | High |
| N:0 Unanimous Reject | Reject | High |
| (N+1)/2 : (N-1)/2 Majority | Adopt majority verdict | Medium |
| No majority (3+ distinct verdicts) | Indeterminate | Low |

- **Conditional Approval** counts as Approve for tally purposes. Conditions are aggregated.
- Partial results (< N responses): confidence capped at Medium. If < ceil(N/2) respond, no verdict issued.

## Contention Analysis

Triggered on any non-unanimous split where a majority exists:

1. Identify dissenter(s) — agents whose verdict differs from the majority
2. For each dissenter: compute average score, find weakest axis, quote rationale
3. If multiple dissenters agree, group them as a bloc

## Comparison Mode

Same rules apply to recommendation tallies instead of verdicts.

## Advisory Agent Handling

- Advisory agents are launched in parallel with voting agents
- Their output is displayed in Phase 4 after voting agents, under a separate "Advisory Analysis" section
- Advisory scores are shown but clearly marked as non-voting
- Advisory agents use the same prompt format and MAGI_OUTPUT schema as voting agents
