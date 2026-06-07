---
kind: action-skill
id: bc-webclient-runner
version: 1
title: BC web client runner
description: Drives the rendered BC web client through a documented flow to catch UI residue AL TestPage cannot observe.
inputs: [repository, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# BC web client runner

Drives a real Business Central web client through a documented user flow (typically `USER_GUIDE.md`), capturing screenshots and asserting on rendered UI state at every step. It catches the class of bug AL TestPage is structurally blind to: page layout, action enable and disable state, FactBox refresh timing, notification toasts, modal stacking, lookup usability, delayed-insert behaviour on subpages, and state-label drift between the guide and the enum. It executes scripted flows; it does not author AL. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` (the extension source, so page and action names and the documented sandbox URL and company can be resolved) and a `file-path` (the user-guide markdown to walk). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `ux` or `testing` as the citable candidate set across every enabled layer: rendered-UI rules (delayed-insert, lookup usability, refresh-after-validate, state-label consistency) can back a finding the run surfaces. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where no curated rule covers an observed rendered-UI defect, this skill emits an agent finding within its own domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the pages walked, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the flow to drive and the rendered checks per step. The environment must be non-production: refuse an on-prem host lacking `sandbox`, `dev`, `test`, or `staging`, and for a SaaS host on `businesscentral.dynamics.com` inspect the environment-name path segment and refuse if it matches `Production` or starts with `Prod`. Then build the worklist:

- Each top-level guide section (or the supplied subset), and within it each documented step.
- Step-level state checks: read the documented outcome (status pill text, field value, subpage row count) after each action.
- Action availability: confirm a button is enabled or disabled exactly as the guide states, reading `aria-disabled` from the accessibility tree.
- Notification toasts: screenshot the toast region before auto-dismiss and read its content.
- FactBox totals: read the numbers and compare to the documented arithmetic.
- Lookup usability on every lookup-bearing field: open the lookup, confirm it lists records and a selection writes back.
- Delayed-insert behaviour on every editable subpage: type into the first non-PK field, tab off, and watch for an out-of-filter banner, a blank PK column, or the row falling out of the parent filter.
- Missing affordances the guide implies (a lookup drop-down a documented path needs).
- State-label drift: compare the displayed status value and enum dropdown values against the names the guide uses.
- Page-level errors: any `Error` notification, inline validation message, or console `ServerError`, captured even if the guide does not mention it.

A curated `ux` or `testing` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

Drive the web client through each worklisted step, screenshot the result, and assert on the documented outcome. The skill requires a Chrome automation surface in the calling session; if it is unavailable, do not fall back to anything else: emit `outcome: "failed"` with `outcome-reason` stating the surface is missing.

Emit a finding for every rendered-UI defect. Where a curated `ux` or `testing` file states the rule (for example a delayed-insert rule, a refresh-after-validate rule, or a state-label-consistency rule), emit a knowledge-backed finding citing it: `id` equal to the file path, `severity` up to `major`, `blocker` only when the file states a platform-level guarantee, `confidence` `high` for an unambiguous match. Where no curated file covers the observed defect, emit an agent finding within this skill's domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:userguide-action-disabled`, `agent:subpage-missing-delayed-insert`, `agent:factbox-stale`, `agent:state-label-drift`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` carrying the section, the step, what was observed against what the guide promised, and the screenshot path. When the underlying impact would otherwise be major (a subpage missing `DelayedInsert = true` corrupting the parent FK, or state-label drift that breaks every downstream filter), keep the emitted `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a curated rule before it can gate. Record the role the run used and the URL in the summary. Hold every agent finding to the precision bar in `skills/do.md`. The fix lives in AL, not in a renderable replacement, so omit `suggested-code` and set `suggested-code-omission-reason` to `fix is an AL change the developer applies after reading the report`.

Outcome selection: `completed` when every attempted step was driven and asserted (including a clean run with empty `findings`); `not-applicable` when the supplied path is not a user guide or the repository drives no rendered page; `partial` when a block stopped the run mid-flow and not every section was attempted (`summary.coverage` reflects the attempted subset); `failed` when the Chrome surface was unavailable or the run could not start, with `outcome-reason` required.

## Output

Output conforms to the DO output contract. Rendered-UI defects with no curated backing are agent findings (`references: []`, `agent:` id, severity capped at `minor`); findings citing a `ux` or `testing` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "bc-webclient-runner", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 2, "info": 0 },
    "coverage": { "worklist-size": 9, "items-evaluated": 9 }
  },
  "findings": [
    {
      "id": "agent:userguide-action-disabled",
      "severity": "minor",
      "message": "Section 3.2: Release on the Freight Movement card is disabled although the guide says it should be enabled once the header is filled (aria-disabled=true on the command-bar item). Screenshot: screenshots/section-3-step-2-release-disabled.png. Verify the action's Enabled expression against the header-filled state.",
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix is an AL change the developer applies after reading the report"
    },
    {
      "id": "agent:subpage-missing-delayed-insert",
      "severity": "minor",
      "message": "Section 5.1: typing into the line subpage then tabbing off shows an out-of-filter banner and a blank No. column, indicating the subpage is missing DelayedInsert = true. Impact is major: OnInsert fires before the number series assigns the PK, so the row persists with a blank or wrong parent FK. Promote to a curated rule before it can gate.",
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix is an AL change the developer applies after reading the report"
    }
  ],
  "suppressed": []
}
```
