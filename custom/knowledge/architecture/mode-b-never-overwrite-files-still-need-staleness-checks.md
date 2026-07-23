---
bc-version: [all]
domain: architecture
keywords: [mode-b, heartbeat, staleness, reconciliation, never-overwrite, drift]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Mode B: "never overwrite" files still need staleness checks

## Description

Files that Mode B ("Opdater CURABIS Standard fra BCQuality") marks as "never overwrite" —
because they protect legitimate developer or team customization — must still get a targeted
staleness check against known-bad patterns, with a proposed and confirmed fix. "Never
overwrite" must not mean "never re-examined." Without this, a bug introduced into the
template before a repo's copy was created persists in that repo forever, immune to every
future Mode B run, no matter how many times it executes.

## Why This Matters

`CLAUDE.md` already has this pattern: Mode B checks its `## BCQuality` section for obsolete
forms (raw GitHub URLs, references to the abandoned `Curabis/BCQuality` fork, hardcoded
per-developer paths) and proposes a fix when found. `HEARTBEAT.md` had no equivalent check —
only a blanket "create if missing, never overwrite." A stale `Curabis/BCQuality` PR-check
reference (the fork is dead; the active repo is `Curabis/QualityHub`) sat undetected in the
template and in every repo's deployed copy, because three layers all skipped it: Mode B
explicitly never re-touches the file, Rømer's inspection round does not include it, and
Florence — who reads the file every round — has no self-audit mechanism and silently reports
"Routine: no open PRs" against a repository that will never have any, because it is not the
one anyone opens PRs against anymore.

## What Counts As A Violation

- A file is marked "never overwrite" in Mode B's reconciliation table with no accompanying
  staleness check for known-bad content patterns.
- A known-bad pattern is fixed in a template but Mode B has no mechanism to propose the same
  fix in repos whose copy predates the fix.

## Correct Pattern

For every "never overwrite" file in Mode B's table, add a staleness check mirroring the
`CLAUDE.md` obsolete-forms check:

    1. Check the existing file for known-bad patterns (maintained list, e.g. references to
       `Curabis/BCQuality` instead of `Curabis/QualityHub`).
    2. If a match is found, show the specific line(s) and the proposed corrected line(s).
    3. Ask for confirmation before editing — never silently rewrite the file.
    4. Preserve everything else in the file untouched (this is a targeted line fix, not a
       template re-apply).

## Verification

For each row in Mode B's reconciliation table marked "never overwrite," confirm the setup
agent documentation includes a paired staleness-check step naming at least one concrete
known-bad pattern to look for. A "never overwrite" row with no staleness check is this rule
being violated.
