bc-version: [all]
domain: architecture
keywords: [claude-md, agents, visibility, setup, mode-b, curabis-standard]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When new agents are added to BCQuality and installed via Mode B update, they
are written to `.github/.agents/` but CLAUDE.md is never touched (Mode B
preserves project-specific files). This means newly installed agents are
invisible to Claude — it will not invoke them because it does not know they exist.

This gap was observed when four court agents (court, lincoln, aurelius, munger)
were installed via Mode B but remained uncallable until the developer asked
directly. Claude had no way to discover them proactively.

## Rule

After any installation or update of agent files in `.github/.agents/`, Claude
must verify that every `.agent.md` file in that directory is referenced in
`CLAUDE.md`. Any agent not listed in CLAUDE.md must be flagged to the developer
with a proposed addition before the session continues.

## What NOT to do

- Do not silently install agents without checking CLAUDE.md coverage
- Do not assume that because a file exists in `.github/.agents/` it is known to Claude
- Do not wait until session end to flag the discrepancy — flag it immediately after install
- Do not add agents to CLAUDE.md without showing the developer the proposed wording first

## Signal to watch for

After running Mode B (or any agent install), compare:

```
Get-ChildItem .github/.agents/*.agent.md | Select-Object -ExpandProperty BaseName
```

against the agent references in CLAUDE.md. Any filename present in the directory
but absent from CLAUDE.md is a gap that must be surfaced.

## Message to developer

When a gap is found, output exactly this before continuing:

```
⚠️ Ny agent installeret men ikke refereret i CLAUDE.md:

  - <agent-navn>.agent.md

Claude kan ikke kalde denne agent medmindre den tilføjes til CLAUDE.md.
Vil du have mig til at tilføje den nu?
```

Do not continue with other activity until the developer has responded.
