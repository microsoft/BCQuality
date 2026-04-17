---
kind: action-skill
id: al-code-review
version: 1
title: AL code review
description: Reviews AL source changes against performance, security, UX, telemetry, and testing guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [26..28]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL code review

Reviews AL source changes against applicable BCQuality guidance and emits a findings report. This skill is the canonical reference implementation of the DO contract — skill authors should copy its structure.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review, typically from an IDE). The skill produces a single JSON document conforming to the DO output contract.

## Source

Collect all knowledge files under `*/knowledge/**/*.md`, across every enabled layer (`/microsoft/`, `/community/`, `/custom/`). Files in any domain subfolder are included; the skill does not enumerate domains. Relevance trims the result to the subset that applies.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown` (see READ's partial-context rule).
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set (e.g., `[finance, jobs]` for a PR touching both); do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown so reviewers can judge the finding's applicability.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types (tables, pages, codeunits, reports, queries, xmlports, enums, permission sets).
- The changed procedures, triggers, and fields.
- Tokens extracted from the diff (identifier names, referenced objects, keywords).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from filename and Description) matches a changed object type.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ: for any two candidates whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts, keep the file from the higher-precedence layer and drop the other. Every dropped file MUST be recorded in the output `suppressed` array with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration MUST be recorded with `reason: "configuration"`. Files that were never candidates (failed Relevance or did not match task signal) are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable knowledge exists in the repo, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, the message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the knowledge file states the anti-pattern violates a platform-level guarantee; when the file does not make that claim, the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file so the author is nudged to read it. Repository-wide observations MAY omit `location`.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (identifier, syntax, object type).
- `medium` when detection relies on heuristics (name similarity, scope inference) or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability (no detection signal).

The outcome selection:

- `completed` — the skill evaluated every worklist item. Default when the skill finishes normally, including when the resulting `findings` array is empty.
- `no-knowledge` — no applicable knowledge survived Source, Relevance, configuration filtering, and conflict resolution. `findings` is empty.
- `not-applicable` — the task context lacks an AL dimension (no AL changes in the diff, or `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before the worklist was exhausted. `summary.coverage` reflects the evaluated subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-code-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 1 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/performance/filter-before-find.md",
      "severity": "major",
      "message": "FindSet is called on a record variable without any prior SetRange/SetFilter. This forces a full-table scan.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 140,
        "range": { "start-line": 140, "end-line": 144 }
      },
      "references": [
        { "path": "microsoft/knowledge/performance/filter-before-find.md" }
      ],
      "confidence": "high"
    },
    {
      "id": "microsoft/knowledge/security/avoid-implicit-commit.md",
      "severity": "minor",
      "message": "An explicit COMMIT inside a posting routine may leave the ledger in an inconsistent state if subsequent steps fail.",
      "location": {
        "file": "src/Sales/PostingRoutines.Codeunit.al",
        "line": 201
      },
      "references": [
        { "path": "microsoft/knowledge/security/avoid-implicit-commit.md" }
      ],
      "confidence": "medium"
    },
    {
      "id": "community/knowledge/telemetry/log-posting-failures.md",
      "severity": "info",
      "message": "Posting routine touched; consider whether failure paths emit telemetry per the linked guidance.",
      "references": [
        { "path": "community/knowledge/telemetry/log-posting-failures.md" }
      ],
      "confidence": "low"
    }
  ],
  "suppressed": [
    {
      "reference": { "path": "community/knowledge/performance/filter-before-find.md" },
      "reason": "layer-precedence"
    }
  ]
}
```

The empty-corpus case — BCQuality's state until knowledge files land — produces:

```json
{
  "skill": { "id": "al-code-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
