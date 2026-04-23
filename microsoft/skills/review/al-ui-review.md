---
kind: action-skill
id: al-ui-review
version: 1
title: AL UI text review
description: Reviews AL page files against UI-text, caption, and tooltip guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL UI text review

Reviews AL page source against the `ui` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

UI findings apply to page files — files that declare `PageType = ...`, including `*.Page.al` under the standard file-naming convention. The skill returns `not-applicable` when the diff contains no page changes.

An orchestrator invokes this skill with either a `pr-diff` or a `file-path`. The skill produces a single JSON document conforming to the DO output contract.

## Source

Collect all knowledge files under `*/knowledge/ui/**/*.md`, across every enabled layer.

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. If absent, `unknown`.
- `application-area` — pass the actual set declared by the changed objects; do not substitute `[all]`.

Discard files that are not applicable. Retain conditionally applicable files only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium` and MUST name the unknown dimensions in `message`.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review.

- **Page-file filter.** UI review applies only to files declaring `page`, `pageextension`, or `pagecustomization`. When the diff contains no such files, return `outcome: "not-applicable"` without evaluating knowledge files.
- For each relevant knowledge file, compute overlap against changed page declarations, weighted toward `Caption`, `ToolTip`, `AboutTitle`, `AboutText`, `OptionCaption`, action definitions, and field-level properties.
- Tokens extracted from the diff (`Caption`, `ToolTip`, `AboutTitle`, `AboutText`, `PageType`, `&`, `Specifies`, `Message(`, `Confirm(`, `Error(` in a page context, `Disabled`, `Invalid`, `Whitelist`, `Blacklist`, trailing punctuation patterns on captions).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic matches a changed page element.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ and record suppressions.

When the post-conflict worklist is empty because no applicable UI knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable UI knowledge matched the page changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. UI text findings are generally `minor` — they affect localization and polish rather than correctness. Reach for `major` only when a banned term appears in customer-facing text or a caption truncation is guaranteed at the stated character limit.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (banned term literal, missing "Specifies" opener on a field tooltip, caption exceeding documented limit).
- `medium` when detection relies on heuristics (judging whether a caption is a noun phrase or a sentence phrase) or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable UI knowledge survived filtering.
- `not-applicable` — the diff contains no page, pageextension, or pagecustomization files.
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
      "id": "microsoft/knowledge/ui/field-tooltips-start-with-specifies-and-end-with-period.md",
      "severity": "minor",
      "message": "Field ToolTip is a fragment ('Customer name') — missing the 'Specifies' opener and the terminating period the house-style guidance requires.",
      "location": {
        "file": "src/Sales/CustomerCard.Page.al",
        "line": 58
      },
      "references": [
        { "path": "microsoft/knowledge/ui/field-tooltips-start-with-specifies-and-end-with-period.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
