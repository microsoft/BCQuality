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

Collect all knowledge files under `*/knowledge/style/**/*.md`, across every enabled layer.

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

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic matches a changed object or declaration.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ and record suppressions.

When the post-conflict worklist is empty because no applicable style knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable style knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Style findings rarely reach `blocker` — reserve it for cases where the knowledge file documents a platform-level requirement (for example, API page property constraints the OData runtime rejects). Most style findings are `minor` or `info`; egregious misuse (`Error` with pre-built Text losing translation and telemetry classification) may reach `major`.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match.
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

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
