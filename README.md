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

## Example Output

> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
> MAGI SYSTEM — Deliberation Results
> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**Topic:** Should we migrate from REST to GraphQL?

### MELCHIOR-1 [Scientist] — Verdict: Approve

| Axis | Score |
|------|-------|
| Correctness/Rigor | 5 |
| Performance | 4 |
| Security | 4 |
| Technical Consistency | 5 |

> Technically sound. Type safety and schema validation are superior to REST.

### BALTHASAR-2 [Mother] — Verdict: Conditional Approval

| Axis | Score |
|------|-------|
| Maintainability | 4 |
| Testability | 3 |
| Operability | 4 |
| Team Impact | 3 |

> Concerns about onboarding cost. Team needs GraphQL training first.

### CASPAR-3 [Woman] — Verdict: Approve

| Axis | Score |
|------|-------|
| Design Elegance | 5 |
| Innovation | 5 |
| Feasibility | 4 |
| Adaptability | 4 |

> Beautiful query API. The industry is moving this way.

> ━━━ Final Judgment ━━━

| | MELCHIOR | BALTHASAR | CASPAR |
|---|---------|-----------|--------|
| **Verdict** | Approve | Cond. Approval | Approve |

- **Overall Verdict:** Conditional Approval
- **Confidence:** Medium (2:1)
- **Conditions:** Team training before full adoption

**Recommended Actions:**
1. Run a GraphQL pilot on a non-critical service
2. Conduct team training sessions before full migration

> ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Project Structure

```
magi-system/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace catalog
├── plugins/magi/
│   ├── .claude-plugin/
│   │   └── plugin.json        # Plugin manifest
│   └── skills/magi/
│       ├── SKILL.md           # Orchestrator
│       └── agents/
│           ├── melchior.md    # The Scientist
│           ├── balthasar.md   # The Mother
│           └── caspar.md      # The Woman
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
