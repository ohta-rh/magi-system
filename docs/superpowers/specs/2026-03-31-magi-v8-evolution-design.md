# MAGI v8 Evolution — Design Specification

**Date:** 2026-03-31
**Status:** Draft
**Priority Principle:** Judgment accuracy first, UX transparency second, skill family and tooling follow.

## Context

MAGI v7 focused on observability and feedback infrastructure (issues #75-#82). v8 shifts to judgment quality and user experience, driven by two findings:

1. **Individual agent analyses are invisible to users.** MAGI Core synthesizes 3 agent responses into 2-3 line summaries, discarding rich analysis, research references, and nuanced reasoning. Users cannot evaluate judgment quality because the reasoning is hidden.
2. **Judgment accuracy has room for improvement.** MAGI Core runs on Sonnet (a synthesis-only role assumption), sycophancy detection misses common patterns (score clustering around 3), and agent research depth varies widely without detection or calibration.

## Architecture: Parallel Tracks

| Track | Focus | Priority | Issues |
|-------|-------|----------|--------|
| T1 | Judgment Accuracy | P0 | 1-1 through 1-5 |
| T2 | UX / Display | P0 | 2-1 through 2-4 |
| T3 | Skill Family Consistency | P1 | 3-1 through 3-3 |
| T4 | Tooling & Governance | P1 | 4-1 through 4-3 |

T1 and T2 are independent and can proceed in parallel. T3 depends on T1 completion (shared output schema changes). T4 supports T1 validation.

---

## Track 1: Judgment Accuracy (P0)

### Issue 1-1: MAGI Core Model Upgrade (Sonnet → Opus)

**Current state:** MAGI Core runs with `model: sonnet`. The SKILL.md comment states "its task is synthesis/extraction/formatting, not deep reasoning."

**Problem:** In practice, MAGI Core performs sycophancy detection, contention analysis, cross-agent tension identification, and confidence calibration. These are reasoning tasks. Sonnet may miss subtle bias patterns and produce shallow contention analysis.

**Change:**
- In `SKILL.md` Phase 3 Step 3, change `model: sonnet` to `model: opus`
- Remove the comment justifying sonnet usage
- Update `references/output-format.md` if it references the model choice

**Impact:** Higher token cost per deliberation. Expected improvement in bias detection accuracy and contention analysis depth.

**Validation:** Compare 5 deliberation logs (before/after) on benchmark fixtures. MAGI Core should identify at least 1 additional bias flag per fixture that sonnet missed.

### Issue 1-2: Agent Research Tracking in MAGI_OUTPUT

**Current state:** Agents "may" use WebSearch per their Research Guidelines. No structured tracking of whether research was conducted.

**Problem:** In the Nikkei 225 deliberation, MELCHIOR and CASPAR conducted extensive web research (12+ sources each) while BALTHASAR conducted zero. MAGI Core had no visibility into this asymmetry and could not calibrate accordingly.

**Change:**
- Add `research_conducted: boolean` and `research_sources_count: number` fields to `MAGI_OUTPUT` schema (v1.2). "Research" means use of WebSearch/WebFetch for external data — codebase exploration via Glob/Grep/Read does not count
- Update `references/schema.md` with new fields
- Update all 3 agent files to emit these fields
- Update `magi-core.md` extraction to read these fields
- Add MAGI Core calibration rule: if an agent did not research AND the topic requires current/external data, flag as "unverified assessment" and note in Calibration Notes

**Impact:** Better-informed confidence calibration. Transparent research asymmetry.

**Validation:** New E2E test fixture with one agent's MAGI_OUTPUT having `research_conducted: false` on a topic requiring research. MAGI Core should flag it.

### Issue 1-3: Score Clustering Bias Detection

**Current state:** Sycophancy detection checks for "all scores >= 4" and overcorrection checks for "all scores <= 2". No detection of "safe middle" clustering.

**Problem:** Agents may avoid controversy by giving all scores in the 2-4 range with minimal differentiation (e.g., 3, 3, 3, 3 or 3, 2, 3, 2). This "ambiguity avoidance" pattern is a form of epistemic cowardice — the agent has an opinion but hedges.

**Change:**
- Add to `magi-core.md` sycophancy detection rules: "Score clustering — flag if ALL scores fall within a range of 1 (e.g., all between 2 and 3, or all between 3 and 4) AND rationales lack specific quantitative evidence"
- The "AND" condition prevents false positives: if an agent genuinely evaluates all axes as similar with strong evidence, that is valid

**Impact:** Catches the most common soft bias pattern: "play it safe with 3s."

**Validation:** New E2E fixture with clustered scores (3,3,3,3 with vague rationales). MAGI Core should flag as score clustering bias.

### Issue 1-4: Verdict-Risk Consistency Check Enhancement

**Current state:** MAGI Core flags "Approve verdict but risks warrant Conditional Approval" as sycophancy. However, the check is not granular — it does not distinguish risk severity levels when checking consistency.

**Problem:** An agent may give Approve while listing a critical-severity risk. The current check may not catch this if the risk is embedded in prose rather than clearly labeled.

**Change:**
- Add to `magi-core.md`: "If any agent lists a risk that MAGI Core classifies as critical AND that agent's verdict is Approve (not Conditional), flag as verdict-risk inconsistency. This is a stronger signal than generic sycophancy — it indicates the agent recognized the risk but did not let it affect the verdict."
- This is a refinement of the existing rule, not a new rule

**Impact:** More precise inconsistency detection. Fewer false negatives on serious sycophancy.

**Validation:** Existing E2E tests should continue to pass. New fixture with Approve verdict + critical risk in risks array.

### Issue 1-5: Cross-Agent Blind Spot Identification

**Current state:** Only CASPAR's Internal Deliberation Protocol includes "Identify what the other two miss." MELCHIOR and BALTHASAR do not have an equivalent step.

**Problem:** MELCHIOR focuses solely on technical axes. BALTHASAR focuses solely on sustainability axes. Neither is prompted to consider what their evaluation framework cannot see. This creates systematic blind spots that MAGI Core must compensate for.

**Change:**
- Add to MELCHIOR's Internal Deliberation Protocol step 5: "Name one risk or consideration that your 4 axes cannot capture — a sustainability, political, or human factor that falls outside your scientific framework but could affect the outcome."
- Add to BALTHASAR's Internal Deliberation Protocol step 5: "Name one risk or consideration that your 4 axes cannot capture — a technical, competitive, or strategic factor that falls outside your sustainability framework but could affect the outcome."
- This creates a structured "humility step" that enriches MAGI Core's synthesis material

**Impact:** Richer input for MAGI Core contention analysis. Agents explicitly acknowledge their own limitations.

**Validation:** Run benchmark fixtures. Each agent should include a blind spot acknowledgment in their output. MAGI Core should reference these in Key Trade-offs section.

---

## Track 2: UX / Display (P0)

### Issue 2-1: Phase 3.0 — Individual Agent Report Display

**Current state:** Agent responses are collected and passed directly to MAGI Core. Users see only MAGI Core's synthesized output.

**Problem:** Users cannot evaluate judgment quality, verify research accuracy, or understand each MAGI's unique perspective. The user explicitly identified this as the primary UX problem.

**Change:**
- Add "Phase 3.0: Agent Report Display" between Phase 2 (agent return) and Phase 3 Step 2 (MAGI Core input construction)
- In Phase 3.0, for each agent response:
  1. Output `### [AGENT-NAME] — [Persona Title]` header
  2. Display the agent's full human-readable analysis (Scores section through References)
  3. Strip the `<!-- MAGI_OUTPUT {...} -->` block from display (it is internal)
  4. Add a separator between agents
- After all agents displayed, output: `━━━ MAGI Core — Integrated Judgment ━━━`
- Proceed to Phase 3 Step 2 (MAGI Core launch) as before

**Flow change:**
```
Before: Phase 2 → (agents return silently) → Phase 3 MAGI Core → display
After:  Phase 2 → (agents return) → Phase 3.0 display each → Phase 3 MAGI Core → display
```

**Impact:** Token output increases significantly (each agent's full analysis is displayed). Total deliberation token count approximately doubles. Users gain full transparency.

**Validation:** Manual test: run a MAGI deliberation and verify all 3 agent analyses appear before MAGI Core output.

### Issue 2-2: MAGI Core Output Refocus on Meta-Analysis

**Current state:** MAGI Core output includes per-agent sections with "verdict + 4 axes table + 2-3 line summary" — effectively re-summarizing what agents already said.

**Problem:** With Issue 2-1 implemented, per-agent summaries in MAGI Core become redundant. Users will have already read the full analyses.

**Change:**
- Remove per-agent individual summary sections from MAGI Core output format
- Replace with a compact vote tally table (name, persona, verdict, avg score — one line per agent, no analysis text)
- MAGI Core output focuses exclusively on:
  1. **Vote Tally Table** (compact)
  2. **Calibration Notes** (bias detection results)
  3. **Contention Analysis** (if non-unanimous)
  4. **Key Trade-offs** (cross-agent tensions)
  5. **Final Judgment** (verdict, confidence, conditions, risk summary, actions)
- Update `magi-core.md` output format section
- Update `references/output-format.md`

**Impact:** MAGI Core output becomes shorter and more focused. Total token output (agents + Core) may be comparable to current total since Core output shrinks while agent output is added.

**Validation:** MAGI_JUDGMENT block should contain the same fields. E2E tests for vote tally and dissenter ID should continue to pass.

### Issue 2-3: Phase 5 Interaction Enhancement

**Current state:** Phase 5 options are: deep dive dissenter (2:1 only), re-evaluate, run dialectic, run adversarial, accept. 3:0 Unanimous Approve skips Phase 5 entirely.

**Problem:** Users may want follow-up interaction even on unanimous verdicts. The current design assumes unanimous = done, but users may want to challenge a unanimous approve or understand a specific axis deeper.

**Change:**
- 3:0 Unanimous Approve: offer Phase 5 with options "Ask a follow-up question" and "Accept verdict" (was: skip entirely)
- All verdicts: add option "Ask [specific agent] to elaborate on [specific axis]" — user selects agent and axis from the deliberation
- All verdicts: add option "Export deliberation as markdown" — writes the full deliberation (Phase 3.0 outputs + MAGI Core output) to `.magi/exports/{timestamp}.md`
- Update Phase 5 implementation in SKILL.md

**Impact:** More user agency. Slightly more complex Phase 5 logic.

**Validation:** Manual test: run a deliberation that produces 3:0 Approve. Verify Phase 5 is offered (not skipped).

### Issue 2-4: Localized Summary in User's Language

**Current state:** All MAGI output is in English (per CLAUDE.md rule: "All plugin files must be English only"). Users who are not native English speakers face a comprehension barrier on the final output.

**Problem:** The "English only" rule is appropriate for skill files, agent definitions, and references (source code). But the runtime output is not a file — it is a conversation with the user. Forcing English output on non-English users degrades UX without any code-quality benefit.

**Change:**
- Add to `magi-core.md` output instructions: "After the Final Judgment section and before the MAGI_JUDGMENT block, if the topic was submitted in a non-English language, append a `### Summary (user's language)` section. This section provides a 5-8 line summary of the verdict, key conditions, and top risks in the user's language."
- This does NOT change the CLAUDE.md rule: skill files, agent files, and references remain English-only. Only runtime output adapts.
- MAGI Core detects language from the topic text in the input data block using character set and linguistic patterns (e.g., CJK characters → Japanese/Chinese, Hangul → Korean). If detection is ambiguous, default to English-only output

**Impact:** Non-English users get an accessible summary without sacrificing the English-only source code convention.

**Validation:** Submit a topic in Japanese. Verify MAGI Core output ends with a Japanese summary section before the MAGI_JUDGMENT block.

---

## Track 3: Skill Family Consistency (P1)

### Issue 3-1: magi-premortem MAGI Core Integration

**Current state:** `/magi-premortem` launches 3 agents with pre-mortem prompts and displays their raw failure narratives. There is no MAGI Core synthesis step. A "Most Likely Failure Mode" is selected manually by the orchestrator.

**Problem:** Without MAGI Core integration, premortem results lack: deduplication of overlapping failure modes, severity ranking, cross-agent pattern detection, and structured output (no MAGI_JUDGMENT).

**Change:**
- Add a MAGI Core synthesis step to `magi-premortem/SKILL.md`
- Create a premortem-specific input format for MAGI Core (or add a mode flag to magi-core.md)
- MAGI Core in premortem mode: rank failure modes by likelihood × severity, deduplicate, identify consensus failure modes vs divergent ones, emit structured output
- Display raw agent analyses first (consistent with Issue 2-1), then MAGI Core synthesis

**Dependencies:** Issue 2-1 pattern (display agents first, then Core). Should be implemented after T2.

**Impact:** Consistent quality across the skill family. Premortem results become more actionable.

### Issue 3-2: magi-quick Structured Output and Logging

**Current state:** `/magi-quick` uses a single Sonnet agent for rapid triage. No `MAGI_OUTPUT` block emitted. No deliberation log written.

**Problem:** Quick assessments are invisible to the v7 observability pipeline (issues #76-#78). Cannot track accuracy or identify systematic biases in quick-mode judgments.

**Change:**
- Add MAGI_OUTPUT block to magi-quick's output format (using the same schema v1.2 but with only the selected agent's axes)
- Add deliberation log writing with `"mode": "quick"` tag in the log JSON
- Add `"agent_count": 1` to distinguish from full deliberations in metrics analysis

**Impact:** Quick assessments enter the observability pipeline. Accuracy tracking becomes comprehensive.

### Issue 3-3: Shared Reference Consolidation

**Current state:** Each skill variant has its own understanding of output format, scoring schema, and governance rules. Some rules are duplicated; others are implicit.

**Problem:** Changes to schema or output format must be manually propagated across skill variants. Risk of drift.

**Change:**
- Identify references that apply across the skill family: `schema.md`, `governance.md`, `extraction-fallback.md`
- Add explicit cross-references from skill variant SKILL.md files to shared references
- Document which references are skill-specific vs family-wide in `governance.md`

**Impact:** Reduced maintenance burden. Consistent behavior across skill family.

---

## Track 4: Tooling & Governance (P1)

### Issue 4-1: Governance Limit Review

**Current state:** Agent files: 130 lines. MAGI Core: 160 lines (currently 75). References: 100 lines.

**Problem:** Issue 1-5 (blind spot identification step) adds content to agent files. Current limits may be too restrictive for richer cognitive frameworks.

**Change:**
- Agent files: 130 → 150 lines (+20 for blind spot step and potential future enrichment)
- MAGI Core: 160 → 200 lines (accommodate Issue 1-1's enhanced detection rules and Issue 2-2's refocused output format)
- References: 100 lines (unchanged — references should stay concise)
- Update `references/governance.md` and `scripts/check-sizes.sh`

**Impact:** Accommodates T1 improvements without governance violations.

**Validation:** Run `bash scripts/check-sizes.sh` after all T1 changes. All files should pass.

### Issue 4-2: E2E Test Expansion for New Detection Patterns

**Current state:** 8 E2E tests in `tests/test-e2e.sh`. No tests for: score clustering bias, verdict-risk inconsistency, research tracking.

**Change:**
- Add fixture: `fixtures/clustered-scores.json` — all scores 3±0.5 with vague rationales. Expected: MAGI Core flags score clustering
- Add fixture: `fixtures/approve-critical-risk.json` — Approve verdict with critical risk. Expected: MAGI Core flags verdict-risk inconsistency
- Add fixture: `fixtures/no-research-flag.json` — agent output with `research_conducted: false` on data-dependent topic. Expected: MAGI Core flags unverified assessment
- Update `tests/test-e2e.sh` to include new fixtures

**Impact:** Regression protection for T1 accuracy improvements.

### Issue 4-3: Benchmark Regression Automation

**Current state:** `scripts/benchmark-regression.sh` exists but requires manual execution. No CI integration.

**Change:**
- Add benchmark regression to `.githooks/pre-commit` (alongside existing governance check)
- Pre-commit runs: governance check + extraction test + benchmark regression
- Benchmark regression: compare current prompt outputs against golden fixtures, flag divergence above threshold

**Impact:** Prompt changes that degrade accuracy are caught before commit.

---

## Dependency Graph

```
T1-1 (Core Opus) ─────────────────────────────────── independent
T1-2 (Research Tracking) ──── T1-2 requires schema.md update
T1-3 (Score Clustering) ──── T1-3 requires magi-core.md update
T1-4 (Verdict-Risk Check) ── T1-4 requires magi-core.md update
T1-5 (Blind Spot Step) ───── T1-5 requires agent file updates

T2-1 (Agent Display) ─────── independent
T2-2 (Core Refocus) ──────── depends on T2-1
T2-3 (Phase 5 Enhance) ───── independent
T2-4 (Localized Summary) ─── depends on T2-2 (Core output format change)

T3-1 (Premortem Core) ─────── depends on T2-1 pattern
T3-2 (Quick Structured) ──── depends on T1-2 (schema v1.2)
T3-3 (Shared References) ─── depends on T1-2 (schema update)

T4-1 (Governance Limits) ─── depends on T1-5 (to know actual size needs)
T4-2 (E2E Expansion) ──────── depends on T1-2, T1-3, T1-4
T4-3 (Benchmark Automation) ─ independent
```

## Implementation Order (Suggested)

**Wave 1 (independent, parallelizable):**
- T1-1: MAGI Core Opus upgrade
- T2-1: Phase 3.0 Agent Report Display
- T2-3: Phase 5 Interaction Enhancement
- T4-3: Benchmark Regression Automation

**Wave 2 (depends on Wave 1):**
- T1-2: Research Tracking (schema v1.2)
- T1-3: Score Clustering Detection
- T1-4: Verdict-Risk Consistency
- T1-5: Blind Spot Identification
- T2-2: MAGI Core Output Refocus (after T2-1)

**Wave 3 (depends on Wave 2):**
- T2-4: Localized Summary (after T2-2)
- T4-1: Governance Limit Review (after T1-5)
- T4-2: E2E Test Expansion (after T1-2, T1-3, T1-4)

**Wave 4 (depends on Wave 2-3):**
- T3-1: Premortem Core Integration
- T3-2: Quick Structured Output
- T3-3: Shared Reference Consolidation
