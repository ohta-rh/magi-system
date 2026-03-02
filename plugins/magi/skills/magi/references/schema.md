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
  "risks": ["string — each a distinct risk or concern. Empty array if none"]
}
```

## Field Rules

- `schema_version`: Must be `"1.0"`. Future versions will increment this field.
- `verdict`: Exactly one of the three values. No other values are valid.
- `conditions`: Must be a non-empty string if verdict is `"Conditional Approval"`, otherwise `null`.
- `scores`: Object with agent-specific axis keys. Each agent has exactly 4 axes. Keys must match the agent's defined evaluation axes.
- `scores.*.score`: Integer from 1 to 5 inclusive.
- `scores.*.rationale`: Non-empty string.
- `risks`: Array of strings. Use `[]` (empty array) if no risks identified.
- The entire JSON block MUST be valid JSON enclosed in `<!-- MAGI_OUTPUT ... -->` HTML comment markers.
