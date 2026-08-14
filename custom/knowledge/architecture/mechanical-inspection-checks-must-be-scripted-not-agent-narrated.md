---
bc-version: [all]
domain: architecture
keywords: [rømer, inspection, mechanical, agent-persona, cost, reliability, governance]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Mechanical inspection checks must be scripted, not agent-narrated

## Description

Edison's own design already establishes the pattern: mechanical detection is
cheap and deterministic, agent judgment is reserved for genuine divergence
that requires interpreting intent or context. Rømer's standards-inspection
round does not yet follow its own portfolio's principle — several of its
stations (file presence, version-string comparison, path checks) are purely
mechanical, yet every station runs through a full agent persona narrating
the check.

This has two costs, not one. The obvious cost is efficiency: agent-persona
invocation is more expensive and slower than a deterministic script for a
check that has exactly one correct answer. The less obvious cost is
reliability: a mechanical check narrated by an LLM inherits the same
non-deterministic surface as the judgment checks sitting next to it in the
same pass — nothing structurally forces a hard comparison to actually run
before the station is reported as passed.

## Rule

Any inspection or review agent whose stations mix deterministic checks
(exists / matches / equals) with judgment checks (interpret / assess /
decide) must split them:

1. **Mechanical stations** — implemented as a script, run outside the agent
   persona; the agent only reads and summarizes the script's output.
2. **Judgment stations** — kept as agent reasoning, invoked only when the
   mechanical layer reports a divergence or when interpretation is
   genuinely required.

The split is designed once, at the station level, when the inspector is
authored or revised — not re-decided per run.

## What NOT to do

- Do not narrate a mechanical check through an agent "for consistency of
  voice" — consistency of report format can be templated without paying
  for a full reasoning pass
- Do not use this rule to strip judgment stations down to scripts — some
  of Rømer's stations (e.g. divergence framing for Ferencz) genuinely
  require interpretation and must stay agent-driven
- Do not treat this as a one-time refactor with no upkeep — a newly added
  station must be classified mechanical-or-judgment before it ships, not
  added by default to the agent-narrated set

## Signal to watch for

An inspection round where every station's description is phrasable as
"check whether X equals/exists/matches Y" and none require reading intent
from surrounding context, yet the round is still invoked as a single agent
persona pass rather than a script with agent summary.

## Message to developer

When authoring or revising an inspection-style agent, classify each station
before writing its logic: if the answer is derivable by direct comparison,
script it; if it requires judgment, keep it in the agent. Mixed rounds
should show their scripted stations' raw output alongside the agent's
judgment-station findings, not blend both into one narrated pass.
