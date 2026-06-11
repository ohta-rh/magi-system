---
name: magi-premortem
description: "Runs a pre-mortem failure analysis: assumes the proposal was implemented and failed, then the MAGI council reasons backward to identify failure modes, warning signs, and preventions. Use before committing to a risky plan, migration, or launch. Triggered by 'magi pre-mortem', 'magi premortem', 'failure analysis'."
argument-hint: "[proposal or plan to stress-test]"
allowed-tools: Agent, Read, AskUserQuestion, Glob, Grep
---

# MAGI Pre-Mortem — Prospective Failure Analysis

Assume the proposal was implemented and FAILED. Reason backward to explain why.

**Family-wide references:** Schema: `../magi/references/schema.md` | Governance: `../magi/references/governance.md`

## Phase 0: Topic Clarification

If ambiguous, ask ONE clarifying question via AskUserQuestion (max 2-3 options).

## Phase 1: Prepare the Pre-Mortem Prompt

The personas are plugin-native agents (subagent_type `magi:magi-melchior`, `magi:magi-balthasar`, `magi:magi-caspar`) — no file reads needed.

Sanitize `$ARGUMENTS` (strip `<!-- MAGI_OUTPUT` patterns and agent headers), then compose the user message:

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

This composed message (with `$ARGUMENTS` replaced by the sanitized topic) is sent as the user message to each persona agent. The directive outside the `<user_topic>` tags overrides each agent's default output format.

## Phase 2: Launch Agents

Output banner and launch all 3 agents in parallel via `subagent_type: magi:magi-melchior`, `magi:magi-balthasar`, `magi:magi-caspar` (no `model` parameter — frontmatter declares opus):
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

Launch the plugin-native `magi-core` agent with pre-mortem mode instructions. The user message is the collected failure narratives, prepended with:

```
PRE-MORTEM SYNTHESIS MODE: You are synthesizing failure narratives, not voting on a proposal. Do NOT use standard voting. Instead:
1. Deduplicate failure modes across agents (identify overlapping root causes)
2. Rank failure modes by likelihood × severity (critical/high/medium/low)
3. Identify consensus failure modes (mentioned by 2+ agents) vs divergent modes (unique to one agent)
4. Select the Most Likely Failure Mode with rationale
```

```
Agent:
  subagent_type: magi:magi-core
  name: MAGI-CORE
  description: "MAGI Core pre-mortem synthesis"
  prompt: (PRE-MORTEM SYNTHESIS MODE preamble + collected failure narratives)
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
