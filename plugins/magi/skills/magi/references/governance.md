# MAGI Plugin Governance Rules

Structural health rules for the MAGI plugin. Based on Anthropic's official skill authoring best practices (2026-03).

## File Size Limits

| File Category | Max Lines | Current | Rationale |
|--------------|-----------|---------|-----------|
| SKILL.md (orchestrator) | 500 | 339 | Anthropic official: SKILL.md body under 500 lines |
| Meta-agent (`agents/magi-core.md`) | 160 | 67 | Synthesis agent: embeds extraction, voting, bias detection, output format |
| Persona agents (`agents/{melchior,balthasar,caspar}.md`) | 130 | 101-102 | Self-contained persona + output format; 130 allows axis expansion |
| Reference files (`references/*.md`) | 100 | 38-84 | Focused single-concern documents |
| Example files (`examples/*.md`) | 100 | 78 | Illustrative, not normative |
| comparison-format.md | 100 | 75 | Comparison prompt template + Phase 4 format |
| voting-engine.md | 100 | 40 | Parameterized N-agent voting logic |
| dialectic-format.md | 100 | 81 | Inter-agent dialogue and adversarial mode |

## When Limits Are Approached (80%+)

1. **SKILL.md > 400 lines**: Extract the largest Phase section into `references/phase-N-detail.md` with a 1-line link from SKILL.md
2. **magi-core.md > 128 lines**: Review for redundancy; compress Output Format section first
3. **Persona agent file > 104 lines**: Review for redundancy with `references/schema.md`; compress Structured Output section first
4. **Reference file > 80 lines**: Split by concern (e.g., separate output-format from judgment-rules — already done)

## Structural Rules

- **1-level reference depth**: SKILL.md and agent files may reference files in `references/` and `examples/`. Reference files must NOT reference other reference files. This prevents transitive loading chains that consume tokens unpredictably.
- **Progressive Disclosure**: SKILL.md is the entry point. Detailed specs live in `references/`. Agents are self-contained. Examples are illustrative.
- **Agent self-containment**: Each agent file must be independently spawnable as a subagent prompt. Do not extract shared sections into common files — agents cannot read external files during execution.

## Verification

Run `scripts/check-sizes.sh` before committing changes to the plugin:

```bash
bash scripts/check-sizes.sh
```

This script checks all file sizes against the limits defined above and reports violations.

## Review Cadence

Re-evaluate these limits when:
- A file reaches 80% of its limit
- A new file category is added (e.g., new reference type)
- Anthropic updates official skill authoring best practices
