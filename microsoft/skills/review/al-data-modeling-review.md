---
kind: action-skill
id: al-data-modeling-review
version: 1
title: AL data-modeling review
description: Performs an AL data-modeling review against guidance from BCQuality.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL data-modeling review

Reviews AL source changes against the `data-modeling` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with a `pr-diff`, `file-path`, or `folder-path`. Data-modeling findings are narrow by design — they apply when the review scope contains setup or master tables, their card pages, primary keys, number-series assignment, block enforcement, audit fields, document print/email/Post-and-Send actions, `Navigate` page subscribers, Report Selection registration or dispatch, price-calculation/price-source extensibility, code that reads or writes sales/purchase/service line price and amount fields, `TransferFields`-based posting-cascade field mirroring, `TableRelation` field-length design, barcode/report-layout font-provider usage, dimension wiring, journal-based posting-routine structure, or Item Ledger Entry document-number lookups after a combined sales post. The skill returns `not-applicable` when none of those apply.

## Source

Use READ's **Bounded retrieval for review skills** workflow with `-Domain data-modeling`. Consume every catalog page across enabled layers before applying this leaf's Relevance and Worklist; preserve each exact catalog path and open complete bodies only for exact paths selected by the Worklist. If the helper or prepared index is unavailable or invalid, use READ's explicit path-discovery and bounded native-read fallback.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially `* Setup` singleton tables and Card pages, custom master tables, tableextensions that add master-data fields, document or journal lines that reference a master, document pages/codeunits exposing print/email/Post-and-Send actions, codeunits subscribing to `Navigate`, enumextensions to `"Report Selection Usage"`/`"Price Calculation Handler"`/`"Price Source Type"`, and report objects that render barcodes.
- The changed fields, keys, triggers, and procedures, weighted toward `Primary Key`, `No.`, `No. Series`, `Blocked`, `Last Date Modified`, `OnInsert`, `OnModify`, `OnRename`, reference-field `OnValidate`, posting validation, and posting-cascade `TransferFields` calls.
- Tokens extracted from the diff that relate to data modeling (`setup`, `master`, `Primary Key`, `Code[10]`, `Code[20]`, `AutoIncrement`, `SystemId`, `No.`, `No. Series`, `NoSeriesManagement`, `Codeunit "No. Series"`, `GetNextNo`, `IsManual`, `TestManual`, `Blocked`, `TestField`, `Last Date Modified`, `Today`, `WorkDate`, `InsertAllowed`, `DeleteAllowed`, `PageType = Card`, `OnOpenPage`, `GetRecordOnce`, `OnInsert`, `OnModify`, `OnRename`, `InitRecord`, `Round`, `Precision`, `Direction`, `TableRelation`, `ValidateTableRelation`, `TestTableRelation`, `Text[`, `tableextension`, `enumextension`, `Media`, `MediaSet`, `Item`, `Count`, `TransferFields`, `Navigate`, `OnAfterFindRecords`, `OnBeforeShowRecords`, `Report Selections`, `Report Selection Usage`, `InsertRecord`, `Document Sending Profile`, `PrintForCust`, `PrintWithDialogForCust`, `PrintWithDialogForVend`, `SendEmailToCust`, `SendEmailToVendor`, `Report.RunModal`, `Report.Run`, `Price Calculation Handler`, `Price Calculation`, `OnFindSupportedSetup`, `Price Calculation Setup`, `Price Source Type`, `PriceSourceList`, `OnAfterAddSources`, `UpdateUnitPrice`, `PlanPriceCalcByField`, `UpdateUnitPriceByField`, `Prices Including VAT`, `Unit Price`, `Direct Unit Cost`, `Line Amount`, `Prepmt. Line Amount`, `Amount Including VAT`, `CalculateOutstandingAmountExclTax`, `Barcode Font Provider`, `Barcode Font Provider 2D`, `EncodeFont`, `ValidateInput`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone. When the diff contains no data-modeling changes by any of the above signals, return `outcome: "not-applicable"` without evaluating files.

The following targeted checks cover every current `data-modeling` article. Treat each as a candidate-selection cue: when the signal appears in changed code, add the named article to the worklist and evaluate it in Action.

- A `* Setup` table or its page changes singleton structure, uses a nonblank or generated key, permits insert/delete, uses a List page, or does not ensure the blank-keyed row exists — `setup-table-is-a-singleton`.
- A new field is typed `Media`, `MediaSet`, or `BLOB` and the field's caption/name suggests a picture or image — `pictures-must-use-media-not-blob`.
- Code outside a test codeunit or a demo-data generator calls `WorkDate(NewDate)` (the assignment form, not a bare `WorkDate()` read) as part of logic whose purpose is unrelated to the work date itself — `code-must-not-change-workdate`. A test deliberately setting a date context, or a demo-data routine that saves, sets, and restores the work date to backdate the data it creates, is not this anti-pattern.
- A new or extended table's name, fields, or usage positively establish it as one of Business Central's nine business-record types — a name ending `Ledger Entry`/`Register`/`Journal Line`/`Header`/`Line`/`Setup`, an auto-generated `Entry No.`/`No.` key posted from elsewhere, a `Template Name`+`Batch Name`+`Line No.` key, or a singleton `Primary Key` field — `table-design-must-match-bc-table-type-conventions`. Do not worklist it from a bare `keys` block or primary-key declaration alone: a temporary/buffer table, a work queue, a log, a cross-reference/mapping table, or a process-local staging table is not one of the nine types and is out of this rule's scope entirely, not an unresolved case.
- Code reads `Item Ledger Entry."Document No."` (or `"Last Shipping No."`/`"Last Posting No."`) after a combined Ship+Invoice **sales** post — `item-ledger-entry-document-no-follows-last-shipping-no`. This is a sales-specific rule: purchase combined posting is Receive+Invoice and uses receiving fields such as `"Last Receiving No."`, not the shipment/document-number behavior this article describes. Do not worklist it from purchase posting code.
- A custom master table changes its primary key, `No.`/`No. Series` fields, or `OnInsert` without assigning a blank `No.` from setup through a number series — `master-table-no-from-number-series-in-oninsert`.
- BC v22 or later code introduces or retains `NoSeriesManagement`, `InitSeries`, `SelectSeries`, or `SetSeries`, or number assignment/manual-entry checks do not use codeunit `"No. Series"` methods such as `GetNextNo`, `IsManual`, or `TestManual` — `use-no-series-codeunit-not-noseriesmanagement`.
- A master gains or changes `Blocked`, or a document line, journal line, reference-field `OnValidate`, or posting routine uses that master without `TestField(Blocked, false)` at the point of use; also cue when the check is placed only in the master's own triggers — `check-blocked-in-referencing-code-not-in-master`.
- A master table adds or changes `Last Date Modified`, `OnModify`, or `OnRename`, but the non-editable field is not assigned `Today()` in both triggers — `set-last-date-modified-in-onmodify-and-onrename`.
- A `tableextension` appends a conditional `TableRelation` as if it overrides an earlier unconditional relation, or relation branches are otherwise designed without accounting for additive top-down evaluation — `table-relation-extensions-are-additive-and-top-down`.
- A field declares a `TableRelation` (or a `tableextension` `modify` adds a relation branch) and the field's declared `Code`/`Text` length is shorter than the related field, or, when any relation on the field is unconditional, differs from it — `tablerelation-field-length-must-match-related-field`. Read the related field's declared length from its table definition rather than assuming one. A field shorter than the related field is a finding in all cases, including when it sets `ValidateTableRelation = false` or `TestTableRelation = false`. Do not flag a field for being longer than its related field when its relations are all conditional, or when it sets `ValidateTableRelation = false` or `TestTableRelation = false` (filter/totaling fields).
- A `Media` or `MediaSet` field is assigned directly between different table types or different field IDs instead of registering each shared item with `MediaSet.Insert` — `share-mediaset-items-with-insert-not-field-assignment`.
- A custom document header assigns defaults outside an `InitRecord` boundary, calls `InitRecord` before assigning its number, or places UI-independent defaults only in a page trigger — `initialize-document-defaults-in-initrecord`.
- Directed `Round` calls use `'<'` as mathematical floor or `'>'` as mathematical ceiling, especially where negative amounts are possible — `round-direction-symbols-use-magnitude`.
- A codeunit dispatches a document by calling `Report.Run`/`Report.RunModal` with a hardcoded report ID, or by building its own email directly, instead of going through the `Report Selections` usage for that document — `custom-document-dispatch-must-not-bypass-report-selections`. Either bypass is a finding on its own; both need not be present. Scope this to customer/vendor-facing documents that have (or should have) a `Report Selection Usage` — a hardcoded `Report.Run` of an ordinary list/analysis report is not this anti-pattern. A call that already goes through `Report Selections`' own Print/Email procedures is not this anti-pattern.
- A document's own interactive Print/Email action routes through `Document Sending Profile` (`DocumentSendingProfile.Send`/`SendVendor`) instead of calling `Report Selections` (`PrintForCust`/`PrintWithDialogForCust`/`SendEmailToCust`/`PrintWithDialogForVend`/`SendEmailToVendor`) directly — `document-print-and-email-actions-call-report-selections-directly`. Do not flag `Document Sending Profile` usage that is genuinely part of a combined Post-and-Send action.
- An `EventSubscriber` is added for `Navigate::OnAfterFindRecords` (registering a custom table in Find Entries) without a matching `Navigate::OnBeforeShowRecords` subscriber for the same table, or vice versa — `extend-find-entries-navigate-for-new-document-types`. Both subscribers must be added together for the same table.
- An `enumextension` extends `"Report Selection Usage"` and registers a report via `ReportSelections.InsertRecord`, without subscribing to the matching *single* counterparty's full triad — the filter event (`OnAfterFilterCustomerUsageReportSelections` on `page 9657` for a sales usage, `OnAfterFilterVendorUsageReportSelections` on `page 9658` for a purchase usage) AND the page-facing usage-enum map/validate events (`enumextension` on `"Custom Report Selection Sales"`/`"Report Selection Usage Vendor"` plus the matching map/validate subscribers) — `extend-report-selection-usage-for-new-document-types`. Requiring or wiring *both* counterparties by default for a one-sided document is also the anti-pattern (`ReportSelectionHandlerCZZ` partitions strictly by counterparty); only a genuinely two-sided usage (as `ReportSelectionHandlerCZC` demonstrates for Compensation) needs both.
- The same field number is added as a new field on two or more tables connected by a `TransferFields` call in a posting cascade (e.g. a header table and the posted-document table `SalesPost.Codeunit.al`/`PurchPost.Codeunit.al` transfer into), with a different data type or length on one side — `transferfields-mirrored-fields-must-match-type-and-length`. A field defined on only one side of the cascade is out of scope; this cues only on a field deliberately mirrored across the cascade with a type or length mismatch.
- An `enumextension` extends `"Price Calculation Handler"` and implements the `Price Calculation` interface, without a matching `OnFindSupportedSetup` subscriber inserting a `Price Calculation Setup` record naming that implementation as the `Implementation` for a `Method`/`Type`/`Asset Type` — `activate-new-price-calculation-handler-via-onfindsupportedsetup`. `Default := true` is only required on that row when it is meant as the fallback for its `Method`/`Type`/`Asset Type` combination; a row meant to be selected only through an explicit, specific `"Dtld. Price Calculation Setup"` row does not need it, so do not flag a missing `Default := true` by itself — flag the missing setup row/subscriber entirely.
- An `enumextension` extends `"Price Source Type"` with a new value intended for a sales, purchase, or job price list, without extending the matching document subset enum (`"Sales Price Source Type"`, `"Purchase Price Source Type"`, `"Job Price Source Type"`) with a value at the same numeric ID — `extend-price-source-type-must-sync-document-subset-enum`.
- A codeunit subscribes to `"Sales Line - Price"`'s `OnAfterAddSources` to register a custom field as a price source via `PriceSourceList.Add`, but that field has no `OnValidate` (or matching `OnAfterValidate`) that triggers recalculation — either `SalesLine.UpdateUnitPrice(<field no.>)`, or the explicit `SalesLine.PlanPriceCalcByField(<field no.>)` followed by `SalesLine.UpdateUnitPriceByField(<same field no.>)`. A bare `UpdateUnitPriceByField` without a preceding `PlanPriceCalcByField` for the same field number does not count as recalculation (it exits without recalculating) — `new-price-source-must-add-candidate-and-trigger-recalculation`.
- Code reads `Unit Price`, `Direct Unit Cost`, `Line Amount`, `Line Discount Amount`, `Inv. Discount Amount`, `Prepmt. Line Amount`, `Prepmt. Amt. Inv.`, `Prepmt Amt to Deduct`, `Prepmt Amt Deducted`, or the result of `CalculateOutstandingAmountExclTax` of a `Sales Line`/`Purchase Line`/`Service Line` as a known net or gross value (a net/gross total, a VAT computation, a comparison with `Amount` or `Item."Unit Price"`/`"Last Direct Cost"`, an export), or writes a source price of known basis into `Unit Price`/`Direct Unit Cost`, without reading the document header's `Prices Including VAT` — `document-line-prices-follow-prices-including-vat`. Reads of fixed-basis fields (`Amount`, `Amount Including VAT`, `Prepayment Amount`, `Prepmt. Amt. Incl. VAT`), combinations of header-dependent fields with each other, prices returned by the standard price calculation, and copies between lines of the same document are not this anti-pattern.
- A report hand-constructs a barcode string only where a concrete, independently provable defect is visible: the source value can contain characters outside the symbology's character set and is never validated, a checksum the symbology/setup requires is never applied, or there is concrete evidence of an incompatible font binding. Do not flag manual start/stop delimiters by themselves — `*value*` is a documented, valid Code 39 form for IDAutomation fonts (IDAutomation also accepts parentheses), so delimiter choice alone is never a finding. Also flag module use that does not match the interface: a 1D `"Barcode Font Provider"` path must call both `ValidateInput` and `EncodeFont`; a 2D `"Barcode Font Provider 2D"` path calls `EncodeFont` only (the 2D interface has no `ValidateInput`, so its absence there is not a finding). Separately, flag an otherwise correctly encoded barcode whose report layout names an evaluation/demo font instead of the purchased production font name — `report-barcodes-must-use-barcode-module-and-production-font-name`.
- A new field is typed `Code`/`Text` and its `OnValidate` calls `DimensionManagement`/`DimMgt`, or a table adds Shortcut Dimension fields, a `Dimension Set ID` field, or `AddDimSource`/`GetDefaultDimID` — `dimension-management-wiring`. A master table calling `SaveDefaultDim` and a document/journal table computing its own `Dimension Set ID` are two different valid shapes; do not flag a master table for lacking a `Dimension Set ID` field or a document for lacking `SaveDefaultDim`.
- A journal-based posting codeunit is added or changed and validation, Journal-table access, ledger writes, and user-interaction (`Confirm`/dialogs) all occur in one procedure or one codeunit, rather than split across `Check Line`/`Post Line`/`Post Batch`-shaped companions — `check-post-line-batch-pattern`. A document posting routine calling `Post Line` directly without a `Post Batch` companion is not this anti-pattern.
- An existing, already-published table's `keys` block adds, removes, or reorders a field in its primary key or any `Clustered = true` key — `do-not-change-primary-key`. A new table defining its own key for the first time is not this anti-pattern; requires repository/publication context to know the table has already shipped.
- Code reads a setup/configuration-table field inside a branch that has already decided the value is required, and blank/zero is handled with a fallback to a default rather than `TestField`/an equivalent guard — `testfield-required-setup-field`. A read that is genuinely optional in that branch, or one already guarded by `TestField`, is not this anti-pattern.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable data-modeling knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable data-modeling knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the model can create ambiguous setup state, incompatible business identifiers, or silently stale synchronization data; otherwise the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- Applicability alone is not a finding. Emit `info` only for a concrete, non-actionable observation the article explicitly defines; otherwise emit nothing when no violation is present.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (object type, field, key, trigger, or API name).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a data-modeling defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material data-modeling defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly data modeling; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: add `InsertAllowed = false` or `DeleteAllowed = false`; replace `WorkDate()` with `Today()`; add the same audit-field assignment to `OnRename`; or replace an obsolete number-series codeunit declaration). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable data-modeling knowledge survived filtering.
- `not-applicable` — the diff touches no setup/master table, page, key, numbering, block-check, or audit-field surface, and no document print/email/Post-and-Send action, `Navigate` subscriber, Report Selection registration/dispatch, price-calculation/price-source extensibility point, sales/purchase/service line price or amount read/write, posting-cascade `TransferFields` mirroring, `TableRelation` field length, barcode/report-font-provider usage, dimension wiring, posting-routine structure, or Item-Ledger-Entry-document-number surface.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. Every finding this skill emits MUST set `findings[].domain` to `"Data Modeling"`. A populated example:

```json
{
  "skill": { "id": "al-data-modeling-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/data-modeling/set-last-date-modified-in-onmodify-and-onrename.md",
      "severity": "major",
      "message": "The table updates Last Date Modified in OnModify but not OnRename, so renaming the primary key leaves the audit date stale and can hide the record from incremental integrations.",
      "location": {
        "file": "src/LoyaltyMember.Table.al",
        "line": 74
      },
      "references": [
        { "path": "microsoft/knowledge/data-modeling/set-last-date-modified-in-onmodify-and-onrename.md" }
      ],
      "confidence": "high",
      "domain": "Data Modeling",
      "suggested-code": "trigger OnRename()\nbegin\n    \"Last Date Modified\" := Today();\nend;"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case produces:

```json
{
  "skill": { "id": "al-data-modeling-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
