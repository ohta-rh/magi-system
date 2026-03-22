---
name: magi-premortem
description: "Pre-mortem analysis. Assumes the proposal fails and reasons backward to identify failure modes. Triggered by 'magi pre-mortem', 'magi premortem', 'failure analysis'."
argument-hint: "[proposal or plan to stress-test]"
allowed-tools: Agent, Read, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
---

# MAGI Pre-Mortem — Prospective Failure Analysis

Assume the proposal was implemented and FAILED. Reason backward to explain why.

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

## Phase 3: Synthesize

No MAGI Core needed (no voting). Collect responses and format:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI PRE-MORTEM — Failure Analysis Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MELCHIOR-1 [Technical Failure]
> (failure narrative)

### BALTHASAR-2 [Organizational Failure]
> (failure narrative)

### CASPAR-3 [Strategic Failure]
> (failure narrative)

### Most Likely Failure Mode
Identify the most plausible scenario. Summarize in 2-3 lines: failure path, earliest warning sign, one mitigation.
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
