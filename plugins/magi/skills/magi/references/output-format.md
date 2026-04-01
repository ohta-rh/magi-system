# Phase 4: Deliberation Output Format

> **Note:** This file is a human-readable reference for the output format. The authoritative runtime source for output formatting is `agents/magi-core.md`, which MAGI Core uses during synthesis. If the two diverge, `magi-core.md` takes precedence.

Report the results in the following format (use Markdown tables for scores, keep ━━━ headers for NERV aesthetic):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI SYSTEM — Deliberation Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Topic:** (state the topic)

Note: Individual agent reports are displayed in Phase 3.0 (before MAGI Core). MAGI Core output uses a compact Vote Tally Table instead of repeating per-agent details:

### Vote Tally

| Agent | Persona | Verdict | Avg Score |
|-------|---------|---------|-----------|
| MELCHIOR-1 | Scientist | (verdict) | (avg) |
| BALTHASAR-2 | Mother | (verdict) | (avg) |
| CASPAR-3 | Woman | (verdict) | (avg) |

Advisory agents appear below with `(advisory)` tag.

- If contention analysis was performed (by MAGI Core), insert it here (before Final Judgment)
- If Phase 3.7 dialectic was performed, insert rebuttal summaries after contention and before Final Judgment
- If Phase 3.8 adversarial challenge was performed, insert after Final Judgment

Note: This output format is rendered by the MAGI Core agent, not the orchestrator directly.

```
━━━ Final Judgment ━━━
```

| | MELCHIOR | BALTHASAR | CASPAR |
|---|---------|-----------|--------|
| **Verdict** | (verdict) | (verdict) | (verdict) |

- **Overall Verdict:** Approve / Reject / Conditional Approval / Indeterminate
- **Confidence:** High / Medium / Low
- **Conditions:** (Aggregate conditions if any. Otherwise "None")

**Recommended Actions:**
1. (1-3 concrete next steps based on deliberation results)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
