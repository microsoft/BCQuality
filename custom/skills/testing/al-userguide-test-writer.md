---
kind: action-skill
id: al-userguide-test-writer
version: 1
title: AL user-guide test writer
description: Maps each USER_GUIDE.md step to a BC page, action, and assertion and emits Subtype=Test TestPage codeunits as findings.
inputs: [file-path, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL user-guide test writer

Reads a Business Central extension's end-user walkthrough (typically `USER_GUIDE.md`), maps each documented step to a page plus action plus assertion, and generates `Subtype = Test` codeunits that script the flow with AL's TestPage library so the suite can run in a container. This is a generator-style skill: each generated test codeunit is a finding whose `suggested-code` carries the AL, and the `## Action` step explains what is generated. It writes tests; it does not run them (that is `al-test-runner`). This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `file-path` (the user-guide markdown) and a `repository` (so page object names, action names, field names, and the test app `idRanges` can be resolved from the source). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` or `ux` as the citable candidate set across every enabled layer: TestPage patterns, isolation rules, handler-function conventions, and page-interaction guidance shape the generated codeunits, so a finding matching a curated rule cites it. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where no curated rule covers a generation choice or a step that cannot be mapped, this skill emits an agent finding within its own domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the pages the guide drives, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the generation work the guide implies:

- One test codeunit per top-level guide section (`"UserGuide §N <Topic>_<SUFFIX>_TST"`, N the section number, suffix matching the extension's mandatory suffix), living in the test app's `idRanges`.
- One `[Test]` procedure per documented step or substep, so a failure points at the specific step.
- Per procedure: the page to open (`OpenNew()` / `OpenEdit()`), the field writes (display captions resolved to AL field names from the source), the action invocations (`Invoke()` on the AL action name, not the caption), and the assertions on documented outcomes (`Assert.AreEqual` / `Assert.IsTrue` via `Codeunit "Library Assert"`).
- `[HandlerFunctions(...)]` where the guide implies a dialog or confirmation, with `asserterror` on negative paths.
- Seed data via `LibrarySales` / `LibraryPurchase` / `LibraryInventory` / `LibraryWarehouse` or the extension's own seed library; an `IsInitialized` guard and an `Initialize()` procedure per codeunit.
- A coverage map: which steps mapped to which procedures, and which sections could not be mapped (page does not exist, action unreachable from a TestPage, behaviour is server-side with no UI hook).

A curated `testing` or `ux` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each mappable section, generate a TestPage codeunit as described in the worklist and emit one finding carrying it. Where a curated `testing` or `ux` file backs a generation choice (an isolation rule, a handler-function convention, a TestPage interaction pattern), cite it: `id` equal to the file path, `references` carrying it, `severity` `info`, `confidence` `high` for an unambiguous match. Where no curated file applies, emit an agent finding: `references: []`, `id` slug prefixed `agent:` (for example `agent:generated-userguide-test`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the section, the steps covered, and the file path the codeunit should be written to. Put the generated AL in `suggested-code`. For a section that cannot be cleanly mapped, emit a separate agent finding (`id` slug `agent:unmappable-userguide-step`) naming the section, the step, why it could not map, and the recommended workaround (for example a parent-subpage navigation pattern, or a note that a server-side behaviour needs a non-UI test); omit `suggested-code` and set `suggested-code-omission-reason` to `step cannot be expressed through a TestPage primitive`. When the extension has no seed library, emit an `info` finding recommending one. Hold every agent finding to the precision bar in `skills/do.md`.

Outcome selection: `completed` when every section was processed (mapped to a codeunit or reported as unmappable); `not-applicable` when the supplied path is not a user guide or no driven page exists in the repository; `no-knowledge` when no curated knowledge survived and no agent finding was raised; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Generated codeunits with no curated backing are agent findings (`references: []`, `agent:` id, severity capped at `minor`, AL in `suggested-code`); findings citing a `testing` or `ux` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "al-userguide-test-writer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "agent:generated-userguide-test",
      "severity": "minor",
      "message": "Generated TestPage codeunit for guide section '2. First-time setup', covering steps 2.1 Open Shipping Setup, 2.2 Review seeded reference data, 2.3 Set up Other Places. Write to src/UserGuide/SetupSection_TST.Codeunit.al in the test app id range.",
      "location": { "file": "src/UserGuide/SetupSection_TST.Codeunit.al" },
      "references": [],
      "confidence": "medium",
      "suggested-code": "codeunit 60001 \"UserGuide §2 Setup_SHP_EQL_TST\"\n{\n    Subtype = Test;\n    TestPermissions = Disabled;\n    // [Test] procedures per documented step\n}"
    },
    {
      "id": "agent:unmappable-userguide-step",
      "severity": "minor",
      "message": "Section 5.1 'Click Add to Container on the line ribbon' is a subpage line-level action. A TestPage cannot invoke it directly; use the parent page's TestPage and a SubPage child reference (Page_PurchaseOrder.PurchLines.\"Add to Container_SHP_EQL\".Invoke()). Confirm the parent-subpage navigation matches AL conventions.",
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "step cannot be expressed through a TestPage primitive"
    }
  ],
  "suppressed": []
}
```
