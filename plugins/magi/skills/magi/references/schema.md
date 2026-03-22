# MAGI_OUTPUT Schema Definition

This is the authoritative schema for the structured output block emitted by each agent. Agents MUST conform to this schema. The orchestrator extracts data based on these field definitions.

```json
{
  "schema_version": "1.0",
  "verdict": "Approve | Reject | Conditional Approval",
  "conditions": "string or null — required if verdict is Conditional Approval",
  "scores": {
    "<axis_key>": {
      "score": "integer 1-5 (5 = best, 1 = worst)",
      "rationale": "string — one-line justification"
    }
  },
  "risks": ["string — each a distinct risk or concern. Empty array if none. Also accepts {severity, description} objects (see below)"]
}
```

## Field Rules

- `schema_version`: Must be `"1.0"`. Future versions will increment this field.
- `verdict`: Exactly one of the three values. No other values are valid.
- `conditions`: Must be a non-empty string if verdict is `"Conditional Approval"`, otherwise `null`.
- `scores`: Object with agent-specific axis keys. Each agent has exactly 4 axes. Keys must match the agent's defined evaluation axes.
- `scores.*.score`: Integer from 1 to 5 inclusive.
- `scores.*.rationale`: Non-empty string.
- `risks`: Array of strings OR objects. Persona agents emit strings; MAGI Core classifies severity during synthesis. Object form: `{"severity": "critical|moderate|informational", "description": "string"}`. Use `[]` if no risks.
  - `critical`: Blocks deployment or causes outage
  - `moderate`: Degrades quality or increases cost
  - `informational`: Awareness item, no immediate action needed
- The entire JSON block MUST be valid JSON enclosed in `<!-- MAGI_OUTPUT ... -->` HTML comment markers.

## Schema v1.1 — Comparison Mode

When agents evaluate multiple options (comparison mode), they emit this schema instead of v1.0:

```json
{
  "schema_version": "1.1",
  "mode": "comparison",
  "recommendation": "string — name of the recommended option",
  "recommendation_rationale": "string — 1-2 line rationale",
  "options": [
    {
      "name": "string — option name",
      "verdict": "Approve | Reject | Conditional Approval",
      "conditions": "string or null",
      "scores": {
        "<axis_key>": {
          "score": "integer 1-5",
          "rationale": "string"
        }
      },
      "risks": ["string"]
    }
  ]
}
```

### Additional Field Rules (v1.1)

- `mode`: Must be `"comparison"`.
- `recommendation`: Must match one of the `options[].name` values.
- `recommendation_rationale`: Non-empty string explaining the recommendation.
- `options`: Array with 2-4 entries. Each entry follows the same `verdict`/`conditions`/`scores`/`risks` rules as v1.0.
- v1.0 root-level fields (`verdict`, `conditions`, `scores`, `risks`) are NOT present in v1.1 — they exist inside each `options[]` entry.

## magi.config.json Agent Schema

```json
{
  "name": "string — required, agent display name",
  "persona": "string — optional, persona description",
  "file": "string — required, path to agent .md file (relative to project root)",
  "model": "string — optional, default 'opus'. Model to use for this agent",
  "role": "string — optional, 'voting' (default) or 'advisory' (non-voting)"
}
```

Config-level options:
- `dialectic`: boolean — enable dialectic round (Phase 3.7). Default: false
- `adversarial`: boolean — enable adversarial challenge (Phase 3.8). Default: false

## MAGI_JUDGMENT Schema

See [judgment-rules.md](judgment-rules.md) for the full MAGI_JUDGMENT schema definition.
