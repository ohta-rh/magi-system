# MAGI System

A Claude Code plugin that implements the MAGI supercomputer council from Neon Genesis Evangelion for multi-dimensional engineering decision-making.

## Project Structure

```
.claude-plugin/
  marketplace.json          — Marketplace catalog (for /plugin marketplace add)
plugins/magi/
  .claude-plugin/
    plugin.json             — Plugin manifest (v3.0.0)
  skills/magi/
    SKILL.md                — Main skill (orchestrator for /magi command)
    agents/
      melchior.md           — MELCHIOR-1: The Scientist (technical excellence)
      balthasar.md          — BALTHASAR-2: The Mother (sustainability)
      caspar.md             — CASPAR-3: The Woman (pragmatic aesthetics)
    references/
      output-format.md      — Phase 4 output templates (NERV aesthetic)
      judgment-rules.md     — Voting rules and confidence levels
      schema.md             — MAGI_OUTPUT structured output schema
      governance.md         — File size limits and split strategies
      extraction-fallback.md — Prose fallback extraction algorithm
    examples/
      sample-deliberation.md — Example deliberation output
  skills/magi-quick/
    SKILL.md                — Quick triage skill (single-agent, sonnet)
scripts/
  check-sizes.sh            — Plugin file size governance check
  validate-output.sh        — MAGI_OUTPUT JSON schema validator
tests/
  test-extraction.sh        — Extraction test suite runner
  fixtures/                 — Golden test fixtures (valid + malformed)
```

## How It Works

- `SKILL.md` is the orchestrator — it spawns agents in parallel, collects results, and synthesizes the final verdict
- Each agent file in `agents/` defines a persona, cognitive framework, internal deliberation protocol, 4 evaluation axes, research guidelines, and output format
- Agents are spawned as `general-purpose` subagents with `model: opus`
- The `$ARGUMENTS` placeholder is sanitized (prompt injection protection) and wrapped in `<user_topic>` tags before injection
- Agent files are loaded via direct path construction from the skill base directory
- Agents emit structured JSON output (`<!-- MAGI_OUTPUT -->`) for reliable programmatic extraction
- Agent configuration can be customized via `magi.config.json` in the project root (with path validation)
- `/magi-quick` provides lightweight single-agent triage using `model: sonnet` for low-stakes decisions

## Orchestration Phases

| Phase | Description |
|-------|-------------|
| Phase 0 | Topic clarification |
| Phase 1 | Configuration check (`magi.config.json` with path validation) + activation sequence |
| Phase 2 | Input sanitization + parallel agent launch (exactly 3 agents, default or custom) |
| Phase 3 | Result synthesis: structured extraction, prose fallback, contention analysis (2:1 splits) |
| Phase 4 | Deliberation output: per-agent reports, divergence map, judgment rules, risk summary |
| Phase 5 | Interactive drill-down (optional): deep dive, re-evaluate, or accept |

## Conventions

- All skill and agent files are written in English
- Each agent has a Cognitive Framework (persona-specific reasoning approach) and Internal Deliberation Protocol (structured thinking steps before scoring)
- Agent output uses a numeric 1-5 scoring scale (5 = best, 1 = worst)
- Agents include a `<!-- MAGI_OUTPUT {...} -->` structured block at the end of their response
- Overall Analysis is 4-6 lines, leading with the most important deliberation finding
- Verdicts are: Approve / Reject / Conditional Approval
- Final judgment follows majority rule (2:1 or 3:0)
- Partial results: 2/3 = warning + capped confidence; 1/3 or 0/3 = no verdict
- Custom agent configs (`magi.config.json`) must define exactly 3 agents — voting logic requires a 3-member council

## Plugin Health Governance

- File size limits and split strategies are defined in `plugins/magi/skills/magi/references/governance.md`
- Before committing plugin changes, run `bash scripts/check-sizes.sh` to verify all files are within limits
- SKILL.md must stay under 500 lines; agent files under 130 lines; reference/example files under 100 lines
