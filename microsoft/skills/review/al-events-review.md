---
kind: action-skill
id: al-events-review
version: 1
title: AL events review
description: Reviews AL source changes against events-and-subscribers guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL events review

Reviews AL source changes against the `events` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). The skill produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `events` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/events/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially codeunits that publish events or host event subscribers, posting/release/validation routines that should expose extension points, and test codeunits that bind subscribers.
- The changed procedures and triggers, weighted toward event publisher methods, methods carrying the `[EventSubscriber(...)]` attribute, routines that raise `OnBefore`/`OnAfter` events, and any procedure that calls `BindSubscription`/`UnbindSubscription`.
- Tokens extracted from the diff that relate to events and the publish/subscribe model (`IntegrationEvent`, `BusinessEvent`, `EventSubscriber`, `IsHandled`, `BindSubscription`, `UnbindSubscription`, `EventSubscriberInstance`, `OnBefore`, `OnAfter`, `Manual`, `IncludeSender`, `Sender`, `this`, `RecordRef`, `xRec`, `temporary`, `Temp`, `repeat`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable events knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable events knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

### Event-design checks

The following targeted checks map diff signals to specific `events` articles. Treat each as a candidate-selection cue: when the signal appears in the changed code, add the named article to the worklist and evaluate it in Action.

- `IsHandled` raised without an immediately preceding `IsHandled := false;`, or one `IsHandled` variable reused across several raises with no reset between them — `initialize-ishandled-to-false-before-publishing`.
- `if IsHandled then exit;` in a routine that also raises a paired `OnAfter…` event later, so the after-event is skipped whenever the call is handled — `preserve-onafter-execution-when-ishandled-skips-the-body`.
- A parameter added before existing parameters on a changed event signature instead of appended at the end — `add-new-event-parameters-at-the-end`.
- Publisher names that do not encode firing position (`OnBefore`/`OnAfter<Routine>` at the boundaries, `On<Routine>OnBefore`/`OnAfter<Context>` mid-routine) — `name-events-by-publisher-position`.
- Two consecutive `OnBefore`/`OnAfter` raises with no logic between them, or a near-duplicate event differing only by an extra parameter — `prefer-reusing-or-extending-existing-events`.
- An event raised between `repeat` and `until` inside a record loop — `do-not-publish-events-inside-loops`.
- A `temporary` record event parameter whose name does not start with `Temp` — `prefix-temporary-record-event-parameters-with-temp`.
- Abbreviated event parameter names (`SalesHdr`, `DocNo`, `Amt`) instead of full table names and spelled-out values — `name-event-parameters-without-abbreviations`.
- `[IntegrationEvent(true, …)]` (`IncludeSender`) on a codeunit event used only to expose the publisher, where `this` could be passed as a typed `Sender` parameter (Business Central 2024 release wave 2 and later) — `prefer-this-over-includesender-in-codeunit-events`.
- A `RecordRef` event parameter, or a passed-through `xRec`, where a concrete typed record fits — `avoid-loosely-typed-event-parameters`.
- A `var IsHandled` added to a pre-existing event rather than introduced through a new `OnBefore` publisher — `do-not-add-ishandled-to-an-existing-event`.
- An `if IsHandled then exit;` whose skipped body performs posting, ledger-entry creation, number-series consumption, or integrity/permission validation — `do-not-bypass-critical-operations-with-ishandled`.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the knowledge file states the anti-pattern violates a platform-level guarantee. When the file does not make such a claim, the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file. Repository-wide observations MAY omit `location`.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (identifier, syntax, object type).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits an events defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material events defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly events and subscribers; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: empty out a non-empty `[IntegrationEvent]` publisher body; add the missing `if IsHandled then exit;` guard after an `OnBefore` raise; add a matching `UnbindSubscription` for a leaked `BindSubscription`; set `EventSubscriberInstance = Manual;` on a codeunit that must be scoped). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item; default when the skill finishes normally, including when the resulting `findings` array is empty.
- `no-knowledge` — no applicable events knowledge survived Source, Relevance, configuration filtering, and conflict resolution. `findings` is empty.
- `not-applicable` — the task context lacks an AL dimension (no AL changes in the diff, or `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before the worklist was exhausted. `summary.coverage` reflects the evaluated subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-events-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/events/publish-thin-onbefore-onafter-integration-events.md",
      "severity": "major",
      "message": "Business logic is placed inside an [IntegrationEvent] publisher body, so the event mutates state on every raise instead of being a thin hook. Move the logic into the calling routine and leave the publisher body empty.",
      "location": {
        "file": "src/Sales/ReservationMgt.Codeunit.al",
        "line": 64,
        "range": { "start-line": 61, "end-line": 67 }
      },
      "references": [
        { "path": "microsoft/knowledge/events/publish-thin-onbefore-onafter-integration-events.md" }
      ],
      "confidence": "high"
    },
    {
      "id": "microsoft/knowledge/events/use-ishandled-to-make-base-behaviour-overridable.md",
      "severity": "minor",
      "message": "An OnBefore event is raised with a var IsHandled parameter, but the routine never guards with 'if IsHandled then exit;', so the default logic still runs after a subscriber handled the call.",
      "location": {
        "file": "src/Sales/ReservationMgt.Codeunit.al",
        "line": 41
      },
      "references": [
        { "path": "microsoft/knowledge/events/use-ishandled-to-make-base-behaviour-overridable.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case — BCQuality's state until events knowledge files land — produces:

```json
{
  "skill": { "id": "al-events-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
