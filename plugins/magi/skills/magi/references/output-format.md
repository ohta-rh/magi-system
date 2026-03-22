# Phase 4: Deliberation Output Format

Report the results in the following format (use Markdown tables for scores, keep ━━━ headers for NERV aesthetic):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI SYSTEM — Deliberation Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Topic:** (state the topic)

### MELCHIOR-1 [Scientist] — Verdict: (verdict)

| Axis | Score |
|------|-------|
| Correctness/Rigor | (1-5) |
| Performance | (1-5) |
| Security | (1-5) |
| Technical Consistency | (1-5) |

> (2-3 line summary: lead with the most important finding, then key reasoning and conditions/concerns if any)

### BALTHASAR-2 [Mother] — Verdict: (verdict)

| Axis | Score |
|------|-------|
| Maintainability | (1-5) |
| Testability | (1-5) |
| Operability | (1-5) |
| Team Impact | (1-5) |

> (2-3 line summary: lead with the most important finding, then key reasoning and conditions/concerns if any)

### CASPAR-3 [Woman] — Verdict: (verdict)

| Axis | Score |
|------|-------|
| Design Elegance | (1-5) |
| Innovation | (1-5) |
| Feasibility | (1-5) |
| Adaptability | (1-5) |

> (2-3 line summary: lead with the most important finding, then key reasoning and conditions/concerns if any)

- If advisory agents are present, add after voting agents:

### Advisory Analysis

#### {AGENT-NAME} [{persona}] (non-voting)

| Axis | Score |
|------|-------|
| (agent's 4 axes) | (1-5) |

> (2-3 line summary)

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
