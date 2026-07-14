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

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `privacy` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/privacy/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. Exclude test codeunits, test libraries, test helper code, files under test/Test/Tests paths, and objects with `Subtype = Test`; test data is synthetic and does not ship to customers. For each relevant file, compute overlap against:

- The changed AL object names and types — especially tables and tableextensions (for `DataClassification` on fields), codeunits that call `Error`, `Session.LogMessage`, or `FeatureTelemetry`, codeunits performing outgoing HTTP requests with customer data, migration codeunits, and objects reading or writing `IsolatedStorage`.
- The changed procedures and triggers, weighted toward those that call `Error`, construct `ErrorInfo`, call `Session.LogMessage`, `StrSubstNo`, `GetLastErrorText`/`GetLastErrorCallStack`, `FeatureTelemetry.LogUsage`/`LogUptake`/`LogError`, `HttpClient.Post`/`Get`, `IsolatedStorage.Set`/`SetEncrypted`/`Get`, or `PrivacyNotice.GetPrivacyNoticeApprovalState`.
- Tokens extracted from the diff that relate to privacy (`DataClassification`, `CustomerContent`, `EndUserIdentifiableInformation`, `EndUserPseudonymousIdentifiers`, `SystemMetadata`, `ToBeClassified`, `PrivacyNotice`, `ErrorInfo`, `GetLastErrorText`, `GetLastErrorCallStack`, `TelemetryScope`, `FeatureTelemetry`, `CustomDimensions`, `LogUsage`, `LogUptake`, `LogError`, `ErrorText`, `ErrorCallStack`, `alErrorText`, `alErrorCallStack`, `HybridSL`, `HybridGP`, `HybridBC`).
- Treat `ErrorInfo.Message`, `ErrorInfo.DataClassification`, `ErrorInfo.ErrorType`, and `ErrorInfo.DetailedMessage` as qualified member signals: accept a call or assignment only when symbol resolution proves that its receiver expression or variable has type `ErrorInfo`. Normalize those accesses to `errorinfo-message`, `errorinfo-dataclassification`, `errorinfo-errortype`, and `errorinfo-detailedmessage` retrieval tokens. Bare `Message` or `DataClassification` tokens MUST NOT trigger this article; do not emit the qualified tokens for `Message(...)` dialog calls, table or table-field `DataClassification` properties, or similarly named members on other types. Resolve the receiver's declaration from the containing object when it is outside the changed hunk.
- Worklist ErrorInfo privacy guidance only from those typed `ErrorInfo` member tokens or from construction of an `ErrorInfo` value. For every `FeatureTelemetry.LogError`, inspect the dedicated error text and call-stack arguments in addition to explicit custom dimensions.

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Apply the topic-specific gates above after this overlap check; in particular, bare `Message` and `DataClassification` tokens cannot admit ErrorInfo guidance. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone.

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

After evaluating each worklist entry, also consider whether the diff exhibits a privacy defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material privacy defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly privacy; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: delete unreachable lines; replace `Count() > 0` with `not IsEmpty()`; move a local `Label` to object scope; add a missing `ToolTip`, `OptionCaption`, or `DataClassification`; replace a string-concatenated `Error` with a Label-backed call; change an over-broad permission token; or add an obvious `else`/guard branch). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

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
      "id": "microsoft/knowledge/privacy/data-classification-required-on-pii-fields.md",
      "severity": "major",
      "message": "The new Customer E-Mail table field has no DataClassification property, leaving personal data unclassified.",
      "location": {
        "file": "src/Sales/Customer.TableExt.al",
        "line": 64,
        "range": { "start-line": 60, "end-line": 64 }
      },
      "references": [
        { "path": "microsoft/knowledge/privacy/data-classification-required-on-pii-fields.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
