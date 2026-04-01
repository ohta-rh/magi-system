---
name: magi-review
description: "MAGI code review. Reads git diff and evaluates changes through the MAGI council. Triggered by 'magi review', 'magi code review', 'review with magi'."
argument-hint: "[optional: specific focus area or concern]"
allowed-tools: Agent, Read, Glob, Grep, Bash
---

# MAGI Review — Git Diff-Aware Code Review

You are the MAGI Review operator. Read the current git diff and invoke the full MAGI council.

**Family-wide references:** Schema: `../magi/references/schema.md` | Governance: `../magi/references/governance.md`

## Phase 1: Gather Diff

Run `git diff --staged` via Bash. If the staged diff is empty, fall back to `git diff HEAD~1`.

If both are empty, inform the user: "No changes detected. Stage changes with `git add` or ensure there are recent commits to review." Exit without invoking MAGI.

## Phase 2: Summarize Changes

From the diff, build a topic summary:
1. List files changed (max 10; if more, summarize as "N files across M directories")
2. Categorize: new feature, bug fix, refactor, config change, test addition, etc.
3. Note scope: lines added/removed

Format:
```
Code Review: [category] across [file list or summary].
Changes: +[added] -[removed] lines.
[1-2 sentence description of what the changes do]

Key files:
- [file1]: [brief change description]
- [file2]: [brief change description]
(up to 5 key files)
```

If `$ARGUMENTS` is provided, append it as additional review focus context.

## Phase 3: Invoke MAGI

Invoke the /magi skill with the generated topic summary:
```
Agent:
  subagent_type: skill
  name: magi
  prompt: (topic summary from Phase 2)
```

The MAGI skill handles all output. Display a closing note: `Review based on: git diff {--staged | HEAD~1}`
