---
kind: action-skill
id: al-privacy-review
version: 1
title: AL privacy review
description: Reviews AL source changes against privacy and data-classification guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL privacy review

Reviews AL source changes against the `privacy` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). The skill produces a single JSON document conforming to the DO output contract.

## Source

Collect all knowledge files under `*/knowledge/privacy/**/*.md`, across every enabled layer (`/microsoft/`, `/community/`, `/custom/`). Relevance trims the result to the subset that applies.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially tables and tableextensions (for `DataClassification` on fields), codeunits that call `Error` or `Session.LogMessage`, codeunits performing outgoing HTTP requests with customer data, and objects reading or writing `IsolatedStorage`.
- The changed procedures and triggers, weighted toward those that call `Error`, `Session.LogMessage`, `StrSubstNo`, `GetLastErrorText`, `HttpClient.Post`/`Get`, `IsolatedStorage.Set`/`SetEncrypted`/`Get`, or `PrivacyNotice.GetPrivacyNoticeApprovalState`.
- Tokens extracted from the diff that relate to privacy (`DataClassification`, `CustomerContent`, `EndUserIdentifiableInformation`, `SystemMetadata`, `ToBeClassified`, `PrivacyNotice`, `GetLastErrorText`, `TelemetryScope`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from filename and Description) matches a changed object type.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable privacy knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable privacy knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the knowledge file states the anti-pattern violates a platform-level guarantee (for example, documented telemetry-classification rules or GDPR-adjacent data-handling requirements). When the file does not make such a claim, the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file. Repository-wide observations MAY omit `location`.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (identifier, syntax, object type).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

Outcome selection:

- `completed` — the skill evaluated every worklist item; default when the skill finishes normally, including when the resulting `findings` array is empty.
- `no-knowledge` — no applicable privacy knowledge survived Source, Relevance, configuration filtering, and conflict resolution. `findings` is empty.
- `not-applicable` — the task context lacks an AL dimension (no AL changes in the diff, or `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before the worklist was exhausted. `summary.coverage` reflects the evaluated subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-privacy-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/privacy/strsubstno-prebuild-breaks-error-telemetry-classification.md",
      "severity": "major",
      "message": "Error receives a pre-built Text produced by StrSubstNo with customer name and email as arguments. Per the referenced guidance the platform cannot classify or strip PII from an opaque Text and will export the full message to telemetry.",
      "location": {
        "file": "src/Sales/CustomerValidation.Codeunit.al",
        "line": 64,
        "range": { "start-line": 60, "end-line": 64 }
      },
      "references": [
        { "path": "microsoft/knowledge/privacy/strsubstno-prebuild-breaks-error-telemetry-classification.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
