# MAGI System

> *"The MAGI — three aspects of one mind, rendering judgment upon the unknown."*

A **Claude Code custom skill** inspired by the MAGI supercomputer system from [Neon Genesis Evangelion](https://en.wikipedia.org/wiki/Neon_Genesis_Evangelion). Three AI agents deliberate engineering decisions in parallel, each embodying a distinct perspective — just as the original MAGI (MELCHIOR, BALTHASAR, and CASPAR) reflected the three aspects of Dr. Naoko Akagi's personality.

## What It Does

MAGI System provides **multi-dimensional engineering decision support** through a council of three specialized agents:

| MAGI | Persona | Evaluation Domain |
|------|---------|-------------------|
| **MELCHIOR-1** | The Scientist | Technical excellence — correctness, performance, security, architectural consistency |
| **BALTHASAR-2** | The Mother | Sustainability — maintainability, testability, operability, team impact |
| **CASPAR-3** | The Woman | Pragmatic aesthetics — design elegance, innovation, feasibility, adaptability |

Each agent independently scores the proposal across 4 axes using a 5-point scale (◎/○/△/▽/×), conducts web research when needed, and renders a verdict. The system then synthesizes all three evaluations into a unified judgment through majority vote.

## Use Cases

- Architecture design decisions
- Technology selection and comparison
- Code review and refactoring strategies
- Design pattern evaluation
- Migration and upgrade planning

## Installation

Copy or symlink this directory into your Claude Code skills directory:

```bash
# Clone the repository
git clone https://github.com/your-username/magi-system.git

# Symlink into Claude Code skills
ln -s "$(pwd)/magi-system" ~/.claude/skills/magi-system
```

## Usage

In Claude Code, invoke the MAGI system with:

```
/magi Should we migrate from REST to GraphQL for our API layer?
```

```
/magi React Server Components vs traditional SPA architecture for our dashboard
```

```
/magi Evaluate the proposal to replace our ORM with raw SQL queries
```

The system will:
1. Spawn three agents in parallel
2. Each agent analyzes the topic from its unique perspective, optionally researching via web search
3. Scores are collected and synthesized
4. A final verdict is rendered with confidence level and recommended actions

## Output

The deliberation result includes:

- **Per-agent scores** across 4 evaluation axes each (12 dimensions total)
- **Individual findings** from each MAGI
- **Multi-dimensional summary** highlighting strengths and concerns
- **Final verdict**: Approve / Reject / Conditional Approval / Indeterminate
- **Vote breakdown**: MELCHIOR / BALTHASAR / CASPAR
- **Confidence level**: High / Medium / Low
- **Recommended actions**: Concrete next steps based on the deliberation

## How It Works

This skill leverages Claude Code's agent spawning capability to run three independent evaluations simultaneously. Each agent has:

- A distinct **persona** that shapes its analytical lens
- **4 scoring dimensions** specific to its domain of expertise
- **Research guidelines** for web-based fact-finding when needed
- A structured **output format** for consistent, comparable results

The orchestrator collects all three reports and applies majority-rule voting to produce a final recommendation.

## License

MIT
