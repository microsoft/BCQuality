---
kind: action-skill
id: al-object-author
version: 1
title: AL object author
description: Generates BC objects from an object spec by composing the AL author leaf skills (API page, table).
inputs: [object-spec]
outputs: [code-artifact]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - microsoft/skills/author/al-api-page-author.md
  - microsoft/skills/author/al-table-author.md
---

# AL object author

Generates Business Central objects from an `object-spec` by composing the leaf AL author skills. This is a **super-skill** — the authoring counterpart to `al-code-review`. Where `al-code-review` composes the review leaves and rolls up their findings-reports, `al-object-author` composes the author leaves and rolls up their `code-artifact` reports.

`al-object-author` does not evaluate knowledge files directly. It invokes each of its sub-skills against the same `object-spec`, collects their `code-artifact` reports, and rolls up their generated `artifacts[]` into a single composed `code-artifact`. Unlike a review super-skill, an author super-skill performs **no agent self-review pass** and emits no agent findings: `code-artifact` output has no findings channel, so composition here is purely *invoke the leaves and roll up their artifacts*.

An orchestrator invokes this skill with an `object-spec` — an abstract description of the object(s) to generate. The skill produces a single JSON document conforming to the DO `code-artifact` output contract, extended with `sub-results` and — when applicable — `skipped-sub-skills`.

## Source

The sub-skills invoked by this skill are those listed in frontmatter `sub-skills`:

- `microsoft/skills/author/al-api-page-author.md` — generates a `PageType = API` page from the spec.
- `microsoft/skills/author/al-table-author.md` — generates a master table (and its setup table) from the spec.

Additional author leaf skills are added by updating the `sub-skills` list. The skill does not discover sub-skills implicitly.

## Relevance

A sub-skill is relevant when both of the following hold:

- The orchestrator has supplied inputs that satisfy the sub-skill's declared `inputs`. Both author leaves declare `inputs: [object-spec]`, so both are relevant whenever the orchestrator supplies an `object-spec`.
- The orchestrator has not disabled the sub-skill via configuration.

Per the DO contract, the super-skill MUST NOT filter sub-skills by task content. `al-object-author` does not inspect the `object-spec` to predict whether it describes a table or an API page. Each leaf is responsible for its own task-level applicability decision: a leaf **self-selects** by returning `outcome: "not-applicable"` when the spec is not for its object type (`al-api-page-author` returns `not-applicable` for a table spec; `al-table-author` returns `not-applicable` for an API-page spec), exactly as review leaves signal non-applicability with `not-applicable` / `no-knowledge`. There is no object-type dispatch in the super-skill.

Sub-skills that fail either check are not invoked and are recorded in `skipped-sub-skills`:

- `reason: "configuration"` when the orchestrator disabled the sub-skill.
- `reason: "not-applicable"` when the orchestrator's inputs do not satisfy the sub-skill's declared `inputs`.

## Worklist

The worklist is the list of sub-skills judged relevant by the previous step. Every sub-skill in the worklist will be invoked in the Action step. Because both leaves declare `inputs: [object-spec]`, both are on the worklist whenever an `object-spec` is supplied and neither is disabled by configuration.

## Action

### Execution discipline (mandatory)

The Action step is a sequence of **discrete iterations**, not one combined generation. Treat each sub-skill in the worklist as its own pass: read the sub-skill's instructions, apply its Source → Relevance → Worklist → Action steps to the supplied `object-spec`, and produce that sub-skill's complete `code-artifact` report before moving on. Do not collapse multiple sub-skills into one shared reasoning step; each leaf has a distinct knowledge subset and a distinct generation procedure. Sub-skills are independent: re-reading the spec once per sub-skill is correct and expected. The output schema accommodates this — `sub-results` carries one entry per invoked sub-skill, each a complete `code-artifact` report.

### Roll up sub-skill artifacts

For each sub-skill in the worklist, executed one at a time per the discipline above:

1. Invoke the sub-skill with the `object-spec`.
2. Capture the sub-skill's complete `code-artifact` report verbatim and append it to `sub-results`.
3. If the sub-skill's `outcome` is `failed`, stop here for this sub-skill: its artifacts are not reliable per the DO contract and MUST NOT be copied into the super-skill's top-level `artifacts[]` or counted in `summary.counts` (its report is still preserved in `sub-results` for traceability).
4. Otherwise, append each entry from the sub-skill's `artifacts[]` to the super-skill's top-level `artifacts[]`. A `not-applicable` or `no-knowledge` leaf contributes zero artifacts. Artifacts are rolled up verbatim; the `code-artifact` schema has no per-artifact `from-sub-skill` field, and leaf attribution is preserved through `sub-results`.

Aggregate `open-questions` across leaves into the super-skill's top-level `open-questions` (deduplicating identical entries). A `not-applicable` / `no-knowledge` leaf contributes none.

### Summary and rollup

`summary.counts.artifacts` and `summary.counts.objects` are the sums across invoked sub-skills whose `outcome` is not `failed`; `summary.coverage.knowledge-applied` is the sum of the leaves' `knowledge-applied` counts. `suppressed[]` at the super-skill level remains empty — knowledge-file suppression is reported by each leaf within its own entry in `sub-results`.

Derive `outcome` using the DO *Outcome rollup* rules over the multiset S of worklisted sub-skills' outcomes. For a master-table spec, S = {`al-api-page-author`: `not-applicable`, `al-table-author`: `completed`} rolls up to `completed`. When every leaf returns `not-applicable` (a spec neither leaf authors), the roll-up is `not-applicable`. `outcome-reason` is required for `partial` and `failed` and SHOULD summarize per-sub-skill state.

## Output

Output conforms to the DO `code-artifact` output contract, extended with `sub-results` and `skipped-sub-skills`. A populated example — an `object-spec` for a master table: `al-api-page-author` self-selects out with `not-applicable`, `al-table-author` generates the two table artifacts, and the super-skill rolls up to `completed`:

```json
{
  "skill": {
    "id": "al-object-author",
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
  "sub-results": [
    {
      "skill": {
        "id": "al-api-page-author",
        "version": 1
      },
      "outcome": "not-applicable",
      "outcome-reason": "The object-spec requests a master table, not a PageType = API page; al-api-page-author authors only API pages.",
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
    },
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
  ],
  "skipped-sub-skills": []
}
```

The all-not-applicable case — an `object-spec` neither leaf authors (for example, an enum or a report object) — rolls up to `not-applicable`:

```json
{
  "skill": {
    "id": "al-object-author",
    "version": 1
  },
  "outcome": "not-applicable",
  "outcome-reason": "Neither author leaf handles the supplied object-spec: al-api-page-author authors API pages and al-table-author authors tables; the spec requests neither.",
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
  "sub-results": [
    {
      "skill": {
        "id": "al-api-page-author",
        "version": 1
      },
      "outcome": "not-applicable",
      "outcome-reason": "The object-spec requests an enum, not a PageType = API page.",
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
    },
    {
      "skill": {
        "id": "al-table-author",
        "version": 1
      },
      "outcome": "not-applicable",
      "outcome-reason": "The object-spec requests an enum, not a master or setup table.",
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
  ],
  "skipped-sub-skills": []
}
```
