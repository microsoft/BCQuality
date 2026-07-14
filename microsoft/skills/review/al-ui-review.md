---
kind: action-skill
id: al-ui-review
version: 1
title: AL UI and accessibility review
description: Reviews AL page and control add-in UI files against UI text, caption, tooltip, and accessibility guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al, javascript]
countries: [w1]
application-area: [all]
---

# AL UI and accessibility review

Reviews AL page source and control add-in UI files against the `ui` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

UI findings apply to page files — files that declare `PageType = ...`, including `*.Page.al` under the standard file-naming convention — and to JavaScript/CSS/HTML files that implement Business Central control add-ins, including their client-service communication. The skill returns `not-applicable` when the diff contains no page or control add-in changes.

An orchestrator invokes this skill with either a `pr-diff` or a `file-path`. The skill produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `ui` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/ui/**`.

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]` or `[javascript]`.
- `countries` — the countries declared in the consuming app's `app.json`. If absent, `unknown`.
- `application-area` — pass the actual set declared by the changed objects; do not substitute `[all]`.

Discard files that are not applicable. Retain conditionally applicable files only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium` and MUST name the unknown dimensions in `message`.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review.

- **UI-file filter.** UI review applies to files declaring `page`, `pageextension`, or `pagecustomization`, and to JavaScript/CSS/HTML that implements a control add-in's rendering or Business Central communication. When the diff contains no such files, return `outcome: "not-applicable"` without evaluating knowledge files.
- For each relevant knowledge file, compute overlap against changed page declarations and control add-in files, weighted toward `Caption`, `ToolTip`, `AboutTitle`, `AboutText`, `OptionCaption`, `ShowCaption`, `InstructionalText`, `GridLayout`, `Style`, `StyleExpr`, promoted action definitions, field importance, page background tasks, DOM creation, ARIA attributes, keyboard/focus handlers, packaged-resource AJAX, and calls from JavaScript into AL.
- Tokens extracted from the diff (`Caption`, `ToolTip`, `AboutTitle`, `AboutText`, `PageType`, `ShowCaption`, `InstructionalText`, `grid`, `fixed`, `GridLayout`, `Style`, `StyleExpr`, `Importance`, `Promoted`, `Additional`, `area(Promoted)`, `actionref`, `PromotedCategory`, `PromotedOnly`, `PromotedIsBig`, `ShowAs`, `SplitButton`, `EnqueueBackgroundTask`, `OnAfterGetCurrRecord`, `OnAfterGetRecord`, `OnPageBackgroundTaskCompleted`, `OnPageBackgroundTaskError`, `RunPageBackgroundTask`, `Favorable`, `Unfavorable`, `Ambiguous`, `cuegroup`, `controladdin`, `control-add-in`, `usercontrol`, `aria-`, `tabindex`, `keydown`, `focus`, `innerHTML`, `createElement`, `packaged-resource`, `ajax`, `$.get`, `$.ajax`, `XMLHttpRequest`, `xhrFields`, `withCredentials`, `withcredentials`, `InvokeExtensibilityMethod`, `invokeextensibilitymethod`, `skipIfBusy`, `successCallback`, `success-callback`, `errorCallback`, `setInterval`, `JSON.stringify`, `payload`, `throttling`, `reduced-functionality`, `ClientServicesMaxUploadSize`, `&`, `Specifies`, `Message(`, `Confirm(`, `Error(` in a page context, `Disabled`, `Invalid`, `Whitelist`, `Blacklist`, trailing punctuation patterns on captions).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed page element. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ and record suppressions.

When the post-conflict worklist is empty because no applicable UI knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable UI knowledge matched the page changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. UI text findings are generally `minor` — they affect localization and polish rather than correctness. Accessibility findings for missing labels, broken grid semantics, semantic color without text meaning, or UI-rendering control add-in changes can be `major`; use `minor` for low-risk manual-review reminders and polish issues.

For packaged-resource requests, flag `$.get` or AJAX/XHR that omits `withCredentials` only when the URL is identifiable as a resource in the control add-in package; do not generalize the rule to external endpoints. For `InvokeExtensibilityMethod`, flag repeated or timer-driven calls that can overlap because they do not wait for the success/error callbacks, and unbounded serialized payloads sent in one call. Prefer bounded chunks serialized through completion callbacks. Do not emit generic browser or JavaScript performance advice.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (banned term literal, missing "Specifies" opener on a field tooltip, caption exceeding documented limit).
- `medium` when detection relies on heuristics (judging whether a caption is a noun phrase or a sentence phrase) or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a UI defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material UI defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly UI; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: delete unreachable lines; replace `Count() > 0` with `not IsEmpty()`; move a local `Label` to object scope; add a missing `ToolTip`, `OptionCaption`, or `DataClassification`; replace a string-concatenated `Error` with a Label-backed call; change an over-broad permission token; or add an obvious `else`/guard branch). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable UI knowledge survived filtering.
- `not-applicable` — the diff contains no page, pageextension, pagecustomization, or control add-in implementation files.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-ui-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/ui/show-caption-on-editable-fields.md",
      "severity": "minor",
      "message": "An editable page field sets ShowCaption = false, removing the visible and accessible label. Leave ShowCaption enabled or use a documented exception pattern.",
      "location": {
        "file": "src/Sales/CustomerCard.Page.al",
        "line": 58
      },
      "references": [
        { "path": "microsoft/knowledge/ui/show-caption-on-editable-fields.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
