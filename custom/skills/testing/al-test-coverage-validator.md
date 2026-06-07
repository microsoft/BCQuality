---
kind: action-skill
id: al-test-coverage-validator
version: 1
title: AL test coverage validator
description: Reports AL test coverage shape and identifies untested branches, error handlers, and edge cases without gating.
inputs: [pr-diff, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL test coverage validator

Reports what a production AL change is and is not covered by, and how meaningfully. For each production procedure or trigger the diff touches, it classifies coverage as covered, shallow, uncovered, or not-applicable, and surfaces uncovered branches, error handlers, and edge cases. It reports; it does not gate. The hard PASS/FAIL decision lives in `al-test-coverage-enforcer`. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the production change to assess) and a `repository` (so the test codeunit index and any coverage report can be read). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` as the citable candidate set across every enabled layer; coverage is structural and rarely maps onto a curated rule, but a published `testing` rule about minimum coverage for a specific area would back a finding. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Most coverage observations are agent findings within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the production surface the diff touches and the coverage signal for each:

- Every production procedure and trigger (`OnInsert`, `OnValidate`, and so on) added or changed in the diff, excluding test files.
- For each, the test index: which test codeunits reference it directly or via a clear chain, and whether any asserts an outcome that depends on its body.
- Branch and error-handler coverage: uncovered `if`/`case` arms, uncovered `Error()` paths, uncovered `else` guards.
- Edge-case coverage where the procedure can encounter them: nulls, empty sets, max values, permission failures, date boundaries.
- Bug-fix regression coverage: when the diff message references a work item or fix, whether a test names it.
- Mutation survivors, when supplied: mutants that survived because no test caught the logic change.

A curated `testing` file enters the worklist only when its `keywords` intersect a real coverage rule. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

Classify each worklisted procedure or trigger: `covered` (a test calls it and asserts an outcome exercising its body), `shallow` (a test calls it but asserts nothing depending on its return or side effects), `uncovered` (no test references it), or `n/a` (deleted or a pure pass-through). Emit a finding for every gap. These are agent findings within this skill's domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:uncovered-procedure`, `agent:shallow-coverage`, `agent:uncovered-branch`, `agent:missing-edge-case`), `confidence` capped at `medium`, `severity` capped at `minor` (this skill reports, it does not gate, so even a wholly uncovered new public procedure is `minor` here and the enforcer raises it). The `message` is self-contained: name the object and procedure, the coverage class, and the concrete gap (which branch, which edge case, which assertion is missing). Where a published `testing` rule genuinely backs a coverage requirement, upgrade that finding to knowledge-backed and cite the file. Hold every agent candidate to the precision bar in `skills/do.md`: a pass-through that genuinely needs no test is not a gap. The fix is a new or extended test rather than a local edit, so omit `suggested-code` and set `suggested-code-omission-reason` to `coverage gap is closed by adding a test, not a local code edit`.

When the test index is missing, report only what static analysis of the diff yields (new procedure count, new trigger count) and state the limitation in an `info` finding.

Outcome selection: `completed` when every touched procedure was classified (including an empty `findings` when coverage is complete); `not-applicable` when the diff has no production AL surface; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Coverage gaps are agent findings (`references: []`, `agent:` id, severity capped at `minor`); the gating decision lives in `al-test-coverage-enforcer`.

```json
{
  "skill": { "id": "al-test-coverage-validator", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 2, "info": 0 },
    "coverage": { "worklist-size": 8, "items-evaluated": 8 }
  },
  "findings": [
    {
      "id": "agent:uncovered-procedure",
      "severity": "minor",
      "message": "codeunit 50101 'Event Registration Mgt'.ReleaseRegistration is touched by the diff but no test codeunit references it directly or indirectly. Add a covering test. The enforcer will gate on this; here it is reported only.",
      "location": { "file": "src/Sales/EventRegistrationMgt.Codeunit.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "coverage gap is closed by adding a test, not a local code edit"
    },
    {
      "id": "agent:shallow-coverage",
      "severity": "minor",
      "message": "ValidateAttendeeCount is called by a test but the test asserts nothing depending on its outcome, so the resulting error path is not actually verified. Add an asserterror on the over-capacity case.",
      "location": { "file": "src/Sales/EventRegistrationMgt.Codeunit.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "coverage gap is closed by adding a test, not a local code edit"
    }
  ],
  "suppressed": []
}
```
