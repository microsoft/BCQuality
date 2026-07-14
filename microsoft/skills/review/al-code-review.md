---
kind: action-skill
id: al-code-review
version: 1
title: AL code review
description: Reviews AL source changes by composing the AL review leaf skills, one per knowledge domain.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - microsoft/skills/review/al-performance-review.md
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
  - microsoft/skills/review/al-testing-review.md
  - microsoft/skills/review/al-data-modeling-review.md
  - microsoft/skills/review/al-appsource-review.md
  - microsoft/skills/review/al-telemetry-review.md
---

# AL code review

Reviews AL source changes by composing the leaf AL review skills. This is the canonical reference implementation of a **super-skill** — skill authors writing composed reviews should copy its structure.

`al-code-review` does not evaluate knowledge files directly. It invokes each of its sub-skills against the same task input, collects their findings-reports, and then performs its own **self-review pass** over the diff using the agent's built-in BC and AL knowledge. BCQuality knowledge is an additive layer: anything the sub-skills found is cited from BCQuality, and anything the agent finds on its own is validated against BCQuality (cited if matched, suppressed if contradicted, surfaced as an **agent finding** otherwise). The result is a single rolled-up findings-report that mixes knowledge-backed and agent findings, each clearly tagged via `from-sub-skill`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). The skill produces a single JSON document conforming to the DO output contract, extended with `sub-results` and — when applicable — `skipped-sub-skills`.

## Source

The sub-skills invoked by this skill are those listed in frontmatter `sub-skills`. Additional leaf skills are added by updating the `sub-skills` list. The skill does not discover sub-skills implicitly.

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

### Execution discipline (mandatory)

The Action step is a sequence of **discrete iterations**, not one combined generation. The contract requires the super-skill to invoke each sub-skill in turn and then perform a self-review pass. Concretely this means:

- Treat each sub-skill in the worklist as its own pass: read the sub-skill's instructions, apply its Source → Relevance → Worklist → Action steps to the orchestrator-supplied inputs, and produce that sub-skill's complete findings-report before moving on.
- Do not collapse multiple sub-skills into one shared reasoning step. Each sub-skill has a distinct knowledge subset and a distinct evaluation procedure; sharing one rolled-up scan dilutes per-skill attention and causes leaves to silently underreport (this has been observed in production: leaf skills returned empty `findings[]` while their standalone runs against the same diff produced multiple matches).
- The agent self-review pass is its own final iteration. Begin it only after every sub-skill in the worklist has completed and its sub-result is recorded.
- Sub-skills are independent: re-walking the diff once per sub-skill is correct and expected. The output schema accommodates this — `sub-results` carries one entry per sub-skill, each a complete findings-report.

### Roll up sub-skill findings

For each sub-skill in the worklist, executed one at a time per the discipline above:

1. Invoke the sub-skill with the orchestrator's inputs, passing only the subset each sub-skill declares in its `inputs`.
2. Capture the sub-skill's complete findings-report verbatim and append it to `sub-results`.
3. If the sub-skill's `outcome` is `failed`, stop here for this sub-skill: its findings are not reliable per the DO contract and MUST NOT be copied into the super-skill's top-level `findings[]` or counted in `summary.counts`.
4. Otherwise, append each entry from the sub-skill's `findings[]` to the super-skill's top-level `findings[]`, setting `from-sub-skill` to the sub-skill's `skill.id`. For non-citation findings (those whose `id` is a skill-defined slug rather than a reference path), prefix `id` with `<from-sub-skill>:` to prevent collisions across sub-skills. Other finding fields are preserved.

### Agent self-review pass

Each leaf sub-skill emits both knowledge-backed findings and, per its own contract, agent findings within its own domain. After every sub-skill has produced its sub-result, perform a super-skill self-review pass against the same task input. The goal of this pass is to surface defects the agent recognises on its own that **no single leaf could have surfaced** because they cross domain boundaries — architecture-level issues that touch performance and reliability at once, error-handling gaps that span security and UX, resource-lifecycle patterns that affect both correctness and performance, and similar cross-cutting concerns. BCQuality is an **additive** knowledge layer: it augments the agent's review judgement, it does not replace it.

The self-review *reasoning* is mandatory — you MUST actually perform the cross-cutting analysis on every real-size PR, not skip it. But the pass need not produce any output: emitting **zero** agent findings is a valid, expected outcome whenever no candidate clears the precision bar in `skills/do.md` (*Agent findings*). Do not invent or pad findings to prove the pass ran. Always reason; emit only what survives the bar.

Frame the pass by cross-cutting concerns — architecture, error handling, resource lifecycle — and by the seams between leaf domains. Do not duplicate domain-specific reasoning that belongs in a leaf: a security-only concern is the security leaf's responsibility, not the super-skill's. The super-skill pass adds value where no individual leaf has the right scope.

For every candidate the agent identifies in this pass:

1. **Validate against BCQuality knowledge.** Check the candidate against the knowledge files the sub-skills have already loaded for this task (visible via their `references` and `suppressed` lists in `sub-results`).
   - If a BCQuality knowledge file matches the candidate, upgrade it to a knowledge-backed finding: cite the file in `references`, set `id` to the file's path, set `from-sub-skill` to the sub-skill that owns that knowledge domain, and merge with or deduplicate against any sub-skill finding that already covers the same concern at the same location.
   - If a BCQuality knowledge file **explicitly contradicts** the candidate (its `## Best Practice` or `## Anti Pattern` says the opposite of what the agent flagged), suppress the candidate and do not surface it.
   - Otherwise the candidate has no BCQuality coverage; emit it as a super-skill agent finding.
2. **Emit agent finding.** Per DO's *Agent findings* rules:
   - `from-sub-skill: "agent"` (the super-skill itself produced it)
   - `references: []`
   - `id` is a skill-defined slug prefixed with `agent:` (for example, `agent:missing-error-handling-on-http-call`).
   - `confidence` capped at `medium`.
   - `severity` capped at `minor` — agent findings are advisory and non-gating per `skills/do.md`; never assign `major` or `blocker` to a finding with no knowledge file behind it.
   - `message` is non-empty and self-contained, describing both the issue and a concrete recommendation. A consumer rendering the finding has no knowledge-file footer to fall back on.
   - `suggested-code` MUST be set when the fix is small, local, and mechanical. If a mechanical-looking finding omits it, set `suggested-code-omission-reason` with the reason (for example, the fix spans non-contiguous code or requires choosing a real production value).

Leaf-level agent findings (those with `references: []` inside a sub-skill's report) are rolled up into the super-skill's top-level `findings[]` like any other sub-skill finding — they keep their `from-sub-skill: <leaf-id>` attribution and are not rewritten. They are not subject to the "MUST validate against knowledge" step above, because each leaf has already validated within its own domain.

### Suggested-code guidance

For both knowledge-backed findings rolled up from sub-skills and agent findings emitted in the self-review pass, populate `findings[].suggested-code` whenever a concrete code replacement is unambiguous from the diff context. This is a MUST for small, local, mechanical fixes. The payload MUST be a literal replacement for the source lines covered by `location` (typically a single line, or the line range in `location.range`) — no diff markers, fences, or commentary. Examples of good candidates: deleting dead code after `exit`, replacing `Count() > 0` with `not IsEmpty()`, moving an inline `Label` declaration to a codeunit-level `var` block, adding a missing property, replacing string-concatenated `Error`, changing an over-broad permission token, fixing whitespace or keyword casing. Skip `suggested-code` only when the fix requires choosing between multiple defensible alternatives, when the fix spans non-contiguous code, or when the surrounding context the agent cannot see could change the answer. If a mechanical-looking finding omits `suggested-code`, set `suggested-code-omission-reason`.

Sub-skills MAY also emit `suggested-code` when their knowledge file unambiguously implies the replacement (the `.good.al` and `.bad.al` companion examples are useful here). The super-skill copies the field through unchanged.

### Summary and rollup

Aggregate `summary.counts` and `summary.coverage` as the sums across invoked sub-skills whose `outcome` is not `failed`. Agent findings emitted by the super-skill itself contribute to `summary.counts` but not to `summary.coverage` (coverage is a sub-skill worklist metric and is undefined for self-review).

`suppressed[]` at the super-skill level remains empty. Knowledge-file-level suppression is reported by each sub-skill within its own entry in `sub-results`.

Derive `outcome` using the DO rollup rules. `outcome-reason` is populated for `partial` and `failed` and SHOULD summarize per-sub-skill state, for example: *"al-security-review failed (tool timeout); al-performance-review completed."*

## Output

Output conforms to the DO output contract, extended with `sub-results` and `skipped-sub-skills`. A populated example — both leaves ran, each produced findings:

```json
{
  "skill": { "id": "al-code-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 1, "major": 1, "minor": 3, "info": 0 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/performance/apply-filters-before-iterating.md",
      "severity": "major",
      "message": "The Country/Region Code predicate is evaluated inside the loop instead of with SetRange before FindSet, so every row crosses the database boundary.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 140,
        "range": { "start-line": 140, "end-line": 144 }
      },
      "references": [
        { "path": "microsoft/knowledge/performance/apply-filters-before-iterating.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-performance-review"
    },
    {
      "id": "microsoft/knowledge/performance/use-setloadfields-for-partial-records.md",
      "severity": "minor",
      "message": "The loop reads only a small subset of fields from a wide table without SetLoadFields, transferring every column for each row.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 152
      },
      "references": [
        { "path": "microsoft/knowledge/performance/use-setloadfields-for-partial-records.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-performance-review"
    },
    {
      "id": "microsoft/knowledge/security/secrettext-for-credentials.md",
      "severity": "blocker",
      "message": "A bearer token is declared as a Text parameter and passed through the HTTP request path as plain text. The referenced guidance requires credentials to flow as SecretText end-to-end.",
      "location": {
        "file": "src/Integration/ApiClient.Codeunit.al",
        "line": 85,
        "range": { "start-line": 85, "end-line": 89 }
      },
      "references": [
        { "path": "microsoft/knowledge/security/secrettext-for-credentials.md" }
      ],
      "confidence": "high",
      "from-sub-skill": "al-security-review"
    },
    {
      "id": "microsoft/knowledge/security/secrets-isolated-storage.md",
      "severity": "minor",
      "message": "A setup table stores an API key in an ordinary Text field, exposing it through table reads and exports. Persist it in IsolatedStorage instead.",
      "location": {
        "file": "src/Integration/ExternalServiceSetup.Table.al",
        "line": 12
      },
      "references": [
        { "path": "microsoft/knowledge/security/secrets-isolated-storage.md" }
      ],
      "confidence": "medium",
      "from-sub-skill": "al-security-review"
    },
    {
      "id": "agent:missing-error-handling-on-http-client",
      "severity": "minor",
      "message": "HttpClient.Send is called without inspecting the response status or wrapping the call in a TryFunction. Network or remote-server failures will surface as runtime errors to the user. Recommendation: branch on the HttpResponseMessage.IsSuccessStatusCode and either retry, surface a controlled error, or fall back, depending on the integration's contract.",
      "location": {
        "file": "src/Integration/ApiClient.Codeunit.al",
        "line": 60,
        "range": { "start-line": 60, "end-line": 64 }
      },
      "references": [],
      "confidence": "medium",
      "from-sub-skill": "agent"
    }
  ],
  "suppressed": [],
  "sub-results": [
    {
      "skill": { "id": "al-performance-review", "version": 1 },
      "outcome": "completed",
      "summary": {
        "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
        "coverage": { "worklist-size": 2, "items-evaluated": 2 }
      },
      "findings": [
        {
          "id": "microsoft/knowledge/performance/apply-filters-before-iterating.md",
          "severity": "major",
          "message": "The Country/Region Code predicate is evaluated inside the loop instead of with SetRange before FindSet, so every row crosses the database boundary.",
          "location": {
            "file": "src/Sales/PostingRoutines.Codeunit.al",
            "line": 140,
            "range": { "start-line": 140, "end-line": 144 }
          },
          "references": [
            { "path": "microsoft/knowledge/performance/apply-filters-before-iterating.md" }
          ],
          "confidence": "high"
        },
        {
          "id": "microsoft/knowledge/performance/use-setloadfields-for-partial-records.md",
          "severity": "minor",
          "message": "The loop reads only a small subset of fields from a wide table without SetLoadFields, transferring every column for each row.",
          "location": {
            "file": "src/Sales/PostingRoutines.Codeunit.al",
            "line": 152
          },
          "references": [
            { "path": "microsoft/knowledge/performance/use-setloadfields-for-partial-records.md" }
          ],
          "confidence": "high"
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
          "id": "microsoft/knowledge/security/secrettext-for-credentials.md",
          "severity": "blocker",
          "message": "A bearer token is declared as a Text parameter and passed through the HTTP request path as plain text. The referenced guidance requires credentials to flow as SecretText end-to-end.",
          "location": {
            "file": "src/Integration/ApiClient.Codeunit.al",
            "line": 85,
            "range": { "start-line": 85, "end-line": 89 }
          },
          "references": [
            { "path": "microsoft/knowledge/security/secrettext-for-credentials.md" }
          ],
          "confidence": "high"
        },
        {
          "id": "microsoft/knowledge/security/secrets-isolated-storage.md",
          "severity": "minor",
          "message": "A setup table stores an API key in an ordinary Text field, exposing it through table reads and exports. Persist it in IsolatedStorage instead.",
          "location": {
            "file": "src/Integration/ExternalServiceSetup.Table.al",
            "line": 12
          },
          "references": [
            { "path": "microsoft/knowledge/security/secrets-isolated-storage.md" }
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
