---
kind: action-skill
id: al-performance-reviewer
version: 1
title: AL performance anti-pattern review
description: Reviews AL for N+1 queries, missing keys, FlowField overuse on lists, missing SetLoadFields, and FindFirst on growing tables, and emits a findings report.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL performance anti-pattern review

Reads AL with a single question: at ten times tenant scale, where does this fall over? It targets the patterns the AL compiler will not warn about but that compound badly under data scale: N+1 per-row sibling lookups and per-row `CalcFields`, a `SetCurrentKey` with no matching key, `FindFirst` on tables that grow without bound (ledger entries, document headers), FlowField columns on list-page repeaters, missing `SetLoadFields`, destructive `DeleteAll`/`ModifyAll` with no filter, heavy `OnAfterGetRecord`, HTTP calls inside a loop, and `Commit` inside iterations. This skill sources from the `performance` knowledge domain and cites those files where they match. It overlaps the platform `al-performance-review`, so its primary added value is agent findings for the scale patterns the corpus does not yet cover. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `performance` as the citable candidate set across every enabled layer: a `Get` inside a loop on a large table, `CalcSums` instead of `CalcFields` in a loop, applying filters before iterating, `SetLoadFields` for partial records, `IsEmpty` for existence checks, `Get` instead of `FindFirst` on a full primary key, and commit boundaries each map onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where a concrete scale defect has no curated rule (a FlowField column added to a heavily rendered list repeater, a `FindFirst` on a known unbounded ledger table with no tight filter, a missing `HasFilter` guard before a destructive iteration), emit an agent finding within this skill's performance domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow the relevant files to the subset that applies to the changes, computing overlap against:

- Record-iteration code: `FindSet`/`FindFirst`/`FindLast` and `repeat..until` loops, weighted toward a per-row `Get`/`Find` on a sibling table (N+1) and a per-row `CalcFields`.
- List pages and their `SourceTable`, weighted toward FlowField columns on the repeater and heavy `OnAfterGetRecord` bodies.
- Keys defined on the table compared against the `SetCurrentKey` plus `SetRange`/`SetFilter` combinations the code actually uses; a `SetCurrentKey` with no matching key.
- `FindFirst` against tables that grow without bound (Item Ledger Entry, Value Entry, G/L Entry, Vendor Ledger Entry, Sales Header, Purchase Header) with no tight `SetRange`.
- Reads that use only a few fields and could `SetLoadFields`; `DeleteAll`/`ModifyAll` with no prior filter or `HasFilter` guard; `HttpClient.Send` or `Commit` inside an iteration.

A curated `performance` file enters the worklist when its `keywords` intersect these tokens or its topic matches a changed object kind. Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. When the diff clearly matches an anti-pattern (a `Get` inside a loop on a large table, a `CalcFields` per row, a `FindFirst` on a full primary key), emit a knowledge-backed finding citing the file: `id` equal to the file path, the file as primary reference, `severity` `blocker` only when the file states a platform-level guarantee otherwise `major`, `location` on the offending line or range, `confidence` `high` for an unambiguous match. When the diff contradicts a best practice without being a full anti-pattern, emit `minor` with the same reference shape.

When a concrete scale defect has no curated rule, emit an agent finding within this skill's performance domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:flowfield-on-list-repeater` or `agent:findfirst-on-unbounded-table`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` that states the cost at scale (one extra query per visible row per render, a full scan on a table that only grows) and a concrete fix (move the FlowField to a factbox, add a `SetRange` that resolves via a key). Where the impact would normally gate (a destructive `DeleteAll` with no filter), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the table is small, the filter is set elsewhere, or the cost is documented and accepted before emitting, and omit when in doubt. The scope is strictly performance; defects outside this domain belong to other skills. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (replacing `Count() > 0` with `not IsEmpty()`, adding a `SetLoadFields` before a `FindSet`, adding a `HasFilter` guard before a `DeleteAll`); otherwise set `suggested-code-omission-reason` (for example `requires choosing the right secondary key to add`).

Outcome selection: `completed` when every worklist item was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the diff has no AL to review; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-performance-reviewer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/performance/avoid-get-inside-loop-on-large-table.md",
      "severity": "major",
      "message": "Inside a FindSet over Vendor, Data Sync Mgt.SyncVendors calls Cache.Get for each row, firing one query per vendor. Pre-load the cache table into a Dictionary outside the loop and look up per row instead.",
      "location": {
        "file": "src/DataSyncMgt.Codeunit.al",
        "line": 142,
        "range": { "start-line": 142, "end-line": 146 }
      },
      "references": [
        { "path": "microsoft/knowledge/performance/avoid-get-inside-loop-on-large-table.md" }
      ],
      "confidence": "high"
    },
    {
      "id": "agent:flowfield-on-list-repeater",
      "severity": "minor",
      "message": "A FlowField column Total Amount was added to the Vendors list repeater, so every visible row triggers a CalcFields on each render. On a 50-row list that is 50 extra aggregate queries per render. Move the field to a factbox, which renders once per selected row, or document and accept the cost. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/Vendors.Page.al",
        "line": 28
      },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix is a layout decision between factbox placement and accepted cost"
    }
  ],
  "suppressed": []
}
```
