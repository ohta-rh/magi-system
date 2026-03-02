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

A **Claude Code plugin** inspired by the [MAGI](https://evangelion.fandom.com/wiki/MAGI) from [Neon Genesis Evangelion](https://en.wikipedia.org/wiki/Neon_Genesis_Evangelion). Three AI agents deliberate your engineering decisions in parallel — each embodying a distinct persona, just as the original MAGI reflected the three facets of Dr. Naoko Akagi.

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

| MAGI | Persona | Cognitive Framework | Evaluation Axes |
|------|---------|--------------------:|-----------------|
| **MELCHIOR-1** | The Scientist | Scientific Method | Correctness, Performance, Security, Technical Consistency |
| **BALTHASAR-2** | The Mother | Time Horizons & Human Capacity | Maintainability, Testability, Operability, Team Impact |
| **CASPAR-3** | The Woman | Pattern Recognition & Aesthetics | Design Elegance, Innovation, Feasibility, Adaptability |

Each agent scores 4 axes (**12 dimensions** total) on a 5-point scale (5 = best, 1 = worst).

Each agent follows an **Internal Deliberation Protocol** — a persona-specific thinking process executed before scoring. MELCHIOR forms and falsifies technical hypotheses. BALTHASAR stress-tests across time horizons and identifies decay vectors. CASPAR forms a gestalt impression and calculates opportunity costs. This ensures scores emerge from deep reasoning, not surface-level checklists.

**Voting:** 3:0 unanimous (high confidence) / 2:1 majority (medium) / 1:1:1 indeterminate

## Features

- **Structured Output Schema** — Agents emit machine-readable JSON (`<!-- MAGI_OUTPUT -->`) alongside human-readable analysis for reliable programmatic extraction
- **Configurable Agents** — Drop a `magi.config.json` in your project root to customize agents, personas, and models
- **Divergence Map** — Score overview table across all 12 axes for at-a-glance comparison
- **Contention Analysis** — On 2:1 splits, the dissenter's rationale is quoted and high-divergence axes are highlighted
- **Partial Results Protocol** — Graceful degradation when agents fail (2/3: warning + capped confidence; 1/3 or 0/3: no verdict)
- **Interactive Drill-Down** — After verdict delivery, drill into a dissenter's concerns, re-evaluate with amendments, or accept

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
