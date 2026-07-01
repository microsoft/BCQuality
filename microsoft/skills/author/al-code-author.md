---
kind: action-skill
id: al-code-author
version: 1
title: AL code author
description: Authors Business Central code by composing the AL author leaf skills - the authoring counterpart to al-code-review. Its current authoring mode greenfields a feature, decomposing a feature-spec into objects, composing the object-type author leaves, and reconciling cross-object references to emit a whole-PR code-artifact.
inputs: [feature-spec]
outputs: [code-artifact]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
sub-skills:
  - microsoft/skills/author/al-api-page-author.md
  - microsoft/skills/author/al-table-author.md
---

# AL code author

`al-code-author` is the role-level **authoring counterpart to `al-code-review`**: where `al-code-review` takes a whole PR and composes the review leaves, rolling up their findings-reports, `al-code-author` composes the leaf AL author skills to **produce a whole PR of code**, rolling up their `code-artifact` reports into a single whole-PR `code-artifact`. It is a **super-skill** — it composes other author skills rather than reading knowledge files directly.

Its **first and currently only** authoring mode is **greenfield feature authoring**: given a `feature-spec` it decomposes the feature into a set of new objects, composes the object-type author leaves, and reconciles the cross-object references. Other modes — for example fixing a defect from a bug report, which needs a different input and a *locate-and-modify* Action rather than greenfield decomposition — are future extensions of this same entry skill and are out of scope today.

The super-skill's own input (`feature-spec`) is coarser than its leaves' input (`object-spec`), and bridging that gap is this skill's job. Its **Action** decomposes the `feature-spec` into a cross-referenced graph of object specs, feeds each object spec to the worklisted leaves, rolls up the artifacts they produce, and reconciles the references across those objects. It does not evaluate knowledge files directly and performs **no agent self-review pass**: `code-artifact` output has no findings channel, so composition here is *decompose -> invoke leaves -> roll up artifacts -> reconcile*.

An orchestrator invokes this skill with a `feature-spec` - an abstract description of the feature's entities, their relationships, the surfaces (pages and APIs) to expose, and generation parameters. The skill produces a single JSON document conforming to the DO `code-artifact` output contract, extended with `sub-results` and - when applicable - `skipped-sub-skills`.

## Source

The sub-skills invoked by this skill are those listed in frontmatter `sub-skills` - the object-type author leaves:

- `microsoft/skills/author/al-api-page-author.md` - generates a `PageType = API` page from an object spec.
- `microsoft/skills/author/al-table-author.md` - generates a master table (and its setup table) from an object spec.

This skill composes those leaves; it does not read knowledge files directly. Additional object-type author leaves are added by updating the `sub-skills` list. The skill does not discover sub-skills implicitly.

## Relevance

A sub-skill is relevant when both of the following hold:

- Its declared `inputs` will be satisfied. The leaves declare `inputs: [object-spec]`; this super-skill declares `inputs: [feature-spec]`. The inputs differ, and that is expected: the code author will **supply each leaf an `object-spec` derived from decomposing the `feature-spec`** (see Action). Relevance is judged against those derived inputs, not against the raw `feature-spec`. Because every derived object spec is an `object-spec`, both leaves' inputs are satisfied whenever the orchestrator supplies a `feature-spec`.
- The orchestrator has not disabled the sub-skill via configuration.

Per the DO composition contract, the super-skill MUST NOT filter sub-skills by task content. `al-code-author` does not inspect the `feature-spec` to predict which object types it contains and then pick leaves accordingly. Every worklisted leaf is invoked against every derived object spec; each leaf **self-selects** by returning `outcome: "not-applicable"` when a given object spec is not for its object type (`al-api-page-author` returns `not-applicable` for a table spec; `al-table-author` returns `not-applicable` for an API-page spec), exactly as review leaves signal non-applicability with `not-applicable` / `no-knowledge`. There is no object-type dispatch in the super-skill.

Sub-skills that fail either check are not invoked and are recorded in `skipped-sub-skills`:

- `reason: "configuration"` when the orchestrator disabled the sub-skill.
- `reason: "not-applicable"` when the derived object specs cannot satisfy the sub-skill's declared `inputs`.

## Worklist

The worklist is the list of sub-skills judged relevant by the previous step - the leaves whose (derived) `inputs` will be satisfied and that are not disabled by configuration. Every sub-skill in the worklist is invoked in the Action step, once per derived object spec. Because both leaves accept an `object-spec` and the code author derives object specs from the `feature-spec`, both are on the worklist whenever a `feature-spec` is supplied and neither is disabled by configuration.

## Action

### Execution discipline (mandatory)

The Action step is a sequence of **discrete iterations**, not one combined generation. Decompose first, then treat each (object spec x sub-skill) invocation as its own pass: read the sub-skill's instructions, apply its Source -> Relevance -> Worklist -> Action steps to that one derived `object-spec`, and produce that invocation's complete `code-artifact` report before moving on. Do not collapse invocations into one shared reasoning step; each leaf has a distinct knowledge subset and generation procedure. The output schema accommodates this - `sub-results` carries one entry per invocation.

### 1. Decompose the feature-spec into an object graph

From the `feature-spec`, build a typed, cross-referenced **object graph**:

- **Enumerate** the objects the feature requires and assign each a type (table, API page, ...).
- **Allocate object IDs**: reserve a contiguous, non-colliding block for the enumerated objects. When the spec supplies no ID range, emit clearly-labeled placeholder IDs with a `TODO` and record the missing range in `open-questions`.
- **Apply the mandatory object-name affix** to every new object name. When the spec supplies no registered affix, treat it as a placeholder and record it in `open-questions` (the affix is required before AppSource submission).
- **Resolve cross-object references** up front so the leaves generate against a consistent graph: the API page's `SourceTable` is the authored master table; the fields the API page exposes are a subset of the master table's fields; the setup table's number-series field feeds the master table's `OnInsert`.

### 2. Fan out each object spec to the worklisted leaves

For each object spec in the graph, run the per-object fan-out - the same discipline the single-object composition uses, now looped over the graph:

1. Invoke every worklisted leaf with that one derived `object-spec`.
2. The matching leaf authors the object; the others return `outcome: "not-applicable"`. Accept the redundant `not-applicable` invocations - that is the cost of contract-clean self-selection (the super-skill never dispatches by object type), the single-object case simply looped over the graph.

### 3. Collect reports and roll up artifacts

- Capture each invocation's complete `code-artifact` report verbatim and append it to `sub-results` (one entry per invocation, including the redundant `not-applicable` ones).
- If an invocation's `outcome` is `failed`, do not copy its artifacts into the top-level `artifacts[]` or count them in `summary.counts`; its report still stays in `sub-results` for traceability.
- Otherwise append each entry from the invocation's `artifacts[]` to the super-skill's top-level `artifacts[]`. A `not-applicable` / `no-knowledge` invocation contributes zero artifacts. Artifacts are rolled up verbatim; the `code-artifact` schema has no per-artifact `from-sub-skill` field, and leaf attribution is preserved through `sub-results`.
- Aggregate `open-questions` across invocations into the top-level `open-questions` (deduplicating identical entries).

### 4. Reconcile cross-object references

After the leaves have produced their artifacts, **verify the cross-object references line up** across the produced code: the API page's `SourceTable` names the authored master table; every field the API page exposes exists on that master table; the setup table's number-series field is the one the master's `OnInsert` reads. Record any residual mismatch or ambiguity in `open-questions` rather than silently papering over it.

### 5. Enumerate feature objects no current leaf can author

Honest coverage: name the objects the feature needs that **no current author leaf produces**, as explicit, clearly-labeled `open-questions` / follow-ups. For a master-data feature these are, at minimum, the master's **List and Card pages**, a **permission set** covering the new tables, and an **install/upgrade codeunit** that seeds the setup singleton row. Listing them defines the next author leaves and keeps the emitted feature honestly partial rather than pretending completeness.

### Summary and rollup

`summary.counts.artifacts` and `summary.counts.objects` are the sums across invocations whose `outcome` is not `failed`; `summary.coverage.knowledge-applied` is the sum of the invocations' `knowledge-applied` counts. `suppressed[]` at the super-skill level remains empty - knowledge-file suppression is reported by each leaf within its own entry in `sub-results`.

Derive `outcome` using the DO *Outcome rollup* rules over the multiset S of all invocations' outcomes. For the Membership feature below, S = {`al-table-author`: `completed`, `al-api-page-author`: `not-applicable`, `al-api-page-author`: `completed`, `al-table-author`: `not-applicable`} rolls up to `completed`. When every invocation returns `not-applicable` (a feature whose objects neither leaf authors), the roll-up is `not-applicable`. `outcome-reason` is required for `partial` and `failed` and SHOULD summarize per-invocation state.

## Output

Output conforms to the DO `code-artifact` output contract, extended with `sub-results` and `skipped-sub-skills`.

A populated example - a `feature-spec` for a **Membership** feature. The code author decomposes it into two object specs: a `Membership Member` master table and a `Membership Member` API page bound to it. It reserves the contiguous ID block 50100-50102, feeds each object spec to both leaves, and reconciles the API page's `SourceTable` to the authored master. `al-table-author` authors the master and its setup table (2 artifacts); `al-api-page-author` authors the API page (1 artifact); each leaf returns `not-applicable` for the other's object spec. The three artifacts roll up under `completed`, and the List/Card pages, permission set, and install codeunit the feature still needs - which no current leaf authors - are listed as `open-questions`:

```json
{
  "skill": {
    "id": "al-code-author",
    "version": 1
  },
  "outcome": "completed",
  "summary": {
    "counts": {
      "artifacts": 3,
      "objects": 3
    },
    "coverage": {
      "knowledge-applied": 7
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
    },
    {
      "id": "membership-member-api-page",
      "object-type": "page",
      "object-name": "Membership Member Entity",
      "path": "src/Membership/MembershipMemberEntity.Page.al",
      "content": "page 50102 \"Membership Member Entity\"\n{\n    // TODO: object ID 50102 is a placeholder; replace with an ID from your assigned range.\n    PageType = API;\n    Caption = 'membershipMember';\n    APIPublisher = 'PLACEHOLDER-publisher';\n    APIGroup = 'PLACEHOLDER-group';\n    APIVersion = 'v1.0';\n    EntityName = 'membershipMember';\n    EntitySetName = 'membershipMembers';\n    ODataKeyFields = SystemId;\n    SourceTable = \"Membership Member\";\n    DelayedInsert = true;\n\n    layout\n    {\n        area(content)\n        {\n            repeater(records)\n            {\n                field(id; Rec.SystemId)\n                {\n                    Caption = 'id';\n                    Editable = false;\n                }\n                field(number; Rec.\"No.\")\n                {\n                    Caption = 'number';\n                }\n                field(displayName; Rec.Name)\n                {\n                    Caption = 'displayName';\n                }\n            }\n        }\n    }\n}\n",
      "references": [
        {
          "path": "microsoft/knowledge/web-services/set-required-api-page-properties.md"
        },
        {
          "path": "microsoft/knowledge/web-services/expose-systemid-as-the-api-key.md"
        }
      ],
      "confidence": "medium",
      "notes": "Object ID 50102, APIPublisher, and APIGroup are placeholders the spec did not supply; replace them before deploying. SourceTable is reconciled to the authored Membership Member master table, and the exposed No. and Name fields are a subset of that table's fields."
    }
  ],
  "open-questions": [
    "Which contiguous object-ID block should the feature use? Placeholders 50100 (Membership Member), 50101 (Membership Setup), and 50102 (Membership Member API page) were emitted; replace them with IDs from your assigned range.",
    "What is the publisher's registered object-name affix? It must be applied to all new object names (Membership Member, Membership Setup, Membership Member Entity) before AppSource submission; names are emitted without it as a placeholder.",
    "The feature needs a Membership Member List page and a Membership Member Card page to surface the master in the client - no current author leaf generates List/Card pages; scaffold as a follow-up.",
    "The feature needs a permission set covering the new Membership Member and Membership Setup tables - no current author leaf generates permission sets; scaffold as a follow-up.",
    "The feature needs an install/upgrade codeunit to seed the Membership Setup singleton row - no current author leaf generates install codeunits; scaffold as a follow-up.",
    "What APIPublisher and APIGroup identify the Membership Member API endpoint?",
    "Is Name the complete business field set for Membership Member, or should additional fields be modeled?"
  ],
  "suppressed": [],
  "sub-results": [
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
    },
    {
      "skill": {
        "id": "al-api-page-author",
        "version": 1
      },
      "outcome": "not-applicable",
      "outcome-reason": "The derived object-spec requests a master table, not a PageType = API page; al-api-page-author authors only API pages.",
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
        "id": "al-api-page-author",
        "version": 1
      },
      "outcome": "completed",
      "summary": {
        "counts": {
          "artifacts": 1,
          "objects": 1
        },
        "coverage": {
          "knowledge-applied": 2
        }
      },
      "artifacts": [
        {
          "id": "membership-member-api-page",
          "object-type": "page",
          "object-name": "Membership Member Entity",
          "path": "src/Membership/MembershipMemberEntity.Page.al",
          "content": "page 50102 \"Membership Member Entity\"\n{\n    // TODO: object ID 50102 is a placeholder; replace with an ID from your assigned range.\n    PageType = API;\n    Caption = 'membershipMember';\n    APIPublisher = 'PLACEHOLDER-publisher';\n    APIGroup = 'PLACEHOLDER-group';\n    APIVersion = 'v1.0';\n    EntityName = 'membershipMember';\n    EntitySetName = 'membershipMembers';\n    ODataKeyFields = SystemId;\n    SourceTable = \"Membership Member\";\n    DelayedInsert = true;\n\n    layout\n    {\n        area(content)\n        {\n            repeater(records)\n            {\n                field(id; Rec.SystemId)\n                {\n                    Caption = 'id';\n                    Editable = false;\n                }\n                field(number; Rec.\"No.\")\n                {\n                    Caption = 'number';\n                }\n                field(displayName; Rec.Name)\n                {\n                    Caption = 'displayName';\n                }\n            }\n        }\n    }\n}\n",
          "references": [
            {
              "path": "microsoft/knowledge/web-services/set-required-api-page-properties.md"
            },
            {
              "path": "microsoft/knowledge/web-services/expose-systemid-as-the-api-key.md"
            }
          ],
          "confidence": "medium",
          "notes": "Object ID 50102, APIPublisher, and APIGroup are placeholders the spec did not supply; replace them before deploying. SourceTable is reconciled to the authored Membership Member master table, and the exposed No. and Name fields are a subset of that table's fields."
        }
      ],
      "open-questions": [
        "Which object ID (from the consuming extension's assigned range) should the Membership Member API page use?",
        "What APIPublisher and APIGroup identify this endpoint?",
        "Is the No. + Name field set the complete API surface for Membership Member?"
      ],
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
      "outcome-reason": "The derived object-spec requests a PageType = API page, not a master or setup table; al-table-author authors only tables.",
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

The all-not-applicable case - a `feature-spec` whose objects neither leaf authors (for example, a reporting-only feature that decomposes to a single report object spec) - invokes both leaves against that spec, both return `not-applicable`, and the feature rolls up to `not-applicable` with no artifacts:

```json
{
  "skill": {
    "id": "al-code-author",
    "version": 1
  },
  "outcome": "not-applicable",
  "outcome-reason": "The feature-spec decomposes only to objects no author leaf handles: al-api-page-author authors API pages and al-table-author authors tables; the feature's single report object is neither.",
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
  "open-questions": [
    "The feature's reporting object (a Report object) is authored by no current leaf - a report author leaf is a follow-up before this feature can be generated."
  ],
  "suppressed": [],
  "sub-results": [
    {
      "skill": {
        "id": "al-api-page-author",
        "version": 1
      },
      "outcome": "not-applicable",
      "outcome-reason": "The derived object-spec requests a report, not a PageType = API page.",
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
      "outcome-reason": "The derived object-spec requests a report, not a master or setup table.",
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
