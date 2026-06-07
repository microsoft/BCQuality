---
kind: action-skill
id: page-scripting-e2e
version: 1
title: Page Scripting e2e planner
description: Decides what belongs in Page Scripting versus an AL test and produces a deterministic recording plan wired into the bc-replay harness.
inputs: [repository, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Page Scripting e2e planner

Builds a durable, repeatable browser-level test layer for a Business Central extension using BC's native Page Scripting (record and replay `.yml`) plus the `e2e-replay` (bc-replay) harness. It decides what belongs in Page Scripting versus an AL TestPage test, produces a deterministic recording plan a human follows, and wires the recordings so the whole set re-runs from one command. This is a generator-style skill: the recording plan markdown and the seed-factory scaffold are carried as findings' `suggested-code`, and the `## Action` step explains what is generated. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` (the extension source and any green AL suite) and a `file-path` (the `DOCS/TEST_GUIDE.md` or `USER_GUIDE.md` whose residue the plan covers). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` or `ux` as the citable candidate set across every enabled layer: rules about what a rendered client must verify (notification toasts, cue rendering, visibility refresh, factbox refresh) and about deterministic seeding can back a plan decision. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The generated plan and the layer-allocation decisions, where no curated rule applies, are agent findings within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the flows recorded, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the residue that needs a rendered client and the recordings that cover it, using the three-layer model: AL TestPage owns logic, state transitions, validation errors, action gates, proportional math, FlowField values, and permission RIMD; Page Scripting owns only what needs a rendered client; the manual checklist owns the irreducible (mobile, subjective look). Build the worklist:

- For each TEST_GUIDE category or USER_GUIDE flow, decide the layer. Anything verifiable by reading a record or asserting a field after invoking a codeunit stays layer 1 and is excluded here.
- The residue items that need a rendered client: notification toasts firing, cue and tile rendering and Style, visibility and editability refresh after a field change, FactBox refresh on row change, dropdown and lookup population and filter-as-you-type narrowing, modal and dialog flow a user clicks through, real posting through standard codeunits driven from the UI.
- One small single-purpose recording per residue item (`E2E-NN <flow>.yml`, the `NN` prefix sorting play order).
- The deterministic precondition per recording: a Test Seed Factory codeunit gated behind an `Allow Test Data Seed` toggle that clears then seeds a fixed-prefix set, a reset No. Series so a recorded New yields a stable number, an `E2E-00 Clear and Seed.yml` head, and filter-as-you-type lookups that narrow to exactly one row.
- The harness wiring: replay via `e2e-replay/run.ps1` or the VS Code task, accounting for the known constraints (bc-replay cannot run from a path with a space, credentials come from env vars not interactive login, the recordings globber rejects `..`).

A curated `testing` or `ux` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

Generate `Page Scripting/E2E-PLAN.md`: a numbered chain of small recordings, each with the file name, the exact click-path the human follows while recording (Tell Me, page, field, value, action), the deterministic precondition, and the residue item it verifies. Generate the Test Seed Factory scaffold and the `E2E-00 Clear and Seed.yml` head as supporting artifacts. Emit one finding carrying the plan. Where a curated `testing` or `ux` file backs a residue allocation (a rule that a given behaviour needs a rendered client, or a determinism rule), cite it: `id` equal to the file path, `references` carrying it, `severity` `info`, `confidence` `high` for an unambiguous match. Where no curated file applies, emit an agent finding: `references: []`, `id` slug prefixed `agent:` (for example `agent:generated-e2e-plan`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` listing the residue items, the recordings planned, and the path to write the plan to. Put the generated plan markdown in `suggested-code`. For any flow wrongly placed in layer 2 that an AL test could verify, emit a separate agent finding (`id` slug `agent:belongs-in-al-test`) recommending it stay in the TestPage suite; omit `suggested-code` and set `suggested-code-omission-reason` to `the recommendation is to keep the flow in the AL suite, not to generate a recording`. Hold every agent finding to the precision bar in `skills/do.md`.

Outcome selection: `completed` when the residue was identified and the plan generated (including when all flows are already covered by layer 1 and no recording is needed); `not-applicable` when the supplied path is not a test or user guide, or the repository has no rendered page to record; `no-knowledge` when no curated knowledge survived and no agent finding was raised; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. The generated plan with no curated backing is an agent finding (`references: []`, `agent:` id, severity capped at `minor`, markdown in `suggested-code`); findings citing a `testing` or `ux` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "page-scripting-e2e", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "agent:generated-e2e-plan",
      "severity": "minor",
      "message": "Generated Page Scripting/E2E-PLAN.md with 4 recordings for the rendered-UI residue the green AL suite cannot reach: notification toast on release, Attention cue turning red at zero, factbox refresh on row change, and the real posting flow driven from the UI. Each recording is anchored to the FE2E- seed prefix with a reset No. Series so replays are deterministic. Write the plan and the Test Seed Factory scaffold into the repo.",
      "location": { "file": "Page Scripting/E2E-PLAN.md" },
      "references": [],
      "confidence": "medium",
      "suggested-code": "# E2E Page Scripting plan\n\n## E2E-00 Clear and Seed\n... numbered recording chain, each with click-path, precondition, and verified residue ..."
    }
  ],
  "suppressed": []
}
```
