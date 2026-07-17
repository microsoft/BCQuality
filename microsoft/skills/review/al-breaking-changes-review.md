---
kind: action-skill
id: al-breaking-changes-review
version: 1
title: AL breaking changes review
description: Reviews AL source changes against breaking-changes guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL breaking changes review

Reviews AL source changes against the `breaking-changes` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). The skill produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `breaking-changes` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/breaking-changes/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially codeunits, tables, and table extensions that expose procedures, fields, or events to other apps, and any member whose access is being widened.
- The changed procedures, fields, and triggers, weighted toward non-`local` procedures, published table fields, event publishers, and any member whose signature, access modifier, or obsolete state is being altered.
- Tokens extracted from the diff that relate to API stability and deprecation (`signature`, `parameter`, `return`, `var`, `Obsolete`, `ObsoleteState`, `ObsoleteReason`, `ObsoleteTag`, `Pending`, `Removed`, `CLEAN`, `SecretText`, `token`, `internal`, `local`, `public`, `protected`, `Scope`, `namespace`, `using`, `AS0007`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone.

The following targeted checks cover every current `breaking-changes` article:

- A helper or object changes between `local`, `internal`, `protected`, or public access, or a new implementation detail is exposed without a supported-API reason — `choose-access-modifiers-deliberately`.
- A public member is removed or replaced without first going through the `[Obsolete]` lifecycle — `deprecate-public-members-with-the-obsolete-lifecycle`.
- A published procedure changes parameter count/order/type/name, `var`, return type, or array shape instead of preserving the old signature and adding an overload — `do-not-change-published-procedure-signatures`.
- A public procedure/event/interface exposes a credential or other sensitive value through `Text` or an externally callable contract — `do-not-expose-sensitive-data-through-public-api`.
- Code already marked obsolete is expanded with new behavior instead of routing new callers to its replacement — `do-not-modify-code-already-marked-obsolete`.
- A shipped table field is deleted, renamed, renumbered, or replaced without retaining the original field as `ObsoleteState = Pending` and migrating its data — `obsolete-table-fields-instead-of-deleting-them`. This owns AS0005 field-name changes; do not substitute the namespace article.
- A published object's namespace changes between the base and changed source while its identity otherwise remains — `namespace-is-part-of-published-object-identity`. Do not apply it to a new, unshipped object or to an ordinary object-name change with no namespace change.

For `obsolete-table-fields-instead-of-deleting-them`, compare the baseline ID and name before emitting. When the original field remains under the same ID and name with `ObsoleteState = Pending`, and the replacement uses a new ID, the change follows the rule and must not be flagged.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable breaking-changes knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable breaking-changes knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the knowledge file states the anti-pattern violates a platform-level guarantee. When the file does not make such a claim, the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- Applicability alone is not a finding. Emit `info` only for a concrete, non-actionable observation the article explicitly defines; otherwise emit nothing when no violation is present.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (identifier, syntax, object type).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a breaking-changes defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material API-stability defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly breaking changes; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: restore a published procedure's parameter list and add a new overload for the extra argument; add an `[Obsolete]` attribute to a member being removed; change a needlessly `public` helper to `internal`). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item; default when the skill finishes normally, including when the resulting `findings` array is empty.
- `no-knowledge` — no applicable breaking-changes knowledge survived Source, Relevance, configuration filtering, and conflict resolution. `findings` is empty.
- `not-applicable` — the task context lacks an AL dimension (no AL changes in the diff, or `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before the worklist was exhausted. `summary.coverage` reflects the evaluated subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO output contract. Every finding this skill emits MUST set `findings[].domain` to `"Breaking Changes"`. A populated example:

```json
{
  "skill": { "id": "al-breaking-changes-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/breaking-changes/do-not-change-published-procedure-signatures.md",
      "severity": "major",
      "message": "A parameter was added to the published procedure CalculateDiscount, breaking every dependent extension that called the previous form. Add a new overload alongside the unchanged procedure instead.",
      "location": {
        "file": "src/Sales/DiscountApi.Codeunit.al",
        "line": 12,
        "range": { "start-line": 12, "end-line": 15 }
      },
      "references": [
        { "path": "microsoft/knowledge/breaking-changes/do-not-change-published-procedure-signatures.md" }
      ],
      "confidence": "high",
      "domain": "Breaking Changes"
    },
    {
      "id": "microsoft/knowledge/breaking-changes/choose-access-modifiers-deliberately.md",
      "severity": "minor",
      "message": "An implementation-detail helper is declared public with no reason to support it externally, making it a de-facto API. Default it to internal or local.",
      "location": {
        "file": "src/Sales/OrderProcessor.Codeunit.al",
        "line": 20
      },
      "references": [
        { "path": "microsoft/knowledge/breaking-changes/choose-access-modifiers-deliberately.md" }
      ],
      "confidence": "medium",
      "domain": "Breaking Changes"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case — BCQuality's state until breaking-changes knowledge files land — produces:

```json
{
  "skill": { "id": "al-breaking-changes-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
