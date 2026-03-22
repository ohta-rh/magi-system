```
                              新  世  紀
███████ ██    ██  █████  ██    ██  █████  ███████ ██      ██  █████  ██    ██
██      ██    ██ ██   ██ ███   ██ ██      ██      ██      ██ ██   ██ ███   ██
█████    ██  ██  ███████ ██ ██ ██ ██  ███ █████   ██      ██ ██   ██ ██ ██ ██
██        ████   ██   ██ ██  ████ ██   ██ ██      ██      ██ ██   ██ ██  ████
███████    ██    ██   ██ ██   ███  █████  ███████ ███████ ██  █████  ██   ███
                           エヴァンゲリオン
```

# MAGI SYSTEM

> *"One mind is a hypothesis. Three minds are a verdict."*

A **Claude Code plugin** that brings the [MAGI supercomputer council](https://evangelion.fandom.com/wiki/MAGI) from [Neon Genesis Evangelion](https://en.wikipedia.org/wiki/Neon_Genesis_Evangelion) into your terminal. Three AI agents — each powered by Claude Opus — deliberate your engineering decisions in parallel, scoring **12 dimensions** simultaneously. A fourth agent, **MAGI Core**, synthesizes their evaluations with sycophancy detection and bias calibration.

Just as the original MAGI reflected the three facets of Dr. Naoko Akagi's personality, each agent embodies a distinct cognitive framework — with built-in cognitive resistance to prevent LLM convergence.

## Installation

### Plugin (Recommended)

Run inside Claude Code interactive mode:

```
/plugin marketplace add ohta-rh/magi-system
/plugin install magi@magi-plugins
```

### Manual Symlink

```bash
git clone https://github.com/ohta-rh/magi-system.git
ln -s "$(pwd)/magi-system/plugins/magi/skills/magi" ~/.claude/skills/magi
```

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Usage

```bash
# Full deliberation
/magi Should we migrate from REST to GraphQL?

# Comparison mode (auto-detected)
/magi React Server Components vs traditional SPA architecture

# Quick triage (single-agent, Sonnet — fast and cheap)
/magi-quick Is adding Redis caching worth the complexity?

# Code review via git diff
/magi-review

# Pre-mortem failure analysis
/magi-premortem Rewrite the auth system in Rust

# With dialectic round (inter-agent rebuttals)
/magi Should we adopt microservices? --dialectic

# With adversarial challenge (devil's advocate)
/magi Migrate to Kubernetes --adversarial
```

## The Three MAGI

```
              ┌──────────────────┐
              │  BALTHASAR · 2   │
              │    「Mother」      │
              └────────┬─────────┘
                      ╱ ╲
                    ╱ MAGI ╲
                  ╱  CORE   ╲
 ┌──────────────┴──┐   ┌──────┴───────────┐
 │  CASPAR  ·  3   │───│  MELCHIOR  ·  1  │
 │   「Woman」       │   │  「Scientist」    │
 └─────────────────┘   └──────────────────┘
```

### MELCHIOR-1 — The Scientist

*"Show me the benchmark, or it didn't happen."*

The cold eye of technical truth. Reasons through the **Scientific Method** — forming falsifiable hypotheses, seeking disconfirmation, updating beliefs with Bayesian rigor. **Explicitly anti-sycophantic**: states findings bluntly, actively resists the tendency to soften negative judgments.

| Axis | What it measures |
|------|-----------------|
| **Correctness & Rigor** | Algorithm correctness, edge cases, fault tolerance, type safety |
| **Performance & Efficiency** | Computational complexity, memory, throughput, latency, scalability |
| **Security** | Threat model, attack surface, auth design, data protection |
| **Technical Consistency** | Architecture alignment, design principles, dependency fitness |

### BALTHASAR-2 — The Mother

*"Will the on-call engineer at 3 AM understand this code?"*

The guardian of long-term survival. Evaluates across **three time horizons** — 1 month, 6 months, 2 years. Designs for the weakest link. **Cognitive resistance**: must articulate the worst-case scenario at the 2-year horizon before approving.

| Axis | What it measures |
|------|-----------------|
| **Maintainability & Readability** | Code comprehensibility, naming, separation of concerns |
| **Testability** | Unit/integration test ease, mockability, testable design |
| **Operability & Observability** | Logging, metrics, alerting, deployment, rollback |
| **Team Impact** | Learning curve, onboarding burden, documentation, skill alignment |

### CASPAR-3 — The Woman

*"Correct but ugly is just a different kind of wrong."*

The voice of intuition and strategic vision. Reasons through **Pattern Recognition and Aesthetic Judgment** — forming a gestalt impression, reading the political terrain, calculating opportunity costs. **Cognitive resistance**: must name the best alternative NOT chosen before approving.

| Axis | What it measures |
|------|-----------------|
| **Design Elegance** | API beauty, abstraction quality, DX, interface intuitiveness |
| **Innovation & Competitiveness** | Paradigm adoption, differentiation, trend alignment |
| **Feasibility** | Implementation cost, timeline realism, incremental adoption |
| **Adaptability & Extensibility** | Future-proofing, extension points, pluggability |

---

**Voting:** 3:0 unanimous (high confidence) / 2:1 majority (medium) / 1:1:1 indeterminate

## Why Three?

A single reviewer has blind spots. Two create deadlocks. Three create a **verdict** — with a built-in mechanism to surface dissent. When MELCHIOR and CASPAR approve but BALTHASAR dissents, you know the proposal is technically sound and elegant but has a sustainability problem. The split *is* the insight.

## Architecture

```
User → /magi "topic"
         │
    ┌────┴─────┐
    │ SKILL.md  │  Thin orchestrator
    └────┬──────┘
         │ Parallel launch (Opus)
    ┌────┼────────────┐
    ▼    ▼            ▼
 MELCHIOR BALTHASAR  CASPAR    Persona agents
    │    │            │
    └────┼────────────┘
         │ If agent fails → 1 retry
         ▼
    ┌──────────┐
    │ MAGI Core │  Synthesis (Sonnet)
    └────┬──────┘  Extraction → Bias detection → Voting →
         │         Tension analysis → Output formatting
         ▼
    Deliberation Report
         │
         │ If 2:1 split → auto micro-dialectic
         ▼
    Phase 5: Interactive drill-down
```

**Key design principle:** The orchestrator does not perform judgment. MAGI Core is a separate agent ensuring true encapsulation.

## Features

### Sycophancy Detection

MAGI Core detects AI bias patterns in agent responses:
- Uniformly high scores with generic rationales
- Approve verdict despite substantive risks
- Critical risk dismissed without justification
- Overcorrection: uniformly harsh without evidence

Confidence is reduced when bias is detected.

### Auto Micro-Dialectic

On 2:1 splits, the dissenter is automatically re-spawned for a brief rebuttal — no flag needed. The dissenter sees the majority's average score and must state whether they maintain their position.

### Cross-Axis Tension Visualization

MAGI Core surfaces trade-offs between agents' axes:

> **Key Trade-offs:**
> - MELCHIOR Security:5 vs CASPAR Feasibility:2 — secure approach impractical at current team size
> - BALTHASAR Operability:2 vs MELCHIOR Performance:5 — fast but unobservable in production

### Risk Severity & Reversibility

Risks are classified as **critical** / **moderate** / **informational**. Each judgment includes a **reversibility** rating (Low/Medium/High). Low reversibility + Medium confidence triggers a caution warning.

### Comparison Mode

"A vs B" topics automatically produce a Score Matrix with per-agent recommendations:

```
| Agent | Axis | GraphQL | gRPC |
|-------|------|:---:|:---:|
| MELCHIOR | Correctness | 5 | 4 |
| MELCHIOR | Performance | 4 | 5 |
| ...
```

### Five Skills

| Skill | Purpose |
|-------|---------|
| `/magi` | Full council deliberation (3 agents + synthesis) |
| `/magi-quick` | Single-agent triage (Sonnet, fast) |
| `/magi-review` | Git diff-aware code review |
| `/magi-premortem` | Assume failure, reason backward |
| Dialectic/Adversarial | `--dialectic` / `--adversarial` flags |

## Configuration

Drop `magi.config.json` in your project root to customize agents:

```json
{
  "agents": [
    { "name": "THREAT-MODEL", "persona": "Security threat analyst", "file": "agents/threat.md" },
    { "name": "COMPLIANCE", "persona": "Regulatory specialist", "file": "agents/compliance.md" },
    { "name": "ARCHITECTURE", "persona": "System architect", "file": "agents/arch.md" }
  ],
  "dialectic": true,
  "adversarial": false
}
```

Requirements: odd N >= 3 voting agents. Add `"role": "advisory"` for non-voting agents.

## Development

### Testing

```bash
bash tests/test-extraction.sh    # 15 schema validation tests
bash tests/test-e2e.sh           # 8 integration tests (vote tally, dissenter ID)
bash scripts/check-sizes.sh      # Governance limits + Current value verification
```

### Pre-commit Hook

```bash
git config core.hooksPath .githooks
```

Auto-runs governance and extraction tests on plugin commits.

### Governance

File size limits enforced by `check-sizes.sh`:

| Category | Limit |
|----------|-------|
| SKILL.md (orchestrator) | 500 lines |
| magi-core.md (meta-agent) | 160 lines |
| Persona agents | 130 lines |
| Reference / example files | 100 lines |

## Project Structure

```
magi-system/
├── .claude-plugin/marketplace.json
├── .githooks/pre-commit
├── plugins/magi/
│   ├── .claude-plugin/plugin.json
│   └── skills/
│       ├── magi/                    # Full deliberation
│       │   ├── SKILL.md             # Thin orchestrator
│       │   ├── agents/
│       │   │   ├── magi-core.md     # Synthesis + bias detection
│       │   │   ├── melchior.md      # The Scientist
│       │   │   ├── balthasar.md     # The Mother
│       │   │   └── caspar.md        # The Woman
│       │   ├── references/          # Schema, rules, formats
│       │   └── examples/            # Sample output
│       ├── magi-quick/              # Single-agent triage
│       ├── magi-review/             # Git diff review
│       └── magi-premortem/          # Failure analysis
├── scripts/                         # Validation & governance
└── tests/                           # Fixtures & test suites
```

## FAQ

**Q: What if all three disagree?**
A: "Indeterminate" verdict — the decision is deferred to you, Commander.

**Q: Does it detect when I'm asking about non-engineering topics?**
A: Yes. MAGI will refuse to deliberate on topics that cannot be scored on its engineering axes.

**Q: Can MAGI evaluate itself?**
A: Yes. The v6 roadmap was created by MAGI deliberating on its own improvement proposals — 27 proposed, 15 closed by 3:0 ruling.

## License

MIT

---

```
    _人人人人人人人人人人人_
    ＞  問題ない。        ＜
    ＞  全ては計画通りだ。＜
    ￣Y^Y^Y^Y^Y^Y^Y^Y^Y^Y￣
             — Gendo Ikari
```
