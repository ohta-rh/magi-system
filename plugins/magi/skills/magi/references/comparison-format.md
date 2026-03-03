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

Agents detect this mode by "Comparison Mode — Evaluate ALL options below" in Topic.

```
### [Option Name]
#### Scores
- (axis1): (1-5) (rationale)
- (axis2): (1-5) (rationale)
- (axis3): (1-5) (rationale)
- (axis4): (1-5) (rationale)
#### Analysis
(3-4 lines)
#### Verdict
(Approve / Reject / Conditional Approval)
#### Risks
(1-3 bullets or "None")
```

After all options:

```
### Recommendation
**[Option Name]** — (1-2 line rationale)
### Key Differentiator
(Single most important factor distinguishing the recommended option)
```

Structured output uses schema v1.1. See [schema.md](schema.md) for field definitions.

## Phase 4: Comparison Output

Use per-agent sections matching standard mode ([output-format.md](output-format.md)), with sub-sections per option:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI SYSTEM — Comparison Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Topic:** (original question)

### [AGENT] [Persona]

#### [Option A] — Verdict: (verdict)

| Axis | Score |
|------|-------|
| (agent's 4 axes with scores) |

> (3-5 line summary: lead with the most important finding, then key reasoning and conditions/concerns)

#### [Option B] — Verdict: (verdict)

(same table and summary)

**Recommendation:** [Option] — (1-line rationale)

(Repeat for all 3 agents. Insert contention analysis before Final Recommendation if 2:1 or 1:1:1.)

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
