---
kind: action-skill
id: al-test-coverage-enforcer
version: 1
title: AL test coverage enforcer
description: Hard coverage gate, passing only when AL coverage meets the threshold and otherwise naming every uncovered path.
inputs: [pr-diff, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL test coverage enforcer

Decides whether a Business Central change has enough AL test coverage to ship. Unlike `al-test-coverage-validator`, which reports, this skill gates: it passes (an empty `findings` array) only when every new or behaviour-changed production surface has at least one identifiable covering test, and otherwise emits a finding per uncovered path at gating severity. When in doubt it fails, because the cost of one extra test is low and the cost of an uncovered regression is high. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the production change to gate) and a `repository` (so the test index and any coverage report can be read). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` as the citable candidate set across every enabled layer: a curated rule about a coverage threshold or a mandatory regression test is the authoritative basis that lets this skill gate at `major` or `blocker`. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where the project threshold is a house default with no curated backing, see Action for how severity is handled.

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the production surfaces the threshold applies to:

- New public procedures (default threshold: every one must have at least one direct or indirect covering test, no exceptions).
- New event subscribers (must have a test that fires the publisher in a realistic context).
- New table triggers (`OnInsert`, `OnModify`, `OnDelete`, field `OnValidate`): each must have a covering test.
- Modified procedures with a behaviour change: an existing or new test must assert the new behaviour. A behaviour change whose existing tests still pass unchanged is itself a gap (the tests do not exercise the new behaviour).
- Bug fixes: must add a regression test that names the bug and fails without the fix.
- Pure refactors with no behaviour change: existing covering tests must still apply; no new test required.

Compute the covering set from the test index (procedure to referencing tests) and any supplied coverage report. A curated `testing` file enters the worklist when its `keywords` intersect a coverage-threshold rule. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted surface, decide PASS or FAIL against the threshold. Emit a finding for every FAIL reason, each naming the specific procedure, subscriber, trigger, or bug fix. Where a curated `testing` knowledge file states the coverage requirement, emit a knowledge-backed finding citing it: `id` equal to the file path, `severity` `blocker` when the file states a platform-level guarantee, otherwise `major`; `confidence` `high` for an unambiguous gap. Where the requirement is the house default with no curated backing, the finding is an agent finding within this skill's domain (`references: []`, `id` slug prefixed `agent:` such as `agent:uncovered-new-public-procedure` or `agent:bug-fix-missing-regression-test`, `confidence` capped at `medium`). Per `skills/do.md`, an agent finding's `severity` is capped at `minor` even though this skill gates: keep the emitted severity at `minor`, state plainly in the `message` that the impact is gating (it blocks completion under the project threshold), and flag that the threshold should be promoted to a curated `testing` rule so the gate carries authoritative weight. The consuming orchestrator combines the threshold configuration with these findings to set the actual PASS/FAIL on the merge. The fix is a new test, so omit `suggested-code` and set `suggested-code-omission-reason` to `the gap is closed by adding a covering test`.

When no coverage report is supplied, fall back to static analysis of the test codeunits (which procedures each test references directly) and state the limitation in an `info` finding. When in doubt about whether a surface is covered, prefer to emit the finding.

Outcome selection: `completed` when every worklisted surface was decided (an empty `findings` array means PASS, the gate is satisfied); `not-applicable` when the diff has no new or behaviour-changed production surface (a pure refactor or doc-only change); `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. An empty `findings` array with `outcome: completed` is the PASS signal. Threshold findings with no curated backing are agent findings (`references: []`, `agent:` id, severity capped at `minor`, gating impact stated in the message); findings citing a `testing` file carry that file path as `id` and may gate at `major` or `blocker`.

```json
{
  "skill": { "id": "al-test-coverage-enforcer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 2, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "agent:uncovered-new-public-procedure",
      "severity": "minor",
      "message": "codeunit 50101 'Event Registration Mgt'.ReleaseRegistration is new in this diff and no test references it directly or indirectly. Impact is gating: under the project threshold this blocks completion. Promote the threshold to a curated testing rule so the gate carries authoritative weight.",
      "location": { "file": "src/Sales/EventRegistrationMgt.Codeunit.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "the gap is closed by adding a covering test"
    },
    {
      "id": "agent:bug-fix-missing-regression-test",
      "severity": "minor",
      "message": "The commit references work item #1234 (a fix) but no new test names the item or asserts the prior failure mode. Impact is gating: a bug fix must ship with a regression test that fails without the fix.",
      "location": { "file": "src/Sales/EventRegistrationMgt.Codeunit.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "the gap is closed by adding a covering test"
    }
  ],
  "suppressed": []
}
```
