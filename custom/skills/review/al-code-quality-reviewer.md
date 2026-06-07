---
kind: action-skill
id: al-code-quality-reviewer
version: 1
title: AL code quality review
description: Reviews AL source changes for design quality, testability, and structural anti-patterns, and emits a findings report.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL code quality review

Reviews Business Central production AL for design and structural problems that hurt the codebase later: direct database access from logic codeunits (the IDataAccess rule), business logic on table or page triggers, untestable seams, swallowed errors, excessive coupling and nesting, and thick event subscribers. This skill is about whether the code is well-designed and testable, not about clarity to a fresh reader (that is `al-readability-checker`) or test quality (that is the test validators). Most of what it surfaces is design judgement the curated corpus does not encode, so the bulk of its output is agent findings within a design quality remit, with curated `performance` and `security` rules cited where a structural defect maps onto one. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `performance` or `security` as the citable candidate set across every enabled layer: a structural defect such as a commit inside a loop, a redundant Get, or an integration event that leaks a secret maps onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The design quality concerns this skill owns (IDataAccess routing, testability seams, coupling, error-handling robustness, subscriber discipline) are mostly not covered by the corpus; for a concrete, demonstrable defect there, emit an agent finding within this skill's design quality domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the changed production AL (exclude test objects) and the structural shapes this skill audits:

- Logic codeunits that call `Get`, `Find*`, `SetRange`, `Insert`, `Modify`, `Delete` directly on a record rather than routing through the project's `IDataAccess` interface or its implementation.
- Table and page objects whose triggers carry non-trivial validation, calculation, or posting logic instead of delegating to a management codeunit.
- Public procedures whose `Record` parameter cannot be exercised with a temporary record, and procedures that read ambient state (`UserId`, `WorkDate`, `CompanyName`, `Session`) with no override seam.
- Procedures with high cyclomatic complexity, length over roughly 80 lines, fan-out over ten codeunits, or nesting at five levels or deeper.
- Swallowed errors (`if not Codeunit.Run() then exit` with no handling), empty `Error('')`, and `Commit` inside a loop or without a documented reason.
- Event subscriber codeunits that mix unrelated subscriptions, hold inline business logic, omit early exit on temporary or wrong record type, or leave `EventSubscriberInstance` unset on a non-trivial subscriber.

A curated `performance` or `security` file enters the worklist when its `keywords` intersect these tokens (for example `commit`, `loop`, `get`, `integrationevent`, `secret`). Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted shape, evaluate the diff and emit findings.

When a defect maps onto a curated `performance` or `security` knowledge file (for example a `Commit` inside an iteration, a redundant `Get` on an already-loaded record, or an integration event exposing a secret), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous pattern match.

When a concrete, demonstrable design quality defect has no curated rule (a logic codeunit reaching the database directly instead of through IDataAccess, a public procedure with no test seam, a swallowed error, a thick subscriber doing inline business logic), emit an agent finding within this skill's design quality domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:direct-db-access-from-logic`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing both the defect and a concrete fix. Where the underlying impact would normally gate (a direct-DB-access violation the team treats as a block), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every agent candidate to the precision bar in `skills/do.md`: steelman that the shape is a deliberate, valid choice before emitting, never emit stylistic or speculative concerns, and omit when in doubt. Defects outside design quality (pure readability, pure performance the corpus already covers) belong to other skills and MUST NOT be emitted here. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (deleting a swallowed-error guard, moving a `Commit` out of a loop, replacing `Error('')` with a Label-backed call); otherwise set `suggested-code-omission-reason` (for example `requires introducing an IDataAccess implementation`). Group repeated instances of one concern into a single finding with a line range rather than many near-identical ones.

Outcome selection: `completed` when every worklist item was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the diff has no production AL to review; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-code-quality-reviewer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/performance/avoid-commit-inside-loops.md",
      "severity": "major",
      "message": "Commit() is called inside a repeat..until loop in EventPostingMgt. Move the commit outside the loop or split the work so the transaction boundary is not broken per row.",
      "location": {
        "file": "src/EventPostingMgt.Codeunit.al",
        "line": 88
      },
      "references": [
        { "path": "microsoft/knowledge/performance/avoid-commit-inside-loops.md" }
      ],
      "confidence": "high"
    },
    {
      "id": "agent:direct-db-access-from-logic",
      "severity": "minor",
      "message": "EventRegistrationMgt.ReleaseRegistration calls Record.Get on Event Registration directly from a logic codeunit, bypassing the project's IDataAccess seam. This couples business logic to the data layer and blocks unit testing with a temporary record. Route the read through the IDataAccess implementation. Impact would normally be major in this codebase; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/EventRegistrationMgt.Codeunit.al",
        "line": 42
      },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "requires routing through the project's IDataAccess implementation"
    }
  ],
  "suppressed": []
}
```
