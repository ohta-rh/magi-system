# Comparison Mode

## Comparison Prompt Template

The orchestrator injects the following as `$ARGUMENTS`. Bracketed placeholders are replaced with actual values.

```
## Comparison Mode — Evaluate ALL options below
Compare the following options. Evaluate EACH option independently on your 4 axes.
Options:
1. [Option A]
2. [Option B]
(additional options if present)
Context: [original user question]
For EACH option: provide 4 axis scores with rationale, 3-4 line analysis, verdict, and risks.
After all options: state your Recommendation (the option you endorse) with rationale and key differentiator.
```

## Agent Output Format (Comparison Mode)

Agents detect this mode by "Comparison Mode — Evaluate ALL options below" in Topic. For each option, output Scores (4 axes), Analysis (3-4 lines), Verdict, and Risks. After all options, output Recommendation with rationale and Key Differentiator. Structured output uses schema v1.1 — see [schema.md](schema.md).

## Phase 4: Comparison Output (Score Matrix Format)

Use a unified Score Matrix to present all agents' evaluations. This eliminates per-agent × per-option section repetition.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI SYSTEM — Comparison Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
**Topic:** (original question)

### Score Matrix

| Agent | Axis | [Option A] | [Option B] |
|-------|------|:---:|:---:|
| MELCHIOR | Correctness/Rigor | (1-5) | (1-5) |
| | Performance | (1-5) | (1-5) |
| | Security | (1-5) | (1-5) |
| | Technical Consistency | (1-5) | (1-5) |
| BALTHASAR | Maintainability | (1-5) | (1-5) |
| | Testability | (1-5) | (1-5) |
| | Operability | (1-5) | (1-5) |
| | Team Impact | (1-5) | (1-5) |
| CASPAR | Design Elegance | (1-5) | (1-5) |
| | Innovation | (1-5) | (1-5) |
| | Feasibility | (1-5) | (1-5) |
| | Adaptability | (1-5) | (1-5) |
| **Average** | | (avg) | (avg) |

### Agent Recommendations

> **MELCHIOR-1 [Scientist]:** Recommends [Option] — (1-2 line rationale with key differentiator from technical perspective)

> **BALTHASAR-2 [Mother]:** Recommends [Option] — (1-2 line rationale with key differentiator from sustainability perspective)

> **CASPAR-3 [Woman]:** Recommends [Option] — (1-2 line rationale with key differentiator from aesthetic/pragmatic perspective)

(Insert contention analysis before Final Recommendation if 2:1 or 1:1:1.)

```
━━━ Final Recommendation ━━━
```
| | MELCHIOR | BALTHASAR | CASPAR |
|---|---------|-----------|--------|
| **Recommendation** | (option) | (option) | (option) |
- **Recommended Option:** [Option]
- **Confidence:** High (3:0) / Medium (2:1) / Low (1:1:1)
- **Key Differentiator:** (from majority/consensus)
**Recommended Actions:**
1. (1-3 next steps)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
