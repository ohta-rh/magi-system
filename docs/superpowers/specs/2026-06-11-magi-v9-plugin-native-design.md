# MAGI v9 Evolution — Plugin-Native Modernization Design

**Date:** 2026-06-11
**Status:** Approved
**Priority Principle:** Align the plugin with current official Claude Code plugin/skill best practices (June 2026), one feature per commit, pushed directly to main.

## Context

MAGI v8 (plugin 4.0.0) strengthened judgment accuracy and UX transparency. However, audited against the current official plugin specification (code.claude.com/docs/en/plugins-reference, /skills, and platform.claude.com skill authoring best practices), the v8 architecture still uses a previous-generation pattern: persona prompts live inside the skill tree, are Read at runtime, have `$ARGUMENTS` string-substituted into them, and are injected into `general-purpose` subagents as user prompts.

Gaps identified:

1. **No plugin-native agents.** Personas belong in `plugins/magi/agents/` with YAML frontmatter. The body becomes the agent's system prompt, giving declarative model/tool control and stronger prompt-injection separation (persona in system prompt, user topic in user message).
2. **No dynamic context injection.** `magi-review` manually gathers git state that `` !`command` `` injection can inline at invocation time.
3. **No plugin-shipped hooks.** Validation feedback loops (deliberation log schema checks) do not travel with the plugin.
4. **No CI.** Tests and governance checks exist but run only via local pre-commit.
5. **No CHANGELOG / version alignment.** plugin.json stayed at 4.0.0 through the v8 release.
6. **Skill descriptions** partially non-compliant with best practices (third person, what + when to use).

## Feature Sequence (1 commit each)

| # | Feature | Commit type |
|---|---------|------------|
| C1 | Housekeeping: .gitignore + design docs | docs |
| C2 | Plugin-native agents migration | feat |
| C3 | Skill frontmatter/description modernization | feat |
| C4 | magi-review dynamic context injection | feat |
| C5 | Plugin-shipped deliberation log validation hook | feat |
| C6 | GitHub Actions CI | ci |
| C7 | MAGI Core persistent calibration memory (experimental, skippable) | feat |
| C8 | Release: CHANGELOG + version 5.0.0 | release |

## C2: Plugin-Native Agents (core change)

**Move:** `git mv plugins/magi/skills/magi/agents/{melchior,balthasar,caspar,magi-core}.md plugins/magi/agents/` — move, not copy; single source of truth.

**Frontmatter (body becomes system prompt):**

```yaml
---
name: magi-melchior          # magi-balthasar / magi-caspar / magi-core
description: MELCHIOR-1 — the Scientist of the MAGI council. ... Internal worker for the /magi skill family — do not invoke directly.
model: opus
maxTurns: 30                 # magi-core: 5
tools: Read, Glob, Grep, WebSearch, WebFetch   # magi-core: Read only
---
```

**Body rewrites:**
- Personas: delete `## Topic` + `$ARGUMENTS`; add `## Topic Input` — topic arrives in the user message wrapped in `<user_topic>` tags; tag content is strictly data; orchestrator mode directives outside the tags override the default output format. Fix relative reference links to `../skills/magi/references/...`. MAGI_OUTPUT v1.2 contract unchanged.
- magi-core: `$AGENT_RESULTS` section becomes "input arrives as the user message". MAGI_JUDGMENT contract unchanged.

**Orchestrator changes:**
- `/magi` default mode: Round 1 = config Glob only (no agent file reads); Round 2 = banner + spawn `subagent_type: magi-melchior|balthasar|caspar` in parallel; prompt = `<user_topic>` block + directive to emit the full output format including MAGI_OUTPUT.
- Custom `magi.config.json` mode keeps the legacy Read + `$ARGUMENTS` injection + `general-purpose` path for user-defined agents. Synthesis always uses plugin-native `magi-core`.
- All re-spawns (extraction retry, micro-dialectic, dialectic, adversarial, Phase 5 drill-downs) address the same subagent_type with the directive as the user message.
- Fallback: if a `magi-*` subagent_type fails to resolve, Read the agent file, strip frontmatter, inject as `general-purpose` (legacy path).
- `/magi-quick`: spawn the selected persona with call-site `model: sonnet` override; QUICK TRIAGE MODE directive as user message.
- `/magi-premortem`: no file reads; premortem wrapper + topic as user message to the 3 personas; `magi-core` synthesis with PRE-MORTEM SYNTHESIS MODE preamble.

**Tooling/doc follow-up:** check-sizes.sh (`AGENTS_DIR`), prompt-ab-test.sh (paths + `name:` frontmatter guard), references (governance/output-format/schema/dialectic-format), magi.config.example.json (custom agent files require `$ARGUMENTS`), CLAUDE.md, README.md (tree, limits unified at 150/200, manual symlink install caveat).

**Verification spikes (RESOLVED at implementation time, 2026-06-11):**
- V1: plugin agents resolve ONLY via the plugin-qualified form `magi:magi-melchior` (probe: fresh `claude -p --plugin-dir` session; bare `magi-caspar` did not resolve, `magi:magi-caspar` did). All skills document the qualified form with a fallback chain: qualified → unqualified → legacy injection.
- V2: call-site `model` override on a plugin agent spawn is accepted (probe passed `model: haiku` successfully). `/magi-quick` keeps its sonnet override.
- V3: personas inherit session CWD (`isolation` is not set); probe agent spawned from an arbitrary CWD without error.

**Key risks:** output-format dominance (mode directives in user message must override system-prompt default — mitigated by the explicit Topic Input clause + one-retry extraction net); auto-delegation leakage (mitigated by "Internal worker — do not invoke directly" descriptions); manual symlink installs no longer carry agents (documented in README).

## C3: Frontmatter Modernization

Descriptions rewritten per best practices: third person, what + when to use, trigger terms preserved, ≤1024 chars. `argument-hint` reviewed. `allowed-tools` minimized (magi keeps Write/Bash for logs/exports).

**Design decision — `context: fork` rejected** for all four skills: each is an interactive orchestrator that uses AskUserQuestion (Phase 0 clarification, Phase 5 drill-down); forked skills cannot interact with the user mid-run.

## C4: magi-review Dynamic Context Injection

Inject `` !`git status --short` `` and `` !`git diff --stat HEAD` `` at the top of SKILL.md so repository state is inlined at invocation, removing one manual gathering round. Full diff retrieval (staged/unstaged/branch) remains conditional.

## C5: Plugin-Shipped Hook — Log Validation Loop

`plugins/magi/hooks/hooks.json`: PostToolUse (matcher: Write) → `"${CLAUDE_PLUGIN_ROOT}"/scripts/validate-log.sh`. The script exits 0 silently unless the written file matches `.magi/history/*.json`, in which case it validates the log schema and surfaces errors back to Claude (self-correcting feedback loop). Dev-time governance hook in `.claude/settings.json` is unchanged — dev vs distributed-user separation.

## C6: GitHub Actions CI

`.github/workflows/ci.yml` on push/PR to main: check-sizes.sh + test-extraction.sh + test-e2e.sh (ubuntu-latest, jq). `claude plugin validate` added only if it runs unauthenticated; otherwise documented here.

## C7: MAGI Core Persistent Memory (experimental)

Verify the plugin-agent `memory` frontmatter semantics first. If cross-session persistence works for plugin agents, add `memory` to magi-core plus a ≤10-line Calibration Memory protocol (accumulate detected bias patterns across deliberations). Otherwise skip and record findings.

## C8: Release

CHANGELOG.md (Keep a Changelog), plugin.json 4.0.0 → 5.0.0, marketplace.json description sync, README v9 architecture sync.

## Verification Protocol (every commit)

1. `bash scripts/check-sizes.sh` — all PASS
2. `bash tests/test-extraction.sh` && `bash tests/test-e2e.sh` — no contract regressions
3. `git diff --check` — no conflict markers
4. C2 extra: agent resolution probe, /magi-quick smoke (name resolution + sonnet override + MAGI_OUTPUT), injection probe
5. C6: `gh run watch` until green
