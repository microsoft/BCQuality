---
kind: action-skill
id: al-test-runner
version: 1
title: AL test runner
description: Executes AL test codeunits via the AL-Go runner or a local container and returns the run result as a findings report.
inputs: [repository, object-list]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL test runner

Executes Business Central AL test codeunits and reports the run result in a shape the rest of the verifier chain can consume. It detects the project's runner (AL-Go pipeline, a Docker BC sandbox via BcContainerHelper, or a project-local build script), invokes it, parses the XUnit-style results, and maps each failure to a finding. It does not judge coverage (that is `al-test-coverage-validator` and `al-test-coverage-enforcer`), test quality (that is `al-test-validator`), or write tests (that is `al-test-writer`). This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` (the project root to run in) and optionally an `object-list` (a filter narrowing the run to specific test codeunits). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` or `pipelines` as the citable candidate set across every enabled layer: runner-selection, isolation, and AL-Go pipeline rules can back a finding about how the run was configured. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. A reported test failure or a runner-startup failure rarely maps onto a curated rule, so it is emitted as an agent finding within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the test objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the run to perform and the artifacts it produces:

- Runner detection, in order: an AL-Go pipeline (`.AL-Go/settings.json` plus a `BuildALGoProject` script); a Docker BC sandbox via BcContainerHelper (a `BcContainerHelperVersion` setting or a `Run-TestsInBcContainer` call); a project-local `scripts/Build.ps1` or equivalent.
- The test codeunits to run: every test codeunit in the repository, narrowed by the `object-list` filter when supplied.
- The results file the run emits (`TestResults.xml` or equivalent) and the runner console output.

A curated `testing` or `pipelines` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

Invoke the detected runner with the project's standard arguments, capture its output and the XUnit-style results file, and parse total, passed, failed, and skipped counts. Emit one finding per failed test: an agent finding (`references: []`, `id` slug prefixed `agent:` such as `agent:test-failed`, `confidence` capped at `medium`, `severity` capped at `minor`), with a self-contained `message` carrying the test codeunit, the test procedure, the assertion message, and the source location, and a `location` pointing at the failing line. Keep `severity` at `minor` even though a red test commonly blocks the chain, and say in the `message` that the run failed; the gating decision belongs to `al-test-coverage-enforcer` and the consuming orchestrator, not to this advisory channel. A run with many skipped tests emits an `info` finding naming the skip count. Where a curated `testing` or `pipelines` rule explains a misconfiguration the run surfaced (for example an isolation attribute that produced a spurious failure), upgrade that finding to knowledge-backed and cite the file. Mechanical fixes are rare here (the fix lives in the test or production code, not in the run), so omit `suggested-code` and set `suggested-code-omission-reason` to `fix lives in the test or production source under change`.

If the runner cannot start (Docker daemon down, BC image missing, AL-Go misconfigured) or exceeds the configured timeout, do not silently succeed: emit `outcome: "failed"` with `outcome-reason` carrying the exact command attempted and the error output, and an agent finding describing the startup failure.

Outcome selection: `completed` when the run finished and every failure was mapped to a finding (including a green run with empty `findings`); `not-applicable` when the repository has no AL test codeunit or no runner could be detected; `partial` when the run was cancelled on timeout after some tests ran (`summary.coverage` reflects the executed subset); `failed` when the runner could not start, with `outcome-reason` required.

## Output

Output conforms to the DO output contract. Test failures are agent findings (`references: []`, `agent:` id, severity capped at `minor`).

```json
{
  "skill": { "id": "al-test-runner", "version": 1 },
  "outcome": "completed",
  "outcome-reason": "al-go-pipeline runner, 27 tests, 1 failed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 1 },
    "coverage": { "worklist-size": 27, "items-evaluated": 27 }
  },
  "findings": [
    {
      "id": "agent:test-failed",
      "severity": "minor",
      "message": "Test ReleaseRegistrationShouldFailWhenOverCapacity in codeunit 50202 'Event Registration Tests' failed: expected error 'Capacity exceeded' but got 'Permission denied'. The run is red; fix the production code or the test before the chain can gate. Runner: al-go-pipeline.",
      "location": { "file": "test/EventRegistrationTests.al", "line": 88 },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix lives in the test or production source under change"
    },
    {
      "id": "agent:tests-skipped",
      "severity": "info",
      "message": "1 test was skipped via an explicit Skip() call (codeunit 50202, SmokeTest). Skipped tests do not fail the run; confirm the skip is intentional.",
      "references": [],
      "confidence": "medium"
    }
  ],
  "suppressed": []
}
```
