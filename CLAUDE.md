# MAGI System

A Claude Code plugin that implements the MAGI supercomputer council from Neon Genesis Evangelion for multi-dimensional engineering decision-making.

## Project Structure

```
.claude-plugin/
  marketplace.json          — Marketplace catalog (for /plugin marketplace add)
plugins/magi/
  .claude-plugin/
    plugin.json             — Plugin manifest
  skills/magi/
    SKILL.md                — Main skill (orchestrator for /magi command)
    agents/
      melchior.md           — MELCHIOR-1: The Scientist (technical excellence)
      balthasar.md          — BALTHASAR-2: The Mother (sustainability)
      caspar.md             — CASPAR-3: The Woman (pragmatic aesthetics)
```

## How It Works

- `SKILL.md` is the orchestrator — it uses Glob to discover agent files, spawns three agents in parallel, collects results, and synthesizes the final verdict
- Each agent file in `agents/` defines a persona, 4 evaluation axes, research guidelines, and output format
- Agents are spawned as `general-purpose` subagents with `model: sonnet`
- The `$ARGUMENTS` placeholder in agent prompts is replaced with the actual topic before spawning
- Agent files are discovered dynamically via Glob to support both plugin and manual symlink installation

## Conventions

- All skill and agent files are written in English
- Agent output uses the ◎/○/△/▽/× scoring scale (5/4/3/2/1)
- Verdicts are: Approve / Reject / Conditional Approval
- Final judgment follows majority rule (2:1 or 3:0)
