# Dialectic Phase — Inter-Agent Dialogue

Optional Phase 3.7 that enables agents to respond to each other's findings before the final verdict.

## Activation

Dialectic mode is opt-in. It activates when ANY of these conditions are met:

1. User includes `--dialectic` or `dialectic` flag in the topic
2. `magi.config.json` contains `"dialectic": true`
3. User selects "Run dialectic round" in Phase 5

## Dialectic Round (Phase 3.7)

After Phase 3.5 (contention analysis), if dialectic mode is active:

### Step 1: Prepare Cross-Agent Briefing

For each voting agent, build a briefing containing:
- The other agents' verdicts and average scores (no raw scores — averages only)
- The other agents' Overall Analysis (quoted verbatim)
- The other agents' top risk concern

### Step 2: Launch Rebuttal Agents

Re-spawn each voting agent with a rebuttal prompt:

```
You are {agent name} of the MAGI System. You have completed your initial evaluation.

Your initial verdict: {verdict}. Your initial average score: {avg}.

The other agents concluded:
{cross-agent briefing}

## Task
Write a brief rebuttal or concurrence (3-5 lines). You may revise your scores by +/- 1 on any axis if the other agents raised points you did not consider. State revised scores only if changed. State whether your verdict changes.

Output your response as plain text — no MAGI_OUTPUT block needed.
```

Launch all voting agents in parallel (same model as initial round).

### Step 3: Apply Score Revisions

- If an agent revised scores, update the extracted scores (cap revisions at +/- 1)
- If an agent changed their verdict, update the verdict
- Re-run voting engine with updated verdicts

## Adversarial Mode

On-demand mode triggered by `--adversarial` flag or config `"adversarial": true`.

### Activation Rule

- One agent is assigned the devil's advocate role
- Selection: the agent whose initial verdict most closely matches the emerging consensus
- For 3:0 unanimous: select the agent with the highest average score (most positive)

### Adversarial Prompt

The selected agent is re-spawned with:

```
You are {agent name} in ADVERSARIAL MODE. The council reached {verdict} ({tally}).

Your task: argue AGAINST the consensus. Identify risks, blind spots, and failure modes that the council overlooked. Be ruthless — your role is to stress-test the decision.

Output 5-8 lines of adversarial analysis. No MAGI_OUTPUT block needed.
```

### Output Integration

Adversarial analysis is displayed after the Final Judgment as:

```
### Adversarial Challenge — {agent name}
> (adversarial analysis)
```

This does NOT change the verdict — it supplements it for the user's consideration.
