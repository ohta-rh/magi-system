# Prose Fallback Extraction Algorithm

When the `<!-- MAGI_OUTPUT {...} -->` block is missing or malformed, the orchestrator attempts prose extraction as a last resort.

## Step 1: Verdict Extraction

Search for a line matching one of these patterns (case-insensitive):
- `### Verdict` section header, then the first non-empty line after it
- Valid values: `Approve`, `Reject`, `Conditional Approval (...)`

Regex: `(?i)^\s*(?:###\s*)?verdict\s*[:：]?\s*(.+)`

## Step 2: Score Extraction

For each axis line in the `### Scores` section, extract:
- Pattern: `- Axis Name: (N)` or `- Axis Name: N — rationale`
- Regex: `^-\s+(.+?):\s*\(?(\d)\)?\s*[—\-]?\s*(.*)`
- Score must be integer 1-5; discard if outside range

## Step 3: Conditions Extraction

If verdict matches `Conditional Approval`, extract parenthesized condition:
- Regex: `Conditional Approval\s*\((.+)\)`

## Confidence Levels

| Extraction Method | Confidence | Notes |
|-------------------|------------|-------|
| JSON (MAGI_OUTPUT block) | Full | Preferred; used when available |
| Prose fallback (all fields found) | Degraded | Flag in output: "⚠ Prose extraction used" |
| Prose fallback (partial fields) | Minimal | Treat as malformed; count as partial result |

## Orchestrator Behavior

- Always attempt JSON extraction first
- Fall back to prose only if JSON extraction fails
- Log extraction method in metrics (see P2 observability)
- Cap confidence at Medium when prose fallback is used for any agent
