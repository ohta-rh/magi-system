# Phase 6: Action Generation (Opt-in)

Phase 6 converts MAGI deliberation results into actionable development artifacts. It is triggered only when the user explicitly opts in during Phase 5.

## Trigger

Add to Phase 5 AskUserQuestion options (when verdict is not 3:0 Unanimous Reject):

- **"Generate action items"** — Convert Recommended Actions into GitHub Issues and/or implementation tasks

## Action Types

### 1. GitHub Issues
Convert each Recommended Action into a structured issue:
```bash
gh issue create --title "[MAGI] Action: {action_summary}" \
  --label "magi-action" \
  --body "$(cat <<'BODY'
## Source
MAGI Deliberation: {topic}
Verdict: {overall_verdict} (Confidence: {confidence})

## Action
{recommended_action_detail}

## Conditions
{aggregated_conditions}

## Context
{relevant_agent_rationale}
BODY
)"
```

### 2. Implementation Checklist
When conditions exist, break them into a checklist comment on the source issue:
```markdown
## MAGI Conditions Checklist
- [ ] {condition_1}
- [ ] {condition_2}
- [ ] {condition_3}
```

## Decision Log Entry

After action generation, append action references to the decision log:
```json
{ "actions_generated": ["#issue_num1", "#issue_num2"], "action_type": "github_issues" }
```

## Constraints

- Phase 6 never executes automatically — always requires user opt-in
- Generated issues include `magi-action` label for tracking
- Action count matches Recommended Actions count (1-3)
