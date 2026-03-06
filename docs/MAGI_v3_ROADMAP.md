# MAGI System v3 Roadmap

> Generated from MAGI Self-Diagnosis Deliberation (2026-03-06)
> Verdict: 3:0 Conditional Approval — all three MAGI identified critical evolution paths

## Executive Summary

MAGI v2 has reached the **local maximum of a read-only deliberation system**. The architecture is elegant, personas are well-differentiated, and governance is disciplined. However, six structural gaps prevent the system from becoming an indispensable engineering workflow tool:

1. No feedback loop (tests, metrics, learning)
2. No verdict-to-action pipeline
3. Prompt injection vulnerability
4. Agent output validation gap
5. Hardcoded 3-agent constraint
6. Agent isolation (no inter-agent dialogue)

## Priority Matrix

| Priority | Initiative | Impact | Effort | Source |
|----------|-----------|--------|--------|--------|
| P0 | Test & Validation Layer | High | Medium | MELCHIOR + BALTHASAR |
| P0 | Prompt Injection Hardening | High | Low | MELCHIOR |
| P1 | Verdict-to-Action Pipeline | Very High | High | CASPAR |
| P1 | Lightweight Triage Mode | High | Medium | CASPAR |
| P2 | Structured Observability | Medium | Medium | BALTHASAR |
| P3 | N-Agent Abstraction | Medium | High | MELCHIOR |
| P3 | Inter-Agent Dialogue | High | Very High | CASPAR |

---

## P0: Foundation — Test & Validation Layer

### Problem
- MAGI_OUTPUT schema is defined in prose but never validated programmatically
- Agent output conformance rate is unmeasured
- Prose fallback extraction in Phase 3 Step 2 is algorithmically undefined
- check-sizes.sh is the only automated verification (line counts only)

### Solution

#### 0-1: MAGI_OUTPUT JSON Schema Validator
- Create `scripts/validate-output.sh` that accepts agent output text and:
  - Extracts `<!-- MAGI_OUTPUT {...} -->` block via regex
  - Validates JSON against schema.md rules (verdict enum, score range 1-5, required fields)
  - Reports conformance or specific validation errors
- Can be used in CI and as a post-deliberation check

#### 0-2: Golden Output Test Suite
- Create `tests/` directory with:
  - `tests/fixtures/valid-output-v1.0.txt` — known-good agent outputs
  - `tests/fixtures/valid-output-v1.1.txt` — known-good comparison mode outputs
  - `tests/fixtures/malformed-*.txt` — edge cases (missing fields, bad JSON, no MAGI_OUTPUT block)
  - `tests/test-extraction.sh` — validates that extraction logic handles all fixtures correctly

#### 0-3: Prose Fallback Specification
- Define the algorithmic fallback in `references/extraction-fallback.md`:
  - Regex patterns for verdict line extraction
  - Score extraction from `(N)` patterns in axis lines
  - Confidence level for prose-extracted vs JSON-extracted results
  - When to treat as malformed vs. successfully extracted

### Success Criteria
- All golden test fixtures pass validation
- Malformed outputs are correctly classified as failures
- check-sizes.sh + validate-output.sh run in pre-commit hook

---

## P0: Foundation — Prompt Injection Hardening

### Problem
- `$ARGUMENTS` is injected verbatim into agent prompts with no sanitization
- A crafted topic could override agent instructions, corrupt scoring, or exfiltrate context
- `magi.config.json` file paths are read without directory traversal validation

### Solution

#### 0-4: $ARGUMENTS Sanitization
- In SKILL.md Phase 2, add a sanitization step before prompt injection:
  - Strip `<!-- MAGI_OUTPUT` patterns from user input (prevents output spoofing)
  - Strip system prompt override attempts (`## Your Persona`, `## Procedure`, etc.)
  - Wrap user topic in a clearly delimited block:
    ```
    <user_topic>
    {sanitized $ARGUMENTS}
    </user_topic>
    ```
  - Agent prompts reference `<user_topic>` block instead of inline substitution

#### 0-5: Config Path Validation
- In SKILL.md Phase 1 Step 0, validate `magi.config.json` agent file paths:
  - Reject paths containing `..` or absolute paths outside the project
  - Verify each file path resolves to a `.md` file within the project tree

### Success Criteria
- Topics containing prompt override attempts are safely contained
- Config file paths are validated before Read calls

---

## P1: Verdict-to-Action Pipeline

### Problem
- MAGI produces beautiful reports that end at the verdict
- Structured MAGI_OUTPUT JSON exists but connects to nothing downstream
- Gap between "decision made" and "action taken" is the adoption ceiling

### Solution

#### 1-1: Decision Log
- After Phase 4, append deliberation summary to `docs/magi-decisions.jsonl`:
  ```json
  {
    "timestamp": "2026-03-06T10:30:00Z",
    "topic": "...",
    "verdicts": {"MELCHIOR": "...", "BALTHASAR": "...", "CASPAR": "..."},
    "overall": "Approve",
    "confidence": "High",
    "conditions": ["..."],
    "scores_summary": {"MELCHIOR_avg": 3.0, "BALTHASAR_avg": 2.75, "CASPAR_avg": 3.75}
  }
  ```
- Enables trend analysis, quality tracking, and institutional memory

#### 1-2: Action Generation Mode (--execute flag)
- New Phase 6 (opt-in): After verdict, generate actionable outputs:
  - **GitHub Issues**: Convert Recommended Actions into structured issues
  - **Implementation Tasks**: Break conditions into concrete development tasks
  - **Branch + PR scaffold**: Create feature branch with TODO-annotated files
- Triggered by user opt-in at Phase 5, not automatic

#### 1-3: CI Integration Hook
- `scripts/magi-ci.sh` — headless MAGI invocation for PR review:
  - Accepts diff or file list as input
  - Outputs verdict as PR comment or CI check status
  - Uses structured MAGI_OUTPUT for pass/fail determination

### Success Criteria
- Every deliberation is logged to decision log
- Users can opt into action generation after any verdict
- CI integration runs MAGI as automated reviewer

---

## P1: Lightweight Triage Mode

### Problem
- Three Opus calls per deliberation is expensive for exploratory use
- Users self-censor, reserving MAGI for "big decisions" only
- 69 wrong_approach incidents suggest topics that don't fit the full deliberation paradigm

### Solution

#### 1-4: Quick Mode (/magi-quick)
- Single-agent rapid assessment using one randomly selected MAGI persona
- Uses `model: sonnet` instead of `opus` for cost efficiency
- Output: 3-line summary + single verdict + recommendation (full MAGI or accept)
- Serves as triage gate: "Is this topic worth a full MAGI deliberation?"

#### 1-5: Enhanced Phase 0 Clarification
- Add topic complexity scoring to Phase 0:
  - **Simple** (yes/no, single dimension): Suggest quick mode
  - **Standard** (multi-dimensional, clear scope): Proceed to full deliberation
  - **Complex** (cross-cutting, organizational impact): Proceed with extended research
- Reduces wrong_approach by matching deliberation depth to topic complexity

### Success Criteria
- Quick mode completes in <30s at ~1/6 the cost of full deliberation
- Wrong_approach rate decreases measurably after Phase 0 enhancement

---

## P2: Structured Observability

### Problem
- No logging, no metrics, no way to diagnose the 112 reported incidents
- When an agent produces malformed output, no structured error reporting
- No way to track quality trends over time

### Solution

#### 2-1: Deliberation Metrics
- Track per-deliberation:
  - Agent response times, token usage
  - Output conformance (valid JSON / prose fallback / malformed)
  - Verdict distribution over time
  - Contention frequency (2:1 splits vs unanimous)
- Store in `docs/magi-metrics.jsonl`

#### 2-2: Error Classification
- When partial results occur (Phase 3 Step 1), log structured error:
  - Which agent failed, error type (timeout / malformed / missing)
  - Whether prose fallback was attempted and succeeded
- Feed into decision log for root cause analysis

### Success Criteria
- Every deliberation produces a metrics record
- Error patterns are identifiable from logged data

---

## P3: Future — N-Agent Abstraction

### Problem
- Voting logic (2:1, 3:0, 1:1:1) is hardcoded across SKILL.md, judgment-rules.md, and contention analysis
- Any expansion to N agents requires touching multiple files with no abstraction layer

### Solution

#### 3-1: Voting Logic Abstraction
- Extract voting rules into `references/voting-engine.md`:
  - Parameterize by agent count N
  - Define majority/minority thresholds for arbitrary N
  - Contention analysis generalizes to (N-1):1 splits
- SKILL.md references the voting engine rather than embedding logic

#### 3-2: Specialist Agent Pool
- Beyond the core 3, allow optional specialist agents:
  - Domain experts (e.g., "Database Specialist", "Frontend Architect")
  - Spawn as advisory (non-voting) agents alongside the core council
  - Their analysis is included in the report but does not affect the vote

### Success Criteria
- Voting logic works correctly for N=3 (default) and N=5 (extended)
- Advisory agents enrich analysis without breaking voting math

---

## P3: Future — Inter-Agent Dialogue

### Problem
- Current model is three parallel monologues, not a council debate
- Agents cannot challenge each other's assumptions
- Most valuable possible feature — genuine dialectic — is architecturally impossible

### Solution

#### 3-3: Deliberation Round 2 (Dialectic Phase)
- After initial parallel evaluation (current Phase 2-3):
  - Share anonymized scores and key findings across agents
  - Each agent issues a brief rebuttal or concurrence (2-3 lines)
  - Agents may revise scores by +/- 1 based on new information
- Adds one additional round of agent calls but dramatically increases analysis depth

#### 3-4: Adversarial Mode
- On-demand mode where one agent is assigned "devil's advocate" role
- Forced to argue against the emerging consensus
- Particularly valuable for 3:0 unanimous results where groupthink risk is highest

### Success Criteria
- Dialectic phase produces measurably different verdicts in >20% of deliberations
- Adversarial mode surfaces concerns not found in standard mode

---

## Implementation Timeline

```
Phase 0 (Immediate — Week 1-2):
  [P0] MAGI_OUTPUT JSON validator + golden test suite
  [P0] $ARGUMENTS sanitization + config path validation

Phase 1 (Short-term — Week 3-6):
  [P1] Decision log (magi-decisions.jsonl)
  [P1] Quick mode (/magi-quick)
  [P1] Enhanced Phase 0 topic complexity scoring

Phase 2 (Mid-term — Week 7-10):
  [P1] Action generation mode (Phase 6)
  [P1] CI integration hook
  [P2] Deliberation metrics + error classification

Phase 3 (Long-term — Week 11+):
  [P3] Voting logic abstraction
  [P3] Specialist agent pool
  [P3] Inter-agent dialectic phase
  [P3] Adversarial mode
```

## Governance Note

This roadmap adheres to MAGI plugin governance rules:
- New reference files must stay under 100 lines
- New scripts must include size verification
- Agent files must remain self-contained and independently spawnable
- Any SKILL.md growth beyond 400 lines triggers extraction to reference files

---

*"The MAGI system exists to render judgment. But judgment without action is mere contemplation. v3 closes that gap."* — CASPAR-3
