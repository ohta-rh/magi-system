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

> *"The MAGI System — mankind's ultimate decision-making computer.*
> *Born from the three aspects of Dr. Naoko Akagi's soul."*
>
> — Ritsuko Akagi, Chief Scientist, NERV

---

A **Claude Code plugin** inspired by the [MAGI supercomputer system](https://evangelion.fandom.com/wiki/MAGI) from [Neon Genesis Evangelion](https://en.wikipedia.org/wiki/Neon_Genesis_Evangelion).

Three AI agents deliberate your engineering decisions in parallel — each embodying a distinct aspect of personality, just as the original MAGI reflected the three facets of Dr. Naoko Akagi. No Angel can bypass a unanimous vote.

## MAGI System Overview

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║    CODE : 666                                       防壁展開     ║
║    FILE : ENGINEERING_REVIEW                                     ║
║    EX_MODE : DELIBERATION                                        ║
║    PRIORITY : +++                                                ║
║                                                                  ║
║                ┌────────────────────┐                            ║
║                │   BALTHASAR  ·  2  │                            ║
║                │     「Mother」      │                            ║
║                └────────┬───────────┘                            ║
║                        ╱ ╲                                       ║
║                      ╱     ╲                                     ║
║                    ╱  M A G I  ╲                                 ║
║                  ╱               ╲                               ║
║   ┌────────────┴─────┐   ┌───────┴────────────┐                 ║
║   │   CASPAR  ·  3   │───│   MELCHIOR  ·  1   │                 ║
║   │    「Woman」       │   │   「Scientist」     │                 ║
║   └──────────────────┘   └────────────────────┘                 ║
║                                                                  ║
║                                                 修復作業中       ║
╚══════════════════════════════════════════════════════════════════╝
```

## The Three MAGI

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│   M E L C H I O R · 1             "The data does not support        │
│   ═══════════════════              your hypothesis."                │
│   Persona: The Scientist                                             │
│                                                                      │
│   Evaluates:                      Personality:                       │
│   ├─ Correctness & Rigor          ├─ Cold, rational, data-driven     │
│   ├─ Performance & Efficiency     ├─ Skeptical of unproven methods   │
│   ├─ Security                     ├─ Favors proven approaches        │
│   └─ Technical Consistency        └─ Concise and assertive           │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   B A L T H A S A R · 2           "Will the next engineer           │
│   ═══════════════════              understand this at 3 AM?"        │
│   Persona: The Mother                                                │
│                                                                      │
│   Evaluates:                      Personality:                       │
│   ├─ Maintainability              ├─ Nurturing, protective           │
│   ├─ Testability                  ├─ Thinks in decades, not sprints  │
│   ├─ Operability                  ├─ Fears technical debt            │
│   └─ Team Impact                  └─ Gentle but resolute             │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   C A S P A R · 3                  "Correct but ugly?               │
│   ═══════════════                   That's just wrong."             │
│   Persona: The Woman                                                 │
│                                                                      │
│   Evaluates:                      Personality:                       │
│   ├─ Design Elegance              ├─ Intuitive, aesthetic            │
│   ├─ Innovation                   ├─ Embraces risk and novelty       │
│   ├─ Feasibility                  ├─ Reads the room                  │
│   └─ Adaptability                 └─ Provocative and confident       │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Scoring System

Each MAGI scores across 4 dimensions. That's **12 dimensions** of engineering judgment — more than any AT Field can handle.

```
  ◎ ──── 5 ──── Excellent    "No problems detected."
  ○ ──── 4 ──── Good         "Acceptable."
  △ ──── 3 ──── Moderate     "There are concerns."
  ▽ ──── 2 ──── Poor         "Significant issues."
  × ──── 1 ──── Critical     "This must not proceed."
```

## Voting Protocol

```
  3:0   Unanimous    ──→  High Confidence     "All MAGI agree."
  2:1   Majority     ──→  Medium Confidence   "Minority opinion noted."
  1:1:1 Three-way    ──→  Indeterminate       "Cannot reach consensus."
```

> *In Episode 13, the MAGI voted 2:1 to NOT self-destruct NERV HQ.*
> *CASPAR cast the deciding vote — as a woman, she chose not to die*
> *with the man who had dumped her.*

## Installation

### Option 1: Plugin (Recommended)

```bash
claude plugin marketplace add ohta-rh/magi-system
claude plugin install magi@magi-plugins
```

### Option 2: Manual Symlink

```bash
git clone https://github.com/ohta-rh/magi-system.git
ln -s "$(pwd)/magi-system/skills/magi" ~/.claude/skills/magi
```

**Requirements:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI

## Usage

```
/magi Should we migrate from REST to GraphQL for our API layer?
```

```
/magi React Server Components vs traditional SPA architecture
```

```
/magi Evaluate replacing our ORM with raw SQL queries
```

```
/magi Is this the mass refactoring to monorepo we've been avoiding?
```

The MAGI will activate, deliberate in parallel, and return a structured verdict.

## How It Works

```
  You: /magi "Should we use Server Actions?"
   │
   ▼
  ┌─────────────────────────────────┐
  │  MAGI SYSTEM ver.2 ACTIVATED   │
  │  Initializing Parallel Agents   │
  └──────────────┬──────────────────┘
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
   MELCHIOR   BALTHASAR   CASPAR
   (sonnet)   (sonnet)    (sonnet)
       │         │         │          ← Each agent runs independently
       │  WebSearch, Glob, │             with its own persona & axes
       │  Grep, Read ...   │
       ▼         ▼         ▼
   ┌──────┐  ┌──────┐  ┌──────┐
   │ ◎○○◎ │  │ ○△○△ │  │ ◎◎○○ │   ← 4 scores each (12 total)
   │Approve│  │Cond. │  │Approve│
   └──┬───┘  └──┬───┘  └──┬───┘
      └─────────┼─────────┘
                ▼
   ┌─────────────────────────────┐
   │  MAJORITY VOTE: 2:1         │
   │  VERDICT: Approve            │
   │  CONFIDENCE: Medium          │
   │  CONDITIONS: (from BALTHASAR)│
   └─────────────────────────────┘
```

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
  Findings: Technically sound. No correctness concerns.

  ■ BALTHASAR-2 [Mother] ──── Verdict: Conditional Approval
  ┌──────────────────────┬──────┐
  │ Maintainability      │  ○   │
  │ Testability          │  △   │
  │ Operability          │  ○   │
  │ Team Impact          │  △   │
  └──────────────────────┴──────┘
  Findings: Concerns about onboarding cost and test coverage.

  ■ CASPAR-3 [Woman] ──── Verdict: Approve
  ┌──────────────────────┬──────┐
  │ Design Elegance      │  ◎   │
  │ Innovation           │  ◎   │
  │ Feasibility          │  ○   │
  │ Adaptability         │  ○   │
  └──────────────────────┴──────┘
  Findings: Beautiful API. The industry is moving this way.

  ━━━ Final Judgment ━━━

  【Verdict】: Conditional Approval
  【Votes】: MELCHIOR ✅ / BALTHASAR ⚠️ / CASPAR ✅
  【Confidence】: Medium
  【Conditions】: Improve test coverage before adoption

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Project Structure

```
magi-system/
├── .claude-plugin/
│   ├── marketplace.json     # Plugin marketplace config
│   └── plugin.json          # Plugin manifest
├── skills/
│   └── magi/
│       ├── SKILL.md         # Orchestrator (the "Pribnow Box")
│       └── agents/
│           ├── melchior.md  # MELCHIOR-1: The Scientist
│           ├── balthasar.md # BALTHASAR-2: The Mother
│           └── caspar.md    # CASPAR-3: The Woman
├── CLAUDE.md
└── README.md                # You are here (Terminal Dogma)
```

## FAQ

**Q: Can I add a 4th MAGI?**
A: Dr. Akagi only had three aspects. Adding a 4th would be like adding a 5th Children. Theoretically possible, but canonically questionable.

**Q: What if all three disagree?**
A: The system returns "Indeterminate" — just like when the MAGI couldn't agree on the Angel classification. The decision is deferred to the human operator (that's you, Commander).

**Q: Does it actually self-destruct if the vote fails?**
A: No. Unlike NERV HQ, your codebase will remain intact regardless of the verdict. Probably.

**Q: Why use three agents instead of one?**
A: One perspective is an opinion. Three perspectives is wisdom. Also, it looks way cooler in the terminal.

**Q: Is the Scientist always right?**
A: MELCHIOR would say yes. CASPAR would say he's boring. BALTHASAR would say let's not fight and focus on the children.

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
