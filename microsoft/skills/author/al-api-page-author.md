---
kind: action-skill
id: al-api-page-author
version: 1
title: AL API page author
description: Generates a correct Business Central API page (PageType = API) from an object spec, applying BCQuality web-services API guidance.
inputs: [object-spec]
outputs: [code-artifact]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL API page author

Generates a Business Central API page (`PageType = API`) from an `object-spec`, applying the `web-services` knowledge domain in BCQuality, and emits a `code-artifact`. This is a leaf action skill: it invokes no sub-skills. It is the authoring counterpart to `al-web-services-review` — where the review skill consumes a diff and flags API-page defects, this skill consumes a spec and generates a page that does not have them.

An orchestrator invokes this skill with an `object-spec` — an abstract description of the object to generate (target table, desired entity naming, the fields to expose, the read-only flag, and any other generation parameters). The skill produces a single JSON document conforming to the DO `code-artifact` output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `web-services` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so authoring reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/web-services/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the `object-spec` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the application area declared by the target table or the `object-spec`. Pass the actual set; do not substitute `[all]`. If the area cannot be determined, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; an artifact generated under any `unknown` dimension MUST have `confidence` no higher than `medium`, AND the artifact's `notes` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to **authoring an API page** for this spec. A web-services file enters the worklist when its `keywords` or topic (derived from the index entry's `path`, `title`, and `description`) concern `PageType = API` page authoring. Match against API-page authoring vocabulary:

- `api-page`, `pagetype-api`, `odatakeyfields`, `systemid`, `apiversion`, `apipublisher`, `apigroup`, `entityname`, `entitysetname`, `sourcetable` — the required identifying metadata and the stable-key rule.
- `bound-actions`, `serviceenabled`, `webserviceactioncontext` — when the spec asks for operations rather than plain field writes.
- `read-only`, `insertallowed`, `modifyallowed`, `deleteallowed`, `editable` — when the spec marks the page read-only.
- `committed-data`, `readisolation`, `readcommitted` — when the spec requires committed-only reads.
- `apiversion`, `versioning` — when the spec evolves an already-published API.

Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies, plus any `.good.al` / `.bad.al` companions — only after it makes the worklist; candidate selection uses the index alone. The `.good.al` companion of a worklisted rule is the authoring template to follow.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable web-services API knowledge survives — and the skill therefore emits no artifact — emit `outcome: "no-knowledge"`.

## Action

From the `object-spec` (target table, entity naming, fields to expose, read-only flag), generate **one** API page object that satisfies every worklisted rule:

- `PageType = API` with `APIPublisher`, `APIGroup`, and `APIVersion` set, plus `EntityName` (singular) and `EntitySetName` (plural), and a `SourceTable` bound to the spec's target table — the full identifying-property checklist.
- `ODataKeyFields = SystemId`, exposed as a non-editable `field(id; Rec.SystemId)` (`Editable = false`), so the endpoint is addressed by the stable GUID rather than a renamable business key.
- `DelayedInsert = true`.
- A single `repeater` under `area(content)` projecting the spec's fields with camelCase API field names mapped from the underlying table fields; keep the business key (for example `No.`) as an ordinary exposed field, not as the OData key.
- When the spec marks the page read-only: set `InsertAllowed = false`, `ModifyAllowed = false`, `DeleteAllowed = false`, and `Editable = false`. When the spec asks for a record operation (post, ship, release), expose it as a `[ServiceEnabled]` bound action that reports its result through `WebServiceActionContext`, rather than a writable status flag whose `OnValidate` performs the operation.
- When the spec requires committed-only reads, set `Rec.ReadIsolation := IsolationLevel::ReadCommitted;` in `OnOpenPage`. When the spec evolves an already-published API, add the new version to the `APIVersion` list instead of mutating the published one. Expose only committed data; do not surface in-flight writes.

Cite each applied knowledge file in the artifact's `references` (same shape as a finding's `references`). The artifact's `references` SHOULD be non-empty: an authored page is expected to cite the rules it satisfies. Only when the agent generates purely from its own competence — no curated web-services knowledge backing the page — is `references` empty, in which case `confidence` is capped at `medium`, mirroring DO's additive agent-findings principle.

Never silently invent values the spec does not provide. Put unresolved ambiguities — a missing object ID, an unspecified field set, an unknown publisher or group — in `open-questions` (task level) and in the artifact's `notes` (per artifact), and emit them as clearly-labeled placeholders in the generated source rather than guessed values. Emit the generated AL as a single escaped JSON string in `artifacts[].content`: every embedded double quote (for example `Rec."No."`) escaped as `\"`, every newline as `\n`.

Set `confidence` to `high` only when the spec is complete and every worklisted rule was applied; cap at `medium` when any frontmatter dimension was `unknown`, the spec was ambiguous, or the page carries placeholders.

Outcome selection:

- `completed` — the skill generated and emitted at least one artifact.
- `no-knowledge` — no applicable web-services API knowledge survived Source, Relevance, configuration filtering, and conflict resolution, and no artifact was emitted. `artifacts` is empty.
- `not-applicable` — the `object-spec` is not an API-page request, or it carries no AL dimension (the `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before every requested artifact was generated. `summary.coverage` reflects the produced subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO `code-artifact` output contract. A populated example — a generated `customer` API page whose spec left the object ID, publisher, and group unspecified:

```json
{
  "skill": { "id": "al-api-page-author", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "artifacts": 1, "objects": 1 },
    "coverage": { "knowledge-applied": 2 }
  },
  "artifacts": [
    {
      "id": "customer-api-page",
      "object-type": "page",
      "object-name": "Customer Entity",
      "path": "src/Api/CustomerEntity.Page.al",
      "content": "page 50100 \"Customer Entity\"\n{\n    // TODO: object ID 50100 is a placeholder; replace with an ID from your assigned range.\n    PageType = API;\n    Caption = 'customer';\n    APIPublisher = 'PLACEHOLDER-publisher';\n    APIGroup = 'PLACEHOLDER-group';\n    APIVersion = 'v1.0';\n    EntityName = 'customer';\n    EntitySetName = 'customers';\n    ODataKeyFields = SystemId;\n    SourceTable = Customer;\n    DelayedInsert = true;\n\n    layout\n    {\n        area(content)\n        {\n            repeater(records)\n            {\n                field(id; Rec.SystemId)\n                {\n                    Caption = 'id';\n                    Editable = false;\n                }\n                field(number; Rec.\"No.\")\n                {\n                    Caption = 'number';\n                }\n                field(displayName; Rec.Name)\n                {\n                    Caption = 'displayName';\n                }\n            }\n        }\n    }\n}",
      "references": [
        { "path": "microsoft/knowledge/web-services/set-required-api-page-properties.md" },
        { "path": "microsoft/knowledge/web-services/expose-systemid-as-the-api-key.md" }
      ],
      "confidence": "medium",
      "notes": "Object ID, APIPublisher, and APIGroup are placeholders the spec did not supply; replace them before deploying. Field set inferred as No. and Name from the customer spec."
    }
  ],
  "open-questions": [
    "Which object ID (from the consuming extension's assigned range) should this page use?",
    "What APIPublisher and APIGroup identify this endpoint?",
    "Is the No. + Name field set complete, or should more Customer fields be exposed?"
  ],
  "suppressed": [],
  "sub-results": [],
  "skipped-sub-skills": []
}
```

The no-knowledge case — when no web-services API knowledge survives filtering, so no page can be authored against curated guidance — produces:

```json
{
  "skill": { "id": "al-api-page-author", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "artifacts": 0, "objects": 0 },
    "coverage": { "knowledge-applied": 0 }
  },
  "artifacts": [],
  "open-questions": [],
  "suppressed": [],
  "sub-results": [],
  "skipped-sub-skills": []
}
```
