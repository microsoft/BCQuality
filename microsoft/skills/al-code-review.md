---
kind: action-skill
id: al-code-review
version: 1
title: AL code review
description: Reviews AL source changes by composing the AL review leaf skills (performance, security, ...).
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - microsoft/skills/al-performance-review.md
  - microsoft/skills/al-security-review.md
---

# AL code review

Reviews AL source changes by composing the leaf AL review skills. This is the canonical reference implementation of a **super-skill** — skill authors writing composed reviews should copy its structure.

`al-code-review` does not evaluate knowledge files directly. It invokes each of its sub-skills against the same task input, collects their findings-reports, and returns a rolled-up findings-report.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). The skill produces a single JSON document conforming to the DO output contract, extended with `sub-results` and — when applicable — `skipped-sub-skills`.

## Source

The sub-skills invoked by this skill are those listed in frontmatter `sub-skills`:

- `microsoft/skills/al-performance-review.md`
- `microsoft/skills/al-security-review.md`

Additional leaf skills (for example, UX, telemetry, testing) are added by updating the `sub-skills` list. The skill does not discover sub-skills implicitly.

## Relevance

A sub-skill is relevant when both of the following hold:

- The orchestrator has supplied inputs that satisfy the sub-skill's declared `inputs`.
- The orchestrator has not disabled the sub-skill via configuration.

Per the DO contract, the super-skill MUST NOT filter sub-skills by task content. `al-code-review` does not inspect the PR diff to predict whether, for example, there is anything for `al-security-review` to find. Each leaf is responsible for its own task-level applicability decision; leaves signal non-applicability by returning `outcome: "not-applicable"` or `outcome: "no-knowledge"`.

Sub-skills that fail either check are not invoked and are recorded in `skipped-sub-skills`:

- `reason: "configuration"` when the orchestrator disabled the sub-skill.
- `reason: "not-applicable"` when the orchestrator's inputs do not satisfy the sub-skill's declared `inputs`.

## Worklist

The worklist is the list of sub-skills judged relevant by the previous step. Every sub-skill in the worklist will be invoked in the Action step.

## Action

For each sub-skill in the worklist:

1. Invoke the sub-skill with the orchestrator's inputs, passing only the subset each sub-skill declares in its `inputs`.
2. Capture the sub-skill's complete findings-report verbatim and append it to `sub-results`.
3. If the sub-skill's `outcome` is `failed`, stop here for this sub-skill: its findings are not reliable per the DO contract and MUST NOT be copied into the super-skill's top-level `findings[]` or counted in `summary.counts`.
4. Otherwise, append each entry from the sub-skill's `findings[]` to the super-skill's top-level `findings[]`, setting `from-sub-skill` to the sub-skill's `skill.id`. For non-citation findings (those whose `id` is a skill-defined slug rather than a reference path), prefix `id` with `<from-sub-skill>:` to prevent collisions across sub-skills. Other finding fields are preserved.

Aggregate `summary.counts` and `summary.coverage` as the sums across invoked sub-skills whose `outcome` is not `failed`.

`suppressed[]` at the super-skill level remains empty. Knowledge-file-level suppression is reported by each sub-skill within its own entry in `sub-results`.

Derive `outcome` using the DO rollup rules. `outcome-reason` is populated for `partial` and `failed` and SHOULD summarize per-sub-skill state, for example: *"al-security-review failed (tool timeout); al-performance-review completed."*

## Output

Output conforms to the DO output contract, extended with `sub-results` and `skipped-sub-skills`. A populated example — both leaves ran, each produced findings:

```json
{
  "skill": { "id": "al-code-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 1, "major": 1, "minor": 1, "info": 1 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/performance/filter-before-find.md",
      "severity": "major",
      "message": "FindSet is called on a record variable without any prior SetRange/SetFilter. This forces a full-table scan.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 140,
        "range": { "start-line": 140, "end-line": 144 }
      },
      "references": [
        { "path": "microsoft/knowledge/performance/filter-before-find.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-performance-review"
    },
    {
      "id": "community/knowledge/performance/use-setloadfields.md",
      "severity": "info",
      "message": "Posting routine iterates ledger entries; consider whether SetLoadFields applies per the linked guidance.",
      "references": [
        { "path": "community/knowledge/performance/use-setloadfields.md" }
      ],
      "confidence": "low",
      "from-sub-skill": "al-performance-review"
    },
    {
      "id": "microsoft/knowledge/security/no-plaintext-secrets-in-telemetry.md",
      "severity": "blocker",
      "message": "A bearer token is passed to Session.LogMessage as part of the CustomDimensions payload. The referenced guidance documents this as a platform-level data-protection violation.",
      "location": {
        "file": "src/Integration/ApiClient.Codeunit.al",
        "line": 85,
        "range": { "start-line": 85, "end-line": 89 }
      },
      "references": [
        { "path": "microsoft/knowledge/security/no-plaintext-secrets-in-telemetry.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-security-review"
    },
    {
      "id": "microsoft/knowledge/security/avoid-implicit-commit.md",
      "severity": "minor",
      "message": "An explicit COMMIT inside a posting routine may leave the ledger in an inconsistent state if subsequent steps fail.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 201
      },
      "references": [
        { "path": "microsoft/knowledge/security/avoid-implicit-commit.md" }
      ],
      "confidence": "medium",
      "from-sub-skill": "al-security-review"
    }
  ],
  "suppressed": [],
  "sub-results": [
    {
      "skill": { "id": "al-performance-review", "version": 1 },
      "outcome": "completed",
      "summary": {
        "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 1 },
        "coverage": { "worklist-size": 2, "items-evaluated": 2 }
      },
      "findings": [
        {
          "id": "microsoft/knowledge/performance/filter-before-find.md",
          "severity": "major",
          "message": "FindSet is called on a record variable without any prior SetRange/SetFilter. This forces a full-table scan.",
          "location": {
            "file": "src/Sales/PostingRoutines.Codeunit.al",
            "line": 140,
            "range": { "start-line": 140, "end-line": 144 }
          },
          "references": [
            { "path": "microsoft/knowledge/performance/filter-before-find.md" }
          ],
          "confidence": "high"
        },
        {
          "id": "community/knowledge/performance/use-setloadfields.md",
          "severity": "info",
          "message": "Posting routine iterates ledger entries; consider whether SetLoadFields applies per the linked guidance.",
          "references": [
            { "path": "community/knowledge/performance/use-setloadfields.md" }
          ],
          "confidence": "low"
        }
      ],
      "suppressed": []
    },
    {
      "skill": { "id": "al-security-review", "version": 1 },
      "outcome": "completed",
      "summary": {
        "counts": { "blocker": 1, "major": 0, "minor": 1, "info": 0 },
        "coverage": { "worklist-size": 2, "items-evaluated": 2 }
      },
      "findings": [
        {
          "id": "microsoft/knowledge/security/no-plaintext-secrets-in-telemetry.md",
          "severity": "blocker",
          "message": "A bearer token is passed to Session.LogMessage as part of the CustomDimensions payload. The referenced guidance documents this as a platform-level data-protection violation.",
          "location": {
            "file": "src/Integration/ApiClient.Codeunit.al",
            "line": 85,
            "range": { "start-line": 85, "end-line": 89 }
          },
          "references": [
            { "path": "microsoft/knowledge/security/no-plaintext-secrets-in-telemetry.md" }
          ],
          "confidence": "high"
        },
        {
          "id": "microsoft/knowledge/security/avoid-implicit-commit.md",
          "severity": "minor",
          "message": "An explicit COMMIT inside a posting routine may leave the ledger in an inconsistent state if subsequent steps fail.",
          "location": {
            "file": "src/Sales/PostingRoutines.Codeunit.al",
            "line": 201
          },
          "references": [
            { "path": "microsoft/knowledge/security/avoid-implicit-commit.md" }
          ],
          "confidence": "medium"
        }
      ],
      "suppressed": []
    }
  ]
}
```

The empty-corpus case — BCQuality's state until knowledge files land — rolls up to `no-knowledge`:

```json
{
  "skill": { "id": "al-code-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": [],
  "sub-results": [
    {
      "skill": { "id": "al-performance-review", "version": 1 },
      "outcome": "no-knowledge",
      "summary": { "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 }, "coverage": { "worklist-size": 0, "items-evaluated": 0 } },
      "findings": [],
      "suppressed": []
    },
    {
      "skill": { "id": "al-security-review", "version": 1 },
      "outcome": "no-knowledge",
      "summary": { "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 }, "coverage": { "worklist-size": 0, "items-evaluated": 0 } },
      "findings": [],
      "suppressed": []
    }
  ]
}
```
