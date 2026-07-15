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

Do not worklist `temporary-variable-temp-prefix.md` for an event publisher parameter. `events/prefix-temporary-record-event-parameters-with-temp.md` is the exclusive owner of that shape.

Apply these high-signal mappings before fuzzy topic ranking:

- A `Label` or `TextConst` contains multiple or ambiguous placeholders but has no `Comment`, or its Comment does not explain every placeholder — `label-comment-explains-placeholders.md`. A single placeholder whose meaning is explicit in the text, such as `Customer %1`, is allowed without a Comment and must not be flagged.
- `function-call-parentheses-required.md` applies only to a zero-argument invocation written without `()`. Never worklist it from an invocation that already has parentheses or supplies arguments, including `Error(Label, Arg1, Arg2)`.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ and record suppressions.

When the post-conflict worklist is empty because no applicable style knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable style knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Style findings rarely reach `blocker` — reserve it for cases where the knowledge file documents a platform-level requirement (for example, API page property constraints the OData runtime rejects). Most style findings are `minor` or `info`; egregious misuse (`Error` with pre-built Text losing translation and telemetry classification) may reach `major`.

Severity calibration — a formal analyzer already flags the mechanical presence/naming conventions (the `this` keyword AA0248, approved label suffixes AA0074, variable-declaration order by type AA0021, a missing `ToolTip`, required parentheses). On those, BCQuality's value is the *explanation* of why the rule exists, not a second gate; emit them at `info` so a consumer that gates on severity does not re-flag what CodeCop/AppSourceCop already reports. Reserve `minor` for style issues with concrete downstream impact the analyzer does not catch — a `Label` declared at procedure-local instead of object scope (no analyzer enforces label scope, and mis-scoped Labels are fragile in the translation pipeline), lost translation or telemetry classification from a string-built `Error`, an `OptionCaption` that does not match its `OptionMembers`, a misleading named invocation. This keeps the domain's default output advisory and prevents analyzer-redundant noise from competing with substantive review.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match.
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a style defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a clear, widely-accepted AL style violation with a concrete basis a knowledgeable BC reviewer would agree on — steelman it first and drop personal preference, speculation, and any single defensible formatting choice among several; when in doubt, omit. The scope is strictly style — naming, labelling, formatting, and analyzer-adjacent conventions. A correctness, logic, data-integrity, or contract defect is NOT a style finding even when it can be reworded as a convention: a method that mutates a shared `Record`'s filters, an unfiltered `DeleteAll`, a violated interface contract, or a wrong boolean guard are behavioural defects, not conventions — do not emit them here under a style framing. If a specific domain leaf covers the concern (performance, security, error-handling, …) it belongs there; if no knowledge file in any domain covers it, it belongs to the `al-code-review` super-skill's cross-cutting self-review agent channel (`from-sub-skill: "agent"`, `severity` capped at `minor`), not to this leaf. A reliable test: if you cannot cite a style `## Best Practice`/`## Anti Pattern` for the concern, it is very likely not a style finding. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: delete unreachable lines; replace `Count() > 0` with `not IsEmpty()`; move a local `Label` to object scope; add a missing `ToolTip`, `OptionCaption`, or `DataClassification`; replace a string-concatenated `Error` with a Label-backed call; change an over-broad permission token; or add an obvious `else`/guard branch). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable style knowledge survived filtering.
- `not-applicable` — no AL changes in the diff.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. Every finding this skill emits MUST set `findings[].domain` to `"Style"`. A populated example:

```json
{
  "skill": { "id": "al-style-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 1 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/style/label-suffix-approved-list.md",
      "severity": "info",
      "message": "A Label named Text000 has no approved suffix (Msg/Err/Qst/Tok/Lbl/Txt). Per the referenced CodeCop AA0074 guidance, every Label and TextConst carries a suffix indicating its consuming call.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 42
      },
      "references": [
        { "path": "microsoft/knowledge/style/label-suffix-approved-list.md" }
      ],
      "confidence": "high",
      "domain": "Style"
    }
  ],
  "suppressed": []
}
```
