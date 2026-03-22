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
    SKILL.md                — Main skill (thin orchestrator for /magi command)
    agents/
      magi-core.md          — MAGI Core: Integrated judgment intelligence (synthesis, bias detection)
      melchior.md           — MELCHIOR-1: The Scientist (technical excellence, anti-sycophancy)
      balthasar.md          — BALTHASAR-2: The Mother (sustainability)
      caspar.md             — CASPAR-3: The Woman (pragmatic aesthetics)
    references/
      output-format.md      — Output templates reference (NERV aesthetic)
      judgment-rules.md     — Voting rules and confidence levels
      voting-engine.md      — Parameterized N-agent voting logic
      dialectic-format.md   — Inter-agent dialogue and adversarial mode
      schema.md             — MAGI_OUTPUT + MAGI_JUDGMENT structured output schemas
      comparison-format.md  — Comparison prompt template + Phase 4 format
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

- `SKILL.md` is the thin orchestrator — it spawns persona agents in parallel, collects results, and delegates judgment to MAGI Core
- **MAGI Core** (`agents/magi-core.md`) is the integrated judgment intelligence — it handles extraction, voting, contention analysis, sycophancy detection, and output formatting. This ensures true encapsulation: the orchestrator does not perform judgment
- Each persona agent file in `agents/` defines a persona, cognitive framework, internal deliberation protocol, 4 evaluation axes, research guidelines, and output format
- **MELCHIOR-1** has explicit anti-sycophancy instructions, leveraging Claude's meta-sycophancy tendency to produce genuinely critical, unflinching scientific assessment
- **MAGI Core detects sycophancy** (忖度) in agent responses — flagging inflated scores, missing critical findings, and bias patterns. It also detects overcorrection (reverse sycophancy). Confidence is reduced when bias is detected
- Agents are spawned as `general-purpose` subagents with `model: opus`
- The `$ARGUMENTS` placeholder is sanitized (prompt injection protection) and wrapped in `<user_topic>` tags before injection
- Agent files are loaded via direct path construction from the skill base directory
- Persona agents emit `<!-- MAGI_OUTPUT -->` structured JSON; MAGI Core emits `<!-- MAGI_JUDGMENT -->` for orchestrator parsing
- Agent configuration can be customized via `magi.config.json` in the project root (with path validation)
- `/magi-quick` provides lightweight single-agent triage using `model: sonnet` for low-stakes decisions

## Orchestration Phases

| Phase | Description |
|-------|-------------|
| Phase 0 | Topic clarification |
| Phase 1 | Configuration check (`magi.config.json` with path validation) + activation sequence |
| Phase 2 | Input sanitization + parallel persona agent launch (voting + advisory agents) |
| Phase 3 | Judgment via MAGI Core: collect responses, launch synthesis agent (extraction, voting, bias detection, output) |
| Phase 3.7 | Dialectic round (optional): inter-agent rebuttals, re-invoke MAGI Core with updated data |
| Phase 3.8 | Adversarial challenge (optional): devil's advocate stress-test |
| Phase 5 | Interactive drill-down (optional): deep dive, dialectic, adversarial, re-evaluate, accept |

## Conventions

- **All plugin files (skills, agents, references, examples) MUST be written entirely in English.** No Japanese or other non-English content in any plugin files, including examples and sample outputs
- All skill and agent files are written in English
- Each agent has a Cognitive Framework (persona-specific reasoning approach) and Internal Deliberation Protocol (structured thinking steps before scoring)
- Agent output uses a numeric 1-5 scoring scale (5 = best, 1 = worst)
- Agents include a `<!-- MAGI_OUTPUT {...} -->` structured block at the end of their response
- Overall Analysis is 4-6 lines, leading with the most important deliberation finding
- Verdicts are: Approve / Reject / Conditional Approval
- MAGI Core performs sycophancy detection (忖度検知) on all agent responses, flagging inflated scores and missing critical analysis. Confidence is reduced by one level when bias is detected
- Final judgment follows parameterized majority rule (N-agent voting engine), with bias calibration by MAGI Core
- Partial results: (N-1)/N = warning + capped confidence; < ceil(N/2) = no verdict
- Custom configs (`magi.config.json`) must have odd N >= 3 voting agents. Advisory agents (non-voting) are unlimited
- Dialectic mode (`--dialectic` or config) enables inter-agent rebuttals after initial evaluation
- Adversarial mode (`--adversarial` or config) stress-tests the consensus with a devil's advocate

## Plugin Health Governance

- File size limits and split strategies are defined in `plugins/magi/skills/magi/references/governance.md`
- Before committing plugin changes, run `bash scripts/check-sizes.sh` to verify all files are within limits
- SKILL.md must stay under 500 lines; agent files under 130 lines; reference/example files under 100 lines
