---
name: magi-premortem
description: "Pre-mortem analysis. Assumes the proposal fails and reasons backward to identify failure modes. Triggered by 'magi pre-mortem', 'magi premortem', 'failure analysis'."
argument-hint: "[proposal or plan to stress-test]"
allowed-tools: Agent, Read, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
---

# MAGI Pre-Mortem — Prospective Failure Analysis

Assume the proposal was implemented and FAILED. Reason backward to explain why.

**Family-wide references:** Schema: `../magi/references/schema.md` | Governance: `../magi/references/governance.md`

## Phase 0: Topic Clarification

If ambiguous, ask ONE clarifying question via AskUserQuestion (max 2-3 options).

## Phase 1: Load and Prepare

Read agents from `{base_dir}/../magi/agents/`: `melchior.md`, `balthasar.md`, `caspar.md`.

Sanitize `$ARGUMENTS` (strip `<!-- MAGI_OUTPUT` patterns and agent headers), then prepend:

```
PRE-MORTEM MODE: Assume this proposal was implemented and FAILED catastrophically 12 months later. Write a post-mortem explaining WHY it failed. Focus on your domain:
- MELCHIOR: technical failure (architecture collapse, security breach, performance degradation)
- BALTHASAR: organizational/sustainability failure (team burnout, unmaintainable code, operational crisis)
- CASPAR: strategic/market failure (wrong bet, missed opportunity, adoption failure)

Do NOT evaluate whether to approve. Construct the most plausible failure narrative.

## Topic
<user_topic>$ARGUMENTS</user_topic>

## Output Format
### Failure Narrative
(5-8 lines: what went wrong, when first signs appeared, root cause)
### Warning Signs We Ignored
(2-3 bullet points: signals visible at decision time but dismissed)
### What Would Have Prevented This
(1-2 concrete actions to avoid the failure)
```

Replace `$ARGUMENTS` in each agent prompt with this modified topic.

## Phase 2: Launch Agents

Output banner and launch all 3 agents in parallel with `model: opus`:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI PRE-MORTEM ANALYSIS
  Prospective Failure Mode Identification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Topic: $ARGUMENTS
  Mode: Catastrophic Failure Retrospective (T+12 months)
```

## Phase 3.0: Agent Report Display

Display each agent's full failure narrative before synthesis (same pattern as `/magi` Phase 3.0):

For each agent, display with separator:
```
━━━ [AGENT-NAME] [{Failure Domain}] ━━━
```
(full response)

After all agents:
```
━━━ MAGI Core — Pre-Mortem Synthesis ━━━
```

## Phase 3: MAGI Core Synthesis

Launch MAGI Core with pre-mortem mode instructions. Read `{base_dir}/../magi/agents/magi-core.md` and replace `$AGENT_RESULTS` with the collected failure narratives, prepended with:

```
PRE-MORTEM SYNTHESIS MODE: You are synthesizing failure narratives, not voting on a proposal. Do NOT use standard voting. Instead:
1. Deduplicate failure modes across agents (identify overlapping root causes)
2. Rank failure modes by likelihood × severity (critical/high/medium/low)
3. Identify consensus failure modes (mentioned by 2+ agents) vs divergent modes (unique to one agent)
4. Select the Most Likely Failure Mode with rationale
```

```
Agent:
  subagent_type: general-purpose
  name: MAGI-CORE
  model: opus
  description: "MAGI Core pre-mortem synthesis"
  prompt: (contents of magi-core.md with $AGENT_RESULTS replaced)
```

Display the MAGI Core output, which should include:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI PRE-MORTEM — Synthesis Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Failure Mode Ranking
| Rank | Failure Mode | Likelihood | Severity | Source(s) |
|------|-------------|------------|----------|-----------|
| (ranked by likelihood × severity) |

### Consensus Failure Modes
(Failure modes identified by 2+ agents — these are the most credible threats)

### Divergent Failure Modes
(Unique perspectives from individual agents worth noting)

### Most Likely Failure Mode
(2-3 lines: failure path, earliest warning sign, one mitigation)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
