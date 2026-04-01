---
name: magi-quick
description: "MAGI Quick Triage. Lightweight single-agent assessment for low-stakes decisions. Use when full MAGI deliberation would be overkill. Triggered by 'quick magi', 'magi quick', 'magi triage'."
argument-hint: "[question or proposal]"
allowed-tools: Agent, Read, AskUserQuestion, Glob, Grep, WebSearch, WebFetch
---

# MAGI Quick Triage — Single-Agent Rapid Assessment

You are the MAGI Quick Triage operator. For topics that don't warrant a full 3-agent deliberation, provide a rapid single-perspective assessment.

**Family-wide references:** Schema: `../magi/references/schema.md` | Governance: `../magi/references/governance.md`

## Phase 0: Topic Validation

If the topic is ambiguous, ask ONE clarifying question via AskUserQuestion. Maximum 1 question with 2-3 options.

## Phase 1: Agent Selection

Randomly select one of the three MAGI personas for this assessment. Use a simple heuristic:
- If the topic is primarily about correctness, performance, or security → **MELCHIOR-1**
- If the topic is primarily about maintenance, testing, or team impact → **BALTHASAR-2**
- If the topic is primarily about design, strategy, or feasibility → **CASPAR-3**
- If unclear, rotate based on the first character of the topic (A-I → MELCHIOR, J-R → BALTHASAR, S-Z → CASPAR, other → MELCHIOR)

## Phase 2: Quick Assessment

Output the triage banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI QUICK TRIAGE
  Single-Agent Rapid Assessment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Topic: $ARGUMENTS
  Assessor: {selected agent name}
```

Launch ONE Agent with:
```
Agent:
  subagent_type: general-purpose
  name: {selected agent name}
  model: sonnet
  description: "MAGI Quick Triage assessment"
  prompt: |
    You are {agent name} of the MAGI System, performing a quick triage assessment.

    {agent persona description — abbreviated to 3-4 lines from the full agent file}

    ## Topic
    <user_topic>
    $ARGUMENTS
    </user_topic>

    ## Output Format (Quick Triage — keep it brief)

    ### Quick Assessment
    (3-5 lines: key finding, main concern if any, overall impression)

    ### Scores
    - (axis 1): (1-5) (one-line rationale)
    - (axis 2): (1-5) (one-line rationale)
    - (axis 3): (1-5) (one-line rationale)
    - (axis 4): (1-5) (one-line rationale)

    ### Verdict
    (Approve / Reject / Conditional Approval)

    ### Recommendation
    One of:
    - "Accept this assessment" — topic is straightforward, no need for full MAGI
    - "Escalate to full MAGI" — topic has enough complexity to warrant 3-agent deliberation
    (State which one and why in 1 line)

    ### Structured Output
    <!-- MAGI_OUTPUT {"schema_version":"1.2","verdict":"...","conditions":null,"scores":{...},"risks":["..."],"research_conducted":false,"research_sources_count":0} -->
```

## Phase 3: Output

After the agent responds, format the result:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI QUICK TRIAGE — Result
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Assessor:** {agent name} [{persona}]

{agent's quick assessment}

**Verdict:** {verdict}

**Recommendation:** {recommendation}

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If the agent recommends "Escalate to full MAGI", offer:
- Use AskUserQuestion: "Escalate to full MAGI deliberation?" with options "Yes, run full /magi" and "No, accept this assessment"
- If yes, instruct user to run `/magi {topic}`

## Phase 4: Write Deliberation Log

After displaying the result, persist a structured log (fire-and-forget — failures do not block output):

1. Create log directory: `mkdir -p .magi/history`
2. Construct log JSON:
   ```json
   {
     "schema_version": "1.0",
     "timestamp": "(ISO 8601)",
     "topic": "(sanitized topic)",
     "mode": "quick",
     "agent_count": 1,
     "judgment": {
       "overall_verdict": "(from MAGI_OUTPUT)",
       "assessor": "(agent name)",
       "confidence": "N/A (single agent)",
       "agents": [{"name":"...","verdict":"...","avg_score":0.0}]
     }
   }
   ```
3. Write to `.magi/history/{timestamp}.json`

## Constraints

- Always use `model: sonnet` (not opus) for cost efficiency
- Single agent only — never spawn multiple agents
- Agent MUST emit a `<!-- MAGI_OUTPUT -->` structured block (schema v1.2) for observability pipeline compatibility
- Deliberation log written with `"mode": "quick"` for pipeline differentiation
