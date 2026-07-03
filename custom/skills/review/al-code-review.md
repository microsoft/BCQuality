---
kind: action-skill
id: al-code-review
version: 1
title: AL code review
description: Reviews AL source changes by composing the AL review leaf skills, using TCOG-specific performance guidance where available.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - custom/skills/review/al-performance-review.md
  - microsoft/skills/review/al-security-review.md
  - microsoft/skills/review/al-privacy-review.md
  - microsoft/skills/review/al-upgrade-review.md
  - microsoft/skills/review/al-style-review.md
  - microsoft/skills/review/al-ui-review.md
  - microsoft/skills/review/al-error-handling-review.md
  - microsoft/skills/review/al-events-review.md
  - microsoft/skills/review/al-interfaces-review.md
  - microsoft/skills/review/al-breaking-changes-review.md
  - microsoft/skills/review/al-web-services-review.md
---

# AL code review

Reviews AL source changes by composing the AL review leaf skills. This custom-layer variant preserves the standard BCQuality multi-domain review flow, but replaces the performance leaf with the tCOG custom performance review so local conventions participate in the same code-review route.

## Source

The sub-skills invoked by this skill are exactly those listed in frontmatter `sub-skills`. The skill does not discover sub-skills implicitly.

## Relevance

A sub-skill is relevant when both of the following hold:

- The orchestrator supplied inputs that satisfy the sub-skill's declared `inputs`.
- The orchestrator did not disable the sub-skill via configuration.

Per the DO contract, this super-skill must not filter sub-skills by diff content. Each leaf is responsible for deciding whether the task is applicable inside its own execution.

Sub-skills that fail either check are not invoked and are recorded in `skipped-sub-skills` with reason `configuration` or `not-applicable`.

## Worklist

The worklist is the list of sub-skills judged relevant by the previous step. Every sub-skill in the worklist is invoked in the Action step.

## Action

Execute the worklist as discrete iterations, one sub-skill at a time.

For each sub-skill:

1. Invoke the sub-skill with the orchestrator-supplied inputs, passing only the subset declared by that sub-skill.
2. Capture the sub-skill's full findings-report verbatim in `sub-results`.
3. If the sub-skill outcome is `failed`, keep its report in `sub-results` but do not roll its findings up into the top-level result.
4. Otherwise, append each finding from the sub-skill's `findings[]` to the super-skill's top-level `findings[]`, setting `from-sub-skill` to the producing sub-skill's `skill.id`. If the rolled-up finding uses a slug `id` rather than a reference path, prefix it with `<from-sub-skill>:` to avoid collisions.

After every sub-skill completes, perform one self-review pass over the same diff to look for concrete cross-cutting concerns that no single leaf could surface on its own. Validate each candidate against the BCQuality knowledge already loaded by the leaves:

- If a loaded knowledge file matches the concern, upgrade it to a knowledge-backed finding and attribute it to the owning sub-skill.
- If loaded knowledge explicitly contradicts the concern, suppress it.
- Otherwise, emit it as an agent finding with `references: []`, an `id` prefixed with `agent:`, `confidence` no higher than `medium`, and `severity` no higher than `minor`.

Populate `suggested-code` whenever the fix is small, local, and mechanical.

Aggregate summary counts and coverage across invoked sub-skills whose outcome is not `failed`. Agent findings produced by the super-skill contribute to counts but not to coverage.

## Output

Output conforms to the DO findings-report contract in [skills/do.md](skills/do.md), including `sub-results` and `skipped-sub-skills` for this super-skill.