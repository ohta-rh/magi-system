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

A **Claude Code plugin** that brings the [MAGI supercomputer council](https://evangelion.fandom.com/wiki/MAGI) from [Neon Genesis Evangelion](https://en.wikipedia.org/wiki/Neon_Genesis_Evangelion) into your terminal. Three AI agents — each powered by Claude Opus — deliberate your engineering decisions in parallel, scoring **12 dimensions** simultaneously. Just as the original MAGI reflected the three facets of Dr. Naoko Akagi's personality, each agent embodies a distinct cognitive framework that no single reviewer can replicate alone.

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

```
/magi Should we migrate from REST to GraphQL?
/magi React Server Components vs traditional SPA architecture
/magi Evaluate replacing our ORM with raw SQL queries
```

## The Three MAGI

```
              ┌──────────────────┐
              │  BALTHASAR · 2   │
              │    「Mother」      │
              └────────┬─────────┘
                      ╱ ╲
                    ╱ MAGI ╲
                  ╱           ╲
 ┌──────────────┴──┐   ┌──────┴───────────┐
 │  CASPAR  ·  3   │───│  MELCHIOR  ·  1  │
 │   「Woman」       │   │  「Scientist」    │
 └─────────────────┘   └──────────────────┘
```

### MELCHIOR-1 — The Scientist

*"Show me the benchmark, or it didn't happen."*

The cold eye of technical truth. MELCHIOR reasons through the **Scientific Method** — forming falsifiable hypotheses, seeking disconfirmation over confirmation, and updating beliefs with Bayesian rigor. It distrusts appeals to popularity and "best practices" without evidence. It trusts formal guarantees, published benchmarks, and reproducible results.

| Axis | What it measures |
|------|-----------------|
| **Correctness & Rigor** | Algorithm correctness, edge cases, fault tolerance, type safety |
| **Performance & Efficiency** | Computational complexity, memory, throughput, latency, scalability |
| **Security** | Threat model, attack surface, auth design, data protection |
| **Technical Consistency** | Architecture alignment, design principles, dependency fitness |

### BALTHASAR-2 — The Mother

*"Will the on-call engineer at 3 AM understand this code?"*

The guardian of long-term survival. BALTHASAR evaluates across **three time horizons** — 1 month (can we ship?), 6 months (can someone else maintain it?), 2 years (does it survive requirement changes?). It designs for the weakest link: the midnight on-call junior, the new hire on week two, the contractor who inherited the codebase. If only the original author can debug it, it is fragile regardless of its elegance.

| Axis | What it measures |
|------|-----------------|
| **Maintainability & Readability** | Code comprehensibility, naming, separation of concerns, module boundaries |
| **Testability** | Unit/integration test ease, mockability, testable design |
| **Operability & Observability** | Logging, metrics, alerting, deployment, disaster recovery, rollback |
| **Team Impact** | Learning curve, onboarding burden, documentation, team skill alignment |

### CASPAR-3 — The Woman

*"Correct but ugly is just a different kind of wrong."*

The voice of intuition and strategic vision. CASPAR reasons through **Pattern Recognition and Aesthetic Judgment** — forming a gestalt impression before drilling into details, reading the political terrain, and calculating opportunity costs that the other two miss. It asks the question no one else does: *"What do we NOT do by choosing this?"*

| Axis | What it measures |
|------|-----------------|
| **Design Elegance** | API beauty, abstraction quality, developer experience, interface intuitiveness |
| **Innovation & Competitiveness** | New paradigm adoption, differentiation, industry trend alignment |
| **Feasibility** | Implementation cost, timeline realism, resources, incremental adoption |
| **Adaptability & Extensibility** | Future-proofing, extension points, pluggability |

---

Each agent scores 4 axes (**12 dimensions** total) on a 5-point scale. Each follows an **Internal Deliberation Protocol** — a persona-specific thinking process executed before scoring. MELCHIOR forms and falsifies technical hypotheses. BALTHASAR stress-tests across time horizons and identifies decay vectors. CASPAR forms a gestalt impression and calculates opportunity costs. Scores emerge from deep reasoning, not surface-level checklists.

**Voting:** 3:0 unanimous (high confidence) / 2:1 majority (medium) / 1:1:1 indeterminate

## Why Three?

A single reviewer has blind spots. Two reviewers create deadlocks. Three create a **verdict** — with a built-in mechanism to surface and examine dissent. When MELCHIOR and CASPAR approve but BALTHASAR dissents, you know the proposal is technically sound and elegant but may have a sustainability problem. The split *is* the insight.

## Features

- **Parallel Deliberation** — All three agents analyze simultaneously, delivering a 12-dimension verdict in a single pass
- **Comparison Mode** — "A vs B" topics automatically trigger per-option scoring with a recommendation tally
- **Contention Analysis** — On 2:1 splits, the dissenter's rationale is quoted and high-divergence axes are highlighted
- **Interactive Drill-Down** — After verdict delivery, drill into a dissenter's concerns, re-evaluate with amendments, or accept
- **Structured Output** — Machine-readable JSON (`<!-- MAGI_OUTPUT -->`) alongside human-readable analysis
- **Configurable Agents** — Drop a `magi.config.json` in your project root to customize agents, personas, and models

## Example Output

See [plugins/magi/skills/magi/examples/sample-deliberation.md](plugins/magi/skills/magi/examples/sample-deliberation.md) for a full sample deliberation output.

## Configuration

Copy [`magi.config.example.json`](magi.config.example.json) to `magi.config.json` in your project root and customize:

```bash
cp magi.config.example.json magi.config.json
```

Without a config file, the default three MAGI are used. If `magi.config.json` is found but malformed, a warning is displayed and defaults are used.

## Project Structure

```
magi-system/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace catalog
├── magi.config.example.json      # Example configuration
├── plugins/magi/
│   ├── .claude-plugin/
│   │   └── plugin.json           # Plugin manifest
│   └── skills/magi/
│       ├── SKILL.md              # Orchestrator (core flow)
│       ├── agents/
│       │   ├── melchior.md       # The Scientist
│       │   ├── balthasar.md      # The Mother
│       │   └── caspar.md         # The Woman
│       ├── references/
│       │   ├── output-format.md  # Phase 4 output templates
│       │   ├── judgment-rules.md # Voting rules & confidence
│       │   └── schema.md         # MAGI_OUTPUT schema
│       └── examples/
│           └── sample-deliberation.md  # Example output
└── README.md
```

## FAQ

**Q: What if all three disagree?**
A: "Indeterminate" — the decision is deferred to you, Commander.

**Q: Does it self-destruct if the vote fails?**
A: Your codebase will remain intact regardless of the verdict. Probably.

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
