---
kind: action-skill
id: al-extended-review
version: 1
title: AL extended review
description: Composes the custom-layer AL review leaves (multi-tenancy, permissions, events, obsolescence, integration, upgrade) that complement the platform al-code-review.
inputs: [pr-diff, file-path, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - custom/skills/review/al-multitenancy-reviewer.md
  - custom/skills/review/al-permission-set-auditor.md
  - custom/skills/review/al-event-subscriber-auditor.md
  - custom/skills/review/al-obsolete-tracker.md
  - custom/skills/review/al-integration-pattern-reviewer.md
  - custom/skills/review/al-upgrade-checker.md
---

# AL extended review

Composes the custom-layer AL review leaves that cover concerns the platform `microsoft/skills/review/al-code-review` does not: multi-tenant and cross-company safety, permission-set coverage, event-subscriber discipline, obsolescence hygiene, modern integration patterns, and upgrade-codeunit coverage. This is a super-skill: it does not evaluate knowledge files directly, it invokes its sub-skills and rolls up their findings-reports following the DO composition contract.

Run this alongside the platform `al-code-review` (which covers performance, security, privacy, upgrade, style, and UI) for a full review surface. An orchestrator invokes this skill with a `pr-diff`, a `file-path`, or a `repository`, and receives one JSON document conforming to the DO output contract, extended with `sub-results` and, where applicable, `skipped-sub-skills`.

## Source

The sub-skills invoked are exactly those listed in frontmatter `sub-skills`:

- `custom/skills/review/al-multitenancy-reviewer.md`
- `custom/skills/review/al-permission-set-auditor.md`
- `custom/skills/review/al-event-subscriber-auditor.md`
- `custom/skills/review/al-obsolete-tracker.md`
- `custom/skills/review/al-integration-pattern-reviewer.md`
- `custom/skills/review/al-upgrade-checker.md`

Additional leaves are added by editing this list; the skill does not discover sub-skills implicitly. Composition is flat: every entry is a leaf skill, never another super-skill.

## Relevance

A sub-skill is relevant when the orchestrator has supplied inputs that satisfy the sub-skill's declared `inputs` and has not disabled it via configuration. Per the DO contract, this super-skill MUST NOT filter sub-skills by task content (it does not inspect the diff to guess whether a leaf will find anything). Each leaf decides its own task-level applicability and signals it by returning `outcome: "not-applicable"` or `outcome: "no-knowledge"`. Sub-skills failing the input or configuration check are not invoked and are recorded in `skipped-sub-skills` with `reason: "not-applicable"` or `reason: "configuration"`.

## Worklist

The worklist is the set of sub-skills judged relevant by the previous step. Every sub-skill in the worklist is invoked in the Action step; the rest go to `skipped-sub-skills`.

## Action

Invoke each worklisted sub-skill as its own discrete pass, one at a time, passing only the subset of inputs the sub-skill declares. Capture each sub-skill's complete findings-report verbatim into `sub-results`. For any sub-skill whose `outcome` is `failed`, do not copy its findings into the top-level `findings[]` or counts. Otherwise append each of its findings to the top-level `findings[]` with `from-sub-skill` set to the sub-skill's `skill.id`, prefixing slug `id` values (non-citation findings) with `<from-sub-skill>:` to avoid collisions; citation-based findings keyed by repo-relative path are left unchanged.

After every sub-skill has produced its sub-result, perform a super-skill self-review pass for cross-cutting concerns that no single leaf could surface (for example an obsolescence change that is also a cross-tenant data path, or an integration change that is also an upgrade-schema change). Validate each candidate against the knowledge the leaves already loaded: a matching knowledge file upgrades it to a knowledge-backed finding, a contradicting file suppresses it, otherwise emit it as a super-skill agent finding (`from-sub-skill: "agent"`, `references: []`, `id` slug prefixed `agent:`, `confidence` capped at `medium`, `severity` capped at `minor`, self-contained `message`). Hold every candidate to the precision bar in `skills/do.md`. Set `suggested-code` for mechanical fixes, otherwise `suggested-code-omission-reason`.

Derive `outcome` using the DO rollup rules, aggregate `summary.counts` and `summary.coverage` across invoked non-failed sub-skills, and populate `outcome-reason` for `partial` and `failed`. The top-level `suppressed[]` stays empty; knowledge-file suppression is reported by each leaf inside its own `sub-results` entry.

## Output

Output conforms to the DO output contract, extended with `sub-results` (one complete findings-report per invoked sub-skill) and `skipped-sub-skills`. A representative shape:

```json
{
  "skill": { "id": "al-extended-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 2, "info": 0 },
    "coverage": { "worklist-size": 6, "items-evaluated": 6 }
  },
  "findings": [
    {
      "id": "custom/knowledge/integration/never-call-external-services-from-posting.md",
      "severity": "major",
      "message": "HttpClient.Send is called from an OnAfterPostSalesDoc subscriber. Posting locks are held; stage the call on the Integration Message and let the Job Queue send it.",
      "location": { "file": "src/Integration/PostHooks.Codeunit.al", "line": 42 },
      "references": [
        { "path": "custom/knowledge/integration/never-call-external-services-from-posting.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-integration-pattern-reviewer"
    },
    {
      "id": "al-permission-set-auditor:missing-object-in-permission-set",
      "severity": "minor",
      "message": "Table 50123 \"Shipment Buffer\" is defined by the extension but does not appear in any permission set. Add it before AppSource submission.",
      "location": { "file": "src/Shipment/ShipmentBuffer.Table.al", "line": 1 },
      "references": [],
      "confidence": "medium",
      "from-sub-skill": "al-permission-set-auditor"
    }
  ],
  "suppressed": [],
  "sub-results": [
    {
      "skill": { "id": "al-integration-pattern-reviewer", "version": 1 },
      "outcome": "completed",
      "summary": { "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 }, "coverage": { "worklist-size": 3, "items-evaluated": 3 } },
      "findings": [],
      "suppressed": []
    }
  ]
}
```
