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

### Plugin

```bash
claude plugin marketplace add ohta-rh/magi-system
claude plugin install magi@magi-plugins
```

### Manual

```bash
git clone https://github.com/ohta-rh/magi-system.git
ln -s "$(pwd)/magi-system/skills/magi" ~/.claude/skills/magi
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

| MAGI | Persona | Evaluation Axes |
|------|---------|-----------------|
| **MELCHIOR-1** | The Scientist | Correctness, Performance, Security, Technical Consistency |
| **BALTHASAR-2** | The Mother | Maintainability, Testability, Operability, Team Impact |
| **CASPAR-3** | The Woman | Design Elegance, Innovation, Feasibility, Adaptability |

Each agent scores 4 axes (**12 dimensions** total) on a 5-point scale: ◎(5) ○(4) △(3) ▽(2) ×(1)

**Voting:** 3:0 unanimous (high confidence) / 2:1 majority (medium) / 1:1:1 indeterminate

## Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MAGI SYSTEM — Deliberation Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ■ MELCHIOR-1 [Scientist] ──── Verdict: Approve
  ┌──────────────────────┬──────┐
  │ Correctness/Rigor    │  ◎   │
  │ Performance          │  ○   │
  │ Security             │  ○   │
  │ Technical Consistency│  ◎   │
  └──────────────────────┴──────┘

  ■ BALTHASAR-2 [Mother] ──── Verdict: Conditional Approval
  ┌──────────────────────┬──────┐
  │ Maintainability      │  ○   │
  │ Testability          │  △   │
  │ Operability          │  ○   │
  │ Team Impact          │  △   │
  └──────────────────────┴──────┘

  ■ CASPAR-3 [Woman] ──── Verdict: Approve
  ┌──────────────────────┬──────┐
  │ Design Elegance      │  ◎   │
  │ Innovation           │  ◎   │
  │ Feasibility          │  ○   │
  │ Adaptability         │  ○   │
  └──────────────────────┴──────┘

  ━━━ Final Judgment ━━━

  【Verdict】: Conditional Approval
  【Votes】: MELCHIOR ✅ / BALTHASAR ⚠️ / CASPAR ✅
  【Confidence】: Medium

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Project Structure

```
magi-system/
├── .claude-plugin/          # Plugin distribution config
├── skills/magi/
│   ├── SKILL.md             # Orchestrator
│   └── agents/
│       ├── melchior.md      # The Scientist
│       ├── balthasar.md     # The Mother
│       └── caspar.md        # The Woman
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
