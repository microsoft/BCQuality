---
kind: action-skill
id: al-style-review
version: 1
title: AL style review
description: Reviews AL source changes against naming, labelling, and code-convention guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL style review

Reviews AL source changes against the `style` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

Style findings cover AL conventions that CodeCop and similar analyzers partially enforce — label suffixes, API page naming, temporary-variable prefixes, label properties, named invocations, `FieldCaption`/`TableCaption` in user messages, `OptionCaption` pairing, Error-parameter passing, `this` keyword, required parentheses, file-naming. Use together with a formal analyzer; this skill adds BCQuality's remedial-knowledge explanations of why each rule exists.

An orchestrator invokes this skill with either a `pr-diff` or a `file-path`. The skill produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `style` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/style/**`.

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. If absent, `unknown`.
- `application-area` — pass the actual set declared by the changed objects; do not substitute `[all]`.

Discard files that are not applicable. Retain conditionally applicable files only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium` and MUST name the unknown dimensions in `message`.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- Changed AL objects — especially API pages (`PageType = API`), tables and pages declaring Labels/TextConsts, codeunits issuing `Error`/`Message`/`Confirm`, and any file whose name violates the `<ObjectName>.<ObjectType>.al` convention.
- Changed declarations, weighted toward `: Label '...'`, `: TextConst '...'`, temporary record variables, option fields, error-handling call sites, and codeunit-internal method calls.
- Tokens extracted from the diff (`Label`, `TextConst`, `Locked`, `Comment`, `MaxLength`, `temporary`, `OptionMembers`, `OptionCaption`, `APIPublisher`, `APIGroup`, `APIVersion`, `EntityName`, `EntitySetName`, `DelayedInsert`, `FieldCaption`, `TableCaption`, `FieldName`, `TableName`, `Page.RunModal`, `Report.Run`, `this.`, `StrSubstNo`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object or declaration. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ and record suppressions.

When the post-conflict worklist is empty because no applicable style knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable style knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Style findings rarely reach `blocker` — reserve it for cases where the knowledge file documents a platform-level requirement (for example, API page property constraints the OData runtime rejects). Most style findings are `minor` or `info`; egregious misuse (`Error` with pre-built Text losing translation and telemetry classification) may reach `major`.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match.
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a style defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a clear, widely-accepted AL style violation with a concrete basis a knowledgeable BC reviewer would agree on — steelman it first and drop personal preference, speculation, and any single defensible formatting choice among several; when in doubt, omit. The scope is strictly style; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: delete unreachable lines; replace `Count() > 0` with `not IsEmpty()`; move a local `Label` to object scope; add a missing `ToolTip`, `OptionCaption`, or `DataClassification`; replace a string-concatenated `Error` with a Label-backed call; change an over-broad permission token; or add an obvious `else`/guard branch). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable style knowledge survived filtering.
- `not-applicable` — no AL changes in the diff.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-style-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/style/apply-approved-label-suffixes.md",
      "severity": "minor",
      "message": "A Label named Text000 has no approved suffix (Msg/Err/Qst/Tok/Lbl/Txt). Per the referenced CodeCop AA0074 guidance, every Label and TextConst carries a suffix indicating its consuming call.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 42
      },
      "references": [
        { "path": "microsoft/knowledge/style/apply-approved-label-suffixes.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```

