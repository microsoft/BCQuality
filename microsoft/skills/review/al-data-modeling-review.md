---
kind: action-skill
id: al-data-modeling-review
version: 1
title: AL data-modeling review
description: Performs an AL data-modeling review against guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL data-modeling review

Reviews AL source changes against the `data-modeling` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). Data-modeling findings are narrow by design — they apply when the diff touches setup or master tables, their card pages, primary keys, number-series assignment, block enforcement, or audit fields. The skill returns `not-applicable` when none of those apply.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `data-modeling` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/data-modeling/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially `* Setup` singleton tables and Card pages, custom master tables, tableextensions that add master-data fields, and document or journal lines that reference a master.
- The changed fields, keys, triggers, and procedures, weighted toward `Primary Key`, `No.`, `No. Series`, `Blocked`, `Last Date Modified`, `OnInsert`, `OnModify`, `OnRename`, reference-field `OnValidate`, and posting validation.
- Tokens extracted from the diff that relate to data modeling (`setup`, `master`, `Primary Key`, `Code[10]`, `Code[20]`, `AutoIncrement`, `SystemId`, `No.`, `No. Series`, `NoSeriesManagement`, `Codeunit "No. Series"`, `GetNextNo`, `IsManual`, `TestManual`, `Blocked`, `TestField`, `Last Date Modified`, `Today`, `WorkDate`, `InsertAllowed`, `DeleteAllowed`, `PageType = Card`, `OnOpenPage`, `GetRecordOnce`, `OnInsert`, `OnModify`, `OnRename`, `TableRelation`, `tableextension`, `enumextension`, `Media`, `MediaSet`, `Item`, `Count`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone. When the diff contains no data-modeling changes by any of the above signals, return `outcome: "not-applicable"` without evaluating files.

The following targeted checks cover every current `data-modeling` article. Treat each as a candidate-selection cue: when the signal appears in changed code, add the named article to the worklist and evaluate it in Action.

- A `* Setup` table or its page changes singleton structure, uses a nonblank or generated key, permits insert/delete, uses a List page, or does not ensure the blank-keyed row exists — `setup-table-is-a-singleton`.
- A custom master table changes its primary key, `No.`/`No. Series` fields, or `OnInsert` without assigning a blank `No.` from setup through a number series — `master-table-no-from-number-series-in-oninsert`.
- BC v22 or later code introduces or retains `NoSeriesManagement`, `InitSeries`, `SelectSeries`, or `SetSeries`, or number assignment/manual-entry checks do not use codeunit `"No. Series"` methods such as `GetNextNo`, `IsManual`, or `TestManual` — `use-no-series-codeunit-not-noseriesmanagement`.
- A master gains or changes `Blocked`, or a document line, journal line, reference-field `OnValidate`, or posting routine uses that master without `TestField(Blocked, false)` at the point of use; also cue when the check is placed only in the master's own triggers — `check-blocked-in-referencing-code-not-in-master`.
- A master table adds or changes `Last Date Modified`, `OnModify`, or `OnRename`, but the non-editable field is not assigned `Today()` in both triggers — `set-last-date-modified-in-onmodify-and-onrename`.
- A `tableextension` appends a conditional `TableRelation` as if it overrides an earlier unconditional relation, or relation branches are otherwise designed without accounting for additive top-down evaluation — `table-relation-extensions-are-additive-and-top-down`.
- A `Media` or `MediaSet` field is assigned directly between different table types or different field IDs instead of registering each shared item with `MediaSet.Insert` — `share-mediaset-items-with-insert-not-field-assignment`.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable data-modeling knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable data-modeling knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the model can create ambiguous setup state, incompatible business identifiers, or silently stale synchronization data; otherwise the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- Applicability alone is not a finding. Emit `info` only for a concrete, non-actionable observation the article explicitly defines; otherwise emit nothing when no violation is present.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (object type, field, key, trigger, or API name).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a data-modeling defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material data-modeling defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly data modeling; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: add `InsertAllowed = false` or `DeleteAllowed = false`; replace `WorkDate()` with `Today()`; add the same audit-field assignment to `OnRename`; or replace an obsolete number-series codeunit declaration). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable data-modeling knowledge survived filtering.
- `not-applicable` — the diff touches no setup/master table, page, key, numbering, block-check, or audit-field surface.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. Every finding this skill emits MUST set `findings[].domain` to `"Data Modeling"`. A populated example:

```json
{
  "skill": { "id": "al-data-modeling-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/data-modeling/set-last-date-modified-in-onmodify-and-onrename.md",
      "severity": "major",
      "message": "The table updates Last Date Modified in OnModify but not OnRename, so renaming the primary key leaves the audit date stale and can hide the record from incremental integrations.",
      "location": {
        "file": "src/LoyaltyMember.Table.al",
        "line": 74
      },
      "references": [
        { "path": "microsoft/knowledge/data-modeling/set-last-date-modified-in-onmodify-and-onrename.md" }
      ],
      "confidence": "high",
      "domain": "Data Modeling",
      "suggested-code": "trigger OnRename()\nbegin\n    \"Last Date Modified\" := Today();\nend;"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case produces:

```json
{
  "skill": { "id": "al-data-modeling-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
