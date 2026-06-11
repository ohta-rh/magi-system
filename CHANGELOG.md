# Changelog

All notable changes to the MAGI System plugin are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Plugin versions align with MAGI generations from 5.0.0 onward (earlier
generations v5–v8 shipped without a manifest bump — noted below).

## [5.0.0] — 2026-06-11 — MAGI v9: Plugin-Native Modernization

Aligned the plugin with the June 2026 Claude Code plugin specification.

### Changed
- **Plugin-native agents**: MELCHIOR-1, BALTHASAR-2, CASPAR-3, and MAGI Core
  moved from skill-embedded prompt files to `plugins/magi/agents/` with YAML
  frontmatter (`name`, `description`, `model`, `maxTurns`, `tools`). Persona
  definitions are now agent **system prompts**; topics travel as user messages
  inside `<user_topic>` tags — stronger prompt-injection separation.
  Orchestrators spawn by plugin-qualified `subagent_type` (`magi:magi-*`)
  with a documented fallback chain. Custom `magi.config.json` agents keep the
  legacy `$ARGUMENTS` injection path.
- Skill descriptions rewritten per skill-authoring best practices (third
  person, what + when to use); `allowed-tools` minimized per skill.
- `/magi-review` uses dynamic context injection (`` !`git status --short` ``,
  `` !`git diff --stat` ``) so repository state is inlined at invocation.

### Added
- Plugin-shipped `hooks/hooks.json` (PostToolUse on Write): validates
  `.magi/history/*.json` deliberation logs and feeds schema errors back to
  Claude for self-correction.
- GitHub Actions CI: size governance, extraction suite, e2e suite, benchmark
  fixture dry-run, hook smoke test, and `claude plugin validate`.
- MAGI Core persistent calibration memory (`memory: user`): accumulates
  observed bias patterns across deliberations; informs Calibration Notes and
  confidence only, never scores or verdicts.

### Fixed
- `((VAR++))` counters in `benchmark-regression.sh` aborted under
  `set -euo pipefail` on bash 5 (first increment from 0 returns non-zero).

## [4.0.0] — 2026-03-08 *(manifest unchanged through MAGI v5–v8)*

- **MAGI v8** (2026-04-01): MAGI Core on Opus; schema v1.2 research tracking;
  score-clustering and verdict-risk bias detection; cross-agent blind spot
  steps; Phase 3.0 individual agent report display; localized summary;
  premortem/quick structured-output consistency; e2e fixture expansion.
- **MAGI v7** (2026-03-27): deliberation logging, benchmark fixtures,
  A/B prompt testing, metrics and calibration reporting.
- **MAGI v6** (2026-03-21): MAGI Core as integrated judgment intelligence,
  cognitive frameworks and internal deliberation protocols, micro-dialectic,
  risk severity and reversibility, magi-review and magi-premortem skills.
- **v4.0.0 proper** (2026-03-08): N-agent voting abstraction
  (`magi.config.json`), advisory agents, inter-agent dialectic and
  adversarial modes.

## [3.0.0] — 2026-03-06 — MAGI v3

- Input sanitization (prompt-injection protection), config path validation,
  structured `MAGI_OUTPUT` blocks, `/magi-quick` triage skill, governance
  size limits and pre-commit checks.

## [1.0.0] — 2026-03-01

- Initial release as a Claude Code plugin: three-persona council (`/magi`),
  marketplace catalog, NERV-style deliberation output.
