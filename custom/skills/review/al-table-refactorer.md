---
kind: action-skill
id: al-table-refactorer
version: 1
title: AL table refactor review
description: Reviews an AL table for clarity, performance, and house rules, extracting trigger logic and reorganising keys, and emits a findings report with refactored AL.
inputs: [file-path, object-list]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL table refactor review

Reviews a Business Central AL table for clarity, performance, and project house rules, and proposes concrete refactorings: extracting non-trivial validation, calculation, and posting logic out of table triggers into a management codeunit, adding an `IDataAccess` seam where one is missing, reorganising fields and keys for a known access pattern, and tidying FlowFields and CalcFormulas. Refactoring must never change observable behaviour. Because the proposed changes are mechanical AL edits, this skill emits findings that carry the refactored AL in `suggested-code`. It sources from the `performance` and `style` knowledge domains and cites curated rules where a refactoring maps onto one; structural moves the corpus does not encode are agent findings within its design and structure domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `file-path` (the table object) or an `object-list`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `performance` or `style` as the citable candidate set across every enabled layer: a key that should align with the filters a caller uses, a FlowField source key that needs `SumIndexFields`, a `CalcFields` that belongs outside a hot loop, declaration order, captions, and object-scope labels each map onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The structural moves this skill owns (extracting trigger logic into a codeunit, adding an IDataAccess seam) are mostly not encoded; for those concrete defects, emit an agent finding within this skill's design and structure domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the table, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the refactoring opportunities in the table object:

- Table triggers (`OnInsert`, `OnModify`, `OnValidate` of a field) holding non-trivial validation, calculation, or posting logic that belongs in a management codeunit, leaving the triggers as thin dispatchers.
- A missing `IDataAccess` implementation where the project's no-naive-data-access rule expects one.
- Field organisation: primary key first, then foreign keys, then descriptive fields, then computed and FlowFields, then audit fields; a missing secondary key for an obvious non-primary access pattern; a `FindFirst`-on-full-key pattern that should be a `Get`; an auto-increment field used as a primary key.
- FlowFields and CalcFormulas: aggregations callers re-derive that a `CalcFormula` could hold; `CalcFields` inside a hot loop; non-obvious formulas with no XML doc comment.
- House rules: object id inside the assigned range, user-facing labels via object-scope `Label` with a `Comment`, telemetry on protected operations, captions populated, one object per file.

A curated `performance` or `style` file enters the worklist when its `keywords` intersect these tokens (for example `key`, `setcurrentkey`, `flowfield`, `calcfields`, `caption`, `label`). Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each refactoring opportunity, emit a finding that carries the refactored AL.

When the refactoring maps onto a curated `performance` or `style` rule (aligning a key with a filter pattern, adding `SumIndexFields` to a FlowField source key, moving a label to object scope, populating a caption), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When the refactoring is a structural move with no curated rule (extracting validation from a trigger into a management codeunit, adding an IDataAccess seam, reordering fields, adding a secondary key), emit an agent finding within this skill's design and structure domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:extract-trigger-logic`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the move and confirming it preserves observable behaviour. Where the impact would normally gate, keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the current shape is deliberate before emitting, and omit when in doubt.

Because this skill's job is to produce the refactored table, set `suggested-code` on every finding where the change is mechanical and contiguous: it carries the literal refactored AL for the lines indicated by `location` (the reorganised `keys` block, the rewritten thin trigger, the relocated `Label`). When a `.good.al` companion exists and the table matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`. Omit `suggested-code` only when the move spans non-contiguous code or a behaviour-preserving rewrite cannot be determined from the table alone (for example extracting logic that needs a new sibling codeunit file), and then set `suggested-code-omission-reason`. If a change might alter observable behaviour, lower confidence and say so in the `message` rather than emitting a confident replacement.

Outcome selection: `completed` when every opportunity was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the input is not a table object; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-table-refactorer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "agent:extract-trigger-logic",
      "severity": "minor",
      "message": "The OnValidate trigger of field Attendee Count holds the full attendee-cap validation inline. Extract it to Event Registration Mgt.ValidateAttendeeCount and call that from the trigger, leaving the trigger as a thin dispatcher. The extracted call preserves observable behaviour. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/EventRegistration.Table.al",
        "line": 40,
        "range": { "start-line": 40, "end-line": 41 }
      },
      "references": [],
      "confidence": "medium",
      "suggested-code": "                trigger OnValidate()\n                begin\n                    EventRegistrationMgt.ValidateAttendeeCount(Rec);\n                end;"
    }
  ],
  "suppressed": []
}
```
