---
kind: action-skill
id: al-table-author
version: 1
title: AL table author
description: Generates a correct Business Central master table (and its setup table) from an object spec, applying BCQuality data-modeling guidance.
inputs: [object-spec]
outputs: [code-artifact]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL table author

Generates a Business Central master table — and, when the spec is for a numbered master, its companion setup (singleton) table — from an `object-spec`, applying the `data-modeling` knowledge domain in BCQuality, and emits a `code-artifact`. This is a leaf action skill: it invokes no sub-skills. It is the authoring counterpart to the review skills that flag data-modeling defects — where a review skill consumes a diff and flags a stale audit field or a missing number series, this skill consumes a spec and generates a table that does not have those defects.

An orchestrator invokes this skill with an `object-spec` — an abstract description of the object to generate (target entity name, business fields, whether it is a numbered master, whether it is read-only, and any other generation parameters). The skill produces a single JSON document conforming to the DO `code-artifact` output contract.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `data-modeling` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so authoring reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/data-modeling/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the `object-spec` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the application area declared by the target entity or the `object-spec`. Pass the actual set; do not substitute `[all]`. If the area cannot be determined, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; an artifact generated under any `unknown` dimension MUST have `confidence` no higher than `medium`, AND the artifact's `notes` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to **authoring a master or setup table** for this spec. A data-modeling file enters the worklist when its `keywords` or topic (derived from the index entry's `path`, `title`, and `description`) concern generating a master table, its number assignment, its audit fields, or its companion setup table. Match against master/setup table authoring vocabulary:

- `no-series`, `number-assignment`, `primary-key`, `oninsert`, `getnextno`, `ismanual`, `testmanual`, `noseriesmanagement` — the `No.` primary key, its assignment from a number series in `OnInsert`, and the modern `No. Series` codeunit (`master-table-no-from-number-series-in-oninsert`, `use-no-series-codeunit-not-noseriesmanagement`).
- `setup-table`, `insertallowed`, `deleteallowed`, `getrecordonce`, `card-page` — the singleton setup table that holds the feature's `No. Series` (`setup-table-is-a-singleton`).
- `last-date-modified`, `onmodify`, `onrename`, `audit-field`, `non-editable`, `stale-value` — the maintained `Last Date Modified` field refreshed in both triggers (`set-last-date-modified-in-onmodify-and-onrename`).
- `blocked-field`, `testfield`, `referencing-code`, `point-of-use`, `enforcement` — the inert `Blocked` field and where its check belongs (`check-blocked-in-referencing-code-not-in-master`).

Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies, plus any `.good.al` / `.bad.al` companions — only after it makes the worklist; candidate selection uses the index alone. The `.good.al` companion of a worklisted rule is the authoring template to follow.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable data-modeling knowledge survives — and the skill therefore emits no artifact — emit `outcome: "no-knowledge"`.

## Action

From the `object-spec` (target entity name, business fields, whether it is a numbered master, read-only flag), generate the table object(s) that satisfy every worklisted rule.

For a **master table** spec, generate **two artifacts** (prefer two artifacts over one artifact carrying two objects):

- **(A) the master table.** `No.` `Code[20]` is the sole primary key. Add a non-editable `No. Series` `Code[20]` field (`Editable = false`, `TableRelation = "No. Series"`). Declare `Blocked` as **inert data** with **no** block-check logic in the table's own triggers — per `check-blocked-in-referencing-code-not-in-master` the master MUST NOT enforce `Blocked`; note that enforcement belongs in referencing code (journal/document lines), out of scope for this table author. Add a `Last Date Modified` `Date` field with `Editable = false`. Generate an `OnInsert` trigger that assigns the number only when `No.` is blank:
  `if "No." = '' then begin <Setup>.Get(); <Setup>.TestField("<Entity> Nos."); "No. Series" := <Setup>."<Entity> Nos."; "No." := NoSeries.GetNextNo("No. Series"); end;`
  where `NoSeries` is `Codeunit "No. Series"` — the modern codeunit 310, **never** `NoSeriesManagement`/codeunit 396 (`use-no-series-codeunit-not-noseriesmanagement`). The `No.` field's `OnValidate` guards manual entry via `NoSeries.IsManual`/`TestManual` before clearing `No. Series`. `OnModify` sets `"Last Date Modified" := Today();`, and `OnRename` **also** sets `"Last Date Modified" := Today();` — the key trap, because `OnRename` does not fire `OnModify` (`set-last-date-modified-in-onmodify-and-onrename`). Add the business fields from the spec.
- **(B) the setup (singleton) table.** `Primary Key` `Code[10]` is the sole key (a single blank-keyed row), and a `"<Entity> Nos."` `Code[20]` field with `TableRelation = "No. Series"` that feeds the master's `OnInsert`. NOTE in this artifact's `notes` that the singleton is ENFORCED by a setup Card page with `InsertAllowed = false` / `DeleteAllowed = false` (a **page** object, out of scope for this table author) — cite `setup-table-is-a-singleton` for the table structure and flag the page as a follow-up / open question.

Cite **each** applied knowledge file in the artifact's `references` (same shape as a finding's `references`). `references` SHOULD be non-empty: an authored table is expected to cite the rules it satisfies. Only when the agent generates purely from its own competence — no curated data-modeling knowledge backing the table — is `references` empty, in which case `confidence` is capped at `medium`, mirroring DO's additive agent-findings principle.

Never silently invent values the spec does not provide. Put unresolved ambiguities — a missing object ID, an unspecified field set, an unknown publisher — in `open-questions` (task level) and in the artifact's `notes` (per artifact), and emit them as clearly-labeled placeholders in the generated source rather than guessed values. Emit the generated AL as a single escaped JSON string in `artifacts[].content`: every embedded double quote (for example `Rec."No."`) escaped as `\"`, every newline as `\n`.

Set `confidence` to `high` only when the spec is complete and every worklisted rule was applied; cap at `medium` when any frontmatter dimension was `unknown`, the spec was ambiguous, or an artifact carries placeholders.

For a **non-master / plain table** spec, generate just the table with the subset of rules that applies (for example, a `Last Date Modified` field with its `OnModify`/`OnRename` refresh when the spec describes a maintained entity), and note in the artifact which worklisted rules did not apply and why (for example, no number series because the entity is not numbered).

Outcome selection:

- `completed` — the skill generated and emitted at least one artifact.
- `no-knowledge` — no applicable data-modeling knowledge survived Source, Relevance, configuration filtering, and conflict resolution, and no artifact was emitted. `artifacts` is empty.
- `not-applicable` — the `object-spec` is not a table-authoring request, or it carries no AL dimension (the `technologies` filter rejected the task).
- `partial` — a time or token budget was hit before every requested artifact was generated. `summary.coverage` reflects the produced subset; `outcome-reason` explains the cause.
- `failed` — an unrecoverable error occurred. `outcome-reason` is required.

## Output

Output conforms to the DO `code-artifact` output contract. A populated example — a master `Membership Member` table plus its `Membership Setup` singleton, generated from a spec that left the object IDs unspecified:

```json
{
  "skill": {
    "id": "al-table-author",
    "version": 1
  },
  "outcome": "completed",
  "summary": {
    "counts": {
      "artifacts": 2,
      "objects": 2
    },
    "coverage": {
      "knowledge-applied": 5
    }
  },
  "artifacts": [
    {
      "id": "membership-member-table",
      "object-type": "table",
      "object-name": "Membership Member",
      "path": "src/Membership/MembershipMember.Table.al",
      "content": "table 50100 \"Membership Member\"\n{\n    // TODO: object ID 50100 is a placeholder; replace it with an ID from your assigned range.\n    Caption = 'Membership Member';\n    DataClassification = CustomerContent;\n\n    fields\n    {\n        field(1; \"No.\"; Code[20])\n        {\n            Caption = 'No.';\n            NotBlank = true;\n\n            trigger OnValidate()\n            var\n                NoSeries: Codeunit \"No. Series\";\n            begin\n                if \"No.\" = xRec.\"No.\" then\n                    exit;\n                MembershipSetup.Get();\n                if not NoSeries.IsManual(MembershipSetup.\"Member Nos.\") then\n                    Error(ManualNosNotAllowedErr);\n                \"No. Series\" := '';\n            end;\n        }\n        field(2; \"No. Series\"; Code[20])\n        {\n            Caption = 'No. Series';\n            Editable = false;\n            TableRelation = \"No. Series\";\n        }\n        field(10; Name; Text[100])\n        {\n            Caption = 'Name';\n        }\n        // Blocked is inert data: the master carries the flag but holds no logic that acts on it.\n        // Enforcement belongs in referencing code (journal/document lines), out of scope for this table.\n        field(20; Blocked; Boolean)\n        {\n            Caption = 'Blocked';\n        }\n        field(30; \"Last Date Modified\"; Date)\n        {\n            Caption = 'Last Date Modified';\n            Editable = false;\n        }\n    }\n\n    keys\n    {\n        key(PK; \"No.\")\n        {\n            Clustered = true;\n        }\n    }\n\n    var\n        MembershipSetup: Record \"Membership Setup\";\n        ManualNosNotAllowedErr: Label 'Numbers are assigned automatically. Allow manual numbers on the No. Series to enter one by hand.';\n\n    trigger OnInsert()\n    var\n        NoSeries: Codeunit \"No. Series\";\n    begin\n        if \"No.\" = '' then begin\n            MembershipSetup.Get();\n            MembershipSetup.TestField(\"Member Nos.\");\n            \"No. Series\" := MembershipSetup.\"Member Nos.\";\n            \"No.\" := NoSeries.GetNextNo(\"No. Series\");\n        end;\n    end;\n\n    trigger OnModify()\n    begin\n        \"Last Date Modified\" := Today();\n    end;\n\n    trigger OnRename()\n    begin\n        \"Last Date Modified\" := Today();\n    end;\n}\n",
      "references": [
        {
          "path": "microsoft/knowledge/data-modeling/master-table-no-from-number-series-in-oninsert.md"
        },
        {
          "path": "microsoft/knowledge/data-modeling/use-no-series-codeunit-not-noseriesmanagement.md"
        },
        {
          "path": "microsoft/knowledge/data-modeling/set-last-date-modified-in-onmodify-and-onrename.md"
        },
        {
          "path": "microsoft/knowledge/data-modeling/check-blocked-in-referencing-code-not-in-master.md"
        }
      ],
      "confidence": "medium",
      "notes": "Object ID 50100 is a placeholder the spec did not supply; replace it with an ID from your assigned range before deploying. Blocked is emitted as inert data with no trigger logic: enforcement belongs in referencing code (journal/document lines) per check-blocked-in-referencing-code-not-in-master and is a follow-up outside this table author. Business field set inferred as Name from the spec."
    },
    {
      "id": "membership-setup-table",
      "object-type": "table",
      "object-name": "Membership Setup",
      "path": "src/Membership/MembershipSetup.Table.al",
      "content": "table 50101 \"Membership Setup\"\n{\n    // TODO: object ID 50101 is a placeholder; replace it with an ID from your assigned range.\n    Caption = 'Membership Setup';\n    DataClassification = CustomerContent;\n\n    fields\n    {\n        field(1; \"Primary Key\"; Code[10])\n        {\n            Caption = 'Primary Key';\n        }\n        field(10; \"Member Nos.\"; Code[20])\n        {\n            Caption = 'Member Nos.';\n            TableRelation = \"No. Series\";\n        }\n    }\n\n    keys\n    {\n        key(PK; \"Primary Key\")\n        {\n            Clustered = true;\n        }\n    }\n\n    procedure GetRecordOnce()\n    begin\n        if Rec.Get() then\n            exit;\n        Rec.Init();\n        Rec.Insert();\n    end;\n}\n",
      "references": [
        {
          "path": "microsoft/knowledge/data-modeling/setup-table-is-a-singleton.md"
        },
        {
          "path": "microsoft/knowledge/data-modeling/master-table-no-from-number-series-in-oninsert.md"
        }
      ],
      "confidence": "medium",
      "notes": "Object ID 50101 is a placeholder; replace it before deploying. This artifact is the setup TABLE only: the singleton is ENFORCED by a Membership Setup Card page with InsertAllowed = false and DeleteAllowed = false (a page object, out of scope for this table author) - see open-questions. The Member Nos. field feeds the master's OnInsert number assignment."
    }
  ],
  "open-questions": [
    "Which object IDs (from the consuming extension's assigned range) should the Membership Member and Membership Setup tables use?",
    "A Membership Setup Card page (PageType = Card, InsertAllowed = false, DeleteAllowed = false) is required to enforce the setup singleton and is not authored by this table skill - should it be scaffolded as a follow-up?",
    "Is Name the complete business field set for Membership Member, or should additional fields be modeled?"
  ],
  "suppressed": [],
  "sub-results": [],
  "skipped-sub-skills": []
}
```

The no-knowledge case — when no data-modeling knowledge survives filtering, so no table can be authored against curated guidance — produces:

```json
{
  "skill": {
    "id": "al-table-author",
    "version": 1
  },
  "outcome": "no-knowledge",
  "summary": {
    "counts": {
      "artifacts": 0,
      "objects": 0
    },
    "coverage": {
      "knowledge-applied": 0
    }
  },
  "artifacts": [],
  "open-questions": [],
  "suppressed": [],
  "sub-results": [],
  "skipped-sub-skills": []
}
```
