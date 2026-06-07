---
kind: action-skill
id: al-test-validator
version: 1
title: AL test validator
description: Flags AL tests with no assertions, missing edge cases, weak names, poor isolation, and tests that exercise implementation not behaviour.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL test validator

Reads AL test codeunits and reports whether each test is meaningful, well-named, and correctly configured. The failure modes are familiar: a `[Test]` with no `Assert.*`, a name that describes the call site instead of the expected behaviour, an isolation attribute set wrong for an AI test, a test that exercises implementation detail rather than behaviour, or a missing edge case the domain demands. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the changed test files) or a `file-path` (a single test codeunit). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` as the citable candidate set across every enabled layer: test-attribute, isolation, transaction-model, and assertion-pattern rules are the authoritative basis for most findings here. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Project-specific conventions (a naming pattern, a project helper codeunit) rarely map onto a curated file, so a finding about them is an agent finding within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the tested objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the test surface under review. Before raising findings, build a mental model of what the tests should assert: identify the business domain, the invariants and state transitions the system under test enforces, and the edge cases (empty sets, max values, null or blank fields, permission failures, date boundaries) the domain demands. Then compute overlap against:

- Every `[Test]` procedure in the changed or supplied test codeunits, and whether each has at least one `Assert.*` or `asserterror` expectation.
- Codeunit configuration: `Subtype = Test`; for AI tests `TestType = AITest`, `TestPermissions = Disabled`, and for agent tests `RequiredTestIsolation = Disabled`; suite-setup guards via `AITTestContext.IsSuiteSetupDone()`.
- Test names: behaviour-describing (`ReleaseRegistrationShouldFailWhenOverCapacity`) versus implementation-named (`TestReleaseRegistration`) versus opaque (`TestProc01`).
- Anti-patterns: assertions inside an unguarded loop, a test calling `Commit()`, dependence on global state with no seed, deep mocking, a single test asserting multiple behaviours, undocumented `Sleep()`.
- Mutation survivors, when supplied: which test should have caught each survivor and which assertion it lacks.

A curated `testing` file enters the worklist when its `keywords` intersect these tokens. Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted test, evaluate it against the model and the worklisted knowledge. A missing assertion, a `Commit()` in a test, an assertion inside an unguarded loop, global-state dependence, or an isolation/transaction-model attribute wrong for the test type is a defect: when a curated `testing` file states the rule, emit a knowledge-backed finding citing it (`id` equal to the file path, `severity` up to `major`, `blocker` only when the file states a platform-level guarantee, `confidence` `high` for an unambiguous match). Implementation-named tests, single-test-multiple-behaviour, missing edge cases, and project-convention drift rarely map onto a curated file: emit them as agent findings within this skill's domain (`references: []`, `id` slug prefixed `agent:`, `confidence` capped at `medium`, `severity` capped at `minor`, self-contained `message`). When the underlying impact would otherwise be major (a missing assertion that lets a mutation survive), keep the emitted `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a curated rule before it can gate. Hold every agent candidate to the precision bar in `skills/do.md`: steelman that the test is deliberate (a no-throw contract is sometimes the real contract) before emitting, and omit when in doubt. Set `suggested-code` when the fix is mechanical (rename a test, add a `[HandlerFunctions(...)]` attribute, add the missing isolation attribute); otherwise set `suggested-code-omission-reason`.

Outcome selection: `completed` when every worklisted test was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task carries no AL test to validate; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Findings without a knowledge file are agent findings (`references: []`, `agent:` id, severity capped at `minor`); findings citing a `testing` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "al-test-validator", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/testing/transactionmodel-attribute-governs-test-transactions.md",
      "severity": "major",
      "message": "PostAndAssertNoChange posts a document but TransactionModel is unset, so posting rolls back at test end and the state-after-post assertion never observes a committed change.",
      "location": { "file": "test/EventRegistrationTests.al", "line": 88 },
      "references": [ { "path": "microsoft/knowledge/testing/transactionmodel-attribute-governs-test-transactions.md" } ],
      "confidence": "high"
    },
    {
      "id": "agent:implementation-named-test",
      "severity": "minor",
      "message": "Test procedure TestReleaseRegistration names the call site, not the expected behaviour. Rename to describe the outcome, for example ReleaseRegistrationShouldEmitTelemetry, so a failure reads as a broken contract.",
      "location": { "file": "test/EventRegistrationTests.al", "line": 40 },
      "references": [],
      "confidence": "medium",
      "suggested-code": "    procedure ReleaseRegistrationShouldEmitTelemetry()"
    }
  ],
  "suppressed": []
}
```
