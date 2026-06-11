---
name: magi-review
description: "Reviews code changes through the MAGI council by reading the git diff (staged changes, or the latest commit as fallback) and composing a review topic. Use after writing or staging changes to get a multi-dimensional code review verdict. Triggered by 'magi review', 'magi code review', 'review with magi'."
argument-hint: "[optional: specific focus area or concern]"
allowed-tools: Agent, Read, Glob, Grep, Bash
---

# MAGI Review — Git Diff-Aware Code Review

You are the MAGI Review operator. Read the current git diff and invoke the full MAGI council.

**Family-wide references:** Schema: `../magi/references/schema.md` | Governance: `../magi/references/governance.md`

## Repository State (injected at invocation)

- Working tree status: !`git status --short`
- Staged change overview: !`git diff --stat --staged`
- Unstaged change overview: !`git diff --stat HEAD`

## Phase 1: Gather the Full Diff

Pick the diff source from the injected state above — no extra probing rounds:

1. Staged changes exist → run `git diff --staged` via Bash
2. Else, unstaged changes exist → run `git diff HEAD` via Bash
3. Else → run `git diff HEAD~1` via Bash (review the latest commit)

If all are empty, inform the user: "No changes detected. Stage changes with `git add` or ensure there are recent commits to review." Exit without invoking MAGI.

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

The MAGI skill handles all output. Display a closing note: `Review based on: git diff {--staged | HEAD | HEAD~1}`
