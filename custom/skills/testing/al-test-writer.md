---
kind: action-skill
id: al-test-writer
version: 1
title: AL test writer
description: Generates AL test codeunits for a target production object as findings carrying the test source, the TDD red step.
inputs: [object-list, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL test writer

Generates Business Central AL test codeunits that exercise a target production object and assert specific behaviours. This is a generator-style skill: it expresses each generated test codeunit as a finding whose `suggested-code` carries ready-to-drop AL, with the `## Action` step explaining what is generated. The contract is the TDD red step: the generated test must fail against the current production code and pass once the intended behaviour is implemented. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with an `object-list` (the target objects to cover) and a `file-path` (the production AL under test, plus the behaviour spec the caller supplies). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` as the citable candidate set across every enabled layer: test-attribute, isolation, transaction-model, and assertion-pattern rules govern how the generated codeunit must be shaped, so a finding that matches a curated rule cites that file. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where no curated rule covers a concrete generation choice, this skill emits an agent finding within its own domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the target objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the generation work the task actually requires:

- One target per entry in `object-list`: a codeunit, table, page, or report whose behaviour the caller's spec describes.
- The behaviour spec: which inputs should produce which outcome, side effect, or error. If the spec is missing for a target, that target produces no test and is reported as `info` rather than a guessed behaviour.
- The project's existing test conventions (helper codeunits, fakes, naming pattern, assigned test object ID range) read from the supplied source.

A curated `testing` knowledge file enters the worklist when its `keywords` intersect the tokens of the target (`Subtype = Test`, `TestType = AITest`, `RequiredTestIsolation`, `TestPermissions`, `HandlerFunctions`, `Library Assert`, `Commit`, isolation, transaction-model). Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each target in the worklist, generate an AL test codeunit. Set the codeunit attributes for the test type: `Subtype = Test` with `TestPermissions = Disabled` for a regular AL test; add `TestType = AITest` for a Copilot prompt test; add `RequiredTestIsolation = Disabled` as well for an agent accuracy test. Every generated `[Test]` procedure carries a behaviour-describing name (the `Given_When_Then` or `Behaviour_Should_Outcome` pattern), self-seeding setup with no production-data dependence, an invocation of the target procedure or trigger, at least one `Assert.*` call validating the outcome, and `[HandlerFunctions(...)]` where a modal or confirmation is expected. The generated assertions must fail against the current production code (the TDD red contract); when that cannot be guaranteed for a target, say so plainly in the finding `message`.

Emit one finding per generated test codeunit. Where a curated `testing` knowledge file backs the generation choice (for example an isolation or transaction-model rule the generated attributes satisfy), cite it: `id` equal to the file path, `references` carrying it, `confidence` `high` for an unambiguous match, `severity` `info` (a generator produces artifacts, not gating defects). Where no curated file applies, emit an agent finding: `references: []`, `id` slug prefixed `agent:` (for example `agent:generated-test-codeunit`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the target, the asserted behaviours, and the developer follow-up (implement the behaviour so the red test goes green). Put the generated AL in `suggested-code` since the artifact is mechanical; the `message` states what was generated and the TDD-red status. When a target lacks a behaviour spec, emit an `info` finding asking for the spec and omit `suggested-code` with `suggested-code-omission-reason` set to `behaviour spec missing for target`. Hold any agent finding to the precision bar in `skills/do.md`.

Outcome selection: `completed` when every worklist target was processed (including when no AL could be generated for lack of a spec); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task supplies no AL target to cover; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-test-writer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "agent:generated-test-codeunit",
      "severity": "minor",
      "message": "Generated test codeunit 50202 'Event Registration Tests' covering ReleaseRegistration. Asserts 'Capacity exceeded' is raised when attendee count exceeds capacity. Fails on current code (red); implement the capacity validation in Event Registration Mgt.ReleaseRegistration to make it pass.",
      "location": { "file": "test/EventRegistrationTests.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code": "codeunit 50202 \"Event Registration Tests\"\n{\n    Subtype = Test;\n    TestPermissions = Disabled;\n\n    [Test]\n    procedure ReleaseRegistrationShouldFailWhenOverCapacity()\n    begin\n        // ... arrange, act, asserterror\n    end;\n}"
    }
  ],
  "suppressed": []
}
```
