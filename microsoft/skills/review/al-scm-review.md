---
kind: action-skill
id: al-scm-review
version: 1
title: AL Supply Chain Management review
description: Reviews SCM inventory costing, item application, reservations, order tracking, item tracking, warehouse, transfer, and planning workflows in AL.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL Supply Chain Management review

Reviews AL source against the `scm` knowledge domain. This leaf invokes no
sub-skills and is composed by `al-code-review`. For a folder, inspect every
relevant AL file; a folder supplies no historical baseline.

## Source

Apply Relevance's source gate before retrieval. For a relevant scope, use READ's
**Bounded retrieval for review skills** with `-Domain scm` and
`-Technologies @('al')`. Consume every catalog page across enabled layers,
preserving exact paths and applicability. Select from metadata, then read only
worklisted complete articles. Entry owns index preparation; the leaf does not
rebuild. Unavailable/invalid helpers or indexes use READ's bounded native-read
fallback, never a success-shaped empty result.

## Relevance

Resolve changed record/codeunit types, source tables, publishers and calls.
Gate on code that mutates or posts inventory, application, reservation,
tracking, warehouse, transfer or planning state, or makes a supply/demand
availability decision. Stock displays and other read-only queries without
that decision do not pass the gate. Names, comments, captions, an `Item`
reference or a broad `ApplicationArea` alone are not signals.
If no SCM surface remains, return `not-applicable` with zero coverage
and no article-body retrieval; in mixed diffs, retain only relevant procedures
and their visible supporting context.

SCM owns `"Item Ledger Entry"`, `"Value Entry"`, `"Capacity Ledger Entry"`,
`"Warehouse Entry"` and inventory posting/application records. Pure `"G/L Entry"`,
`"Cust. Ledger Entry"`, `"Vendor Ledger Entry"`, `"Detailed Cust. Ledg. Entry"`,
`"Detailed Vendor Ledg. Entry"`, `"VAT Entry"` and financial-only posting
mutations belong to Finance. They remain outside SCM even if Finance is absent
or disabled; do not reclaim them as SCM agent findings. Ownership is not a
claim that every owned surface already has a dedicated article.

Apply READ's frontmatter filters using the target BC major version from
application dependency/host context (not the extension version), AL, known
localization and actual task/object application areas. Omitted context stays
unknown, not `[all]`; unknown areas alone do not exclude codeunits/subscribers.
Retain conditional articles only when configured, cap their findings at
`medium`, and name every unknown dimension.

## Worklist

Extract resolved object/type names, quoted fields, methods, enum members and
publishers. Normalize these and catalog keywords by lowercasing invariantly,
replacing punctuation/whitespace runs with one hyphen and trimming hyphens:
`"Item Ledger Entry"` becomes `item-ledger-entry`; `RunWithCheck` becomes
`runwithcheck`. Match whole tokens/phrases, not identifier substrings.

Select matching keywords or catalog topics only for the same source surface
**and operation**. The following cues resolve slugs to actual enabled catalog
paths; they select articles, not findings. Facts and exceptions stay in articles.

| Changed source surface and operation | Article slug |
| --- | --- |
| `"Item Ledger Entry"`/`"Value Entry"` transaction writes, or a standalone item-journal quantity/value posting entry point | `post-item-ledger-changes-through-item-journals` |
| Revaluation `"Item Journal Line"` with `"Inventory Value Per"` or `"Partial Revaluation"`, and its line/batch posting calls | `post-revaluation-through-the-item-journal-batch` |
| `"Item Application Entry"` relationship/quantity mutation, or `UnApply`, `ReApply`, `RedoApplications`, `CostAdjust` in an application-correction flow | `change-item-applications-through-posting-routines` |
| Binding-reservation cancellation: `"Reservation Entry"` status, delete/quantity/source edits, `CancelReservation`, or source reservation-lifecycle calls | `cancel-reservations-through-reservation-management` |
| Tracking source conversion/partial movement: `"Sales Line-Reserve"`, `TransferSaleLineToSalesLine`, `TransferReservEntry`, `CopyItemTracking`, or `"Reservation Entry"`/`"Tracking Specification"` source/quantity writes | `transfer-item-tracking-through-source-reservation-codeunits` |
| Registered warehouse quantity/physical-adjustment synchronization, `"Directed Put-away and Pick"`, `"Adjustment Bin Code"`, `"Warehouse Adjustment"`, or `"Calculate Whse. Adjustment"` and the resulting item-journal posting | `reconcile-warehouse-adjustments-with-the-item-ledger` |
| `"Transfer Header"`/`"Transfer Line"` shipment/receipt completion, transfer posting publishers, in-transit/document-link changes, or item-journal posting presented as transfer-order completion | `post-transfers-through-shipment-and-receipt-codeunits` |
| `Inventory`, `CalcQtyAvailableToPromise`, or stock sums used in a dated supply/demand promise, including changed location/variant/date filters and source-demand context | `use-date-aware-availability-for-promising` |
| Direct assignment to `Quantity`, `"Unit of Measure Code"`, `"Qty. per Unit of Measure"`, or a `(Base)` quantity field on a persisted or posted item journal, sales, purchase, or transfer line, or a line quantity compared with a base-unit inventory value | `derive-base-quantities-through-the-line-unit-of-measure` |
| `"Requisition Line"` action-message execution, accepted planning suggestions, `"Req. Wksh.-Make Order"`, `CarryOutBatchAction`, or linked supply creation/change plus requisition-line deletion | `carry-out-requisition-actions-through-the-standard-workflow` |

Route clean supported calls through the same cues, not just suspicious writes.
Resolve actual normative conflicts per READ, preserving additive layers and
recording `layer-precedence`/`configuration` suppressions, not noncandidates.
Retrieve exact paths in ordinal chunks of at most eight, consume every
continuation, and never impose a top-eight cutoff. Samples use exact READ links.

## Action

Evaluate every opened article's normative facts, scope and exclusions against
visible persistence, caller contract, document state and operation. Emit only
concrete violations with business consequences and supported remediation; a
declaration, valid alternative or unseen caller is not evidence of a defect.

- Use `major` for material SCM defects, `minor` for narrower best-practice
  conflicts, and `blocker` only for an article-established platform guarantee.
  Applicability alone produces no finding. High confidence requires unambiguous
  evidence and known applicability; inference/conditional applicability caps it
  at `medium`.
- Apply DO's single-owner deduplication. Equivalent findings for the same
  inventory-originated posting bypass and correction have one SCM primary
  owner, even when financial records are downstream. Prefer the most specific
  SCM article and retain other applicable references as supporting evidence.
  Distinct independent financial defects remain Finance; do not duplicate them.
- Agent findings stay strictly SCM-scoped under DO's precision bar, with
  `references: []`, an `agent:` id and `minor`/`medium` ceilings. Generic AL and
  other domains' concerns remain outside this leaf.
- Supply literal `suggested-code` only for a complete, local, unambiguous fix,
  not a sample call that omits workflow setup/source identity. Explain omitted
  mechanical-looking fixes with `suggested-code-omission-reason`.

Outcome selection follows DO, including accurate coverage and reasons for
`partial`/`failed`. No surviving applicable corpus is `no-knowledge`; an existing
corpus with no matching operation is `completed` with an empty worklist.

## Output

Output conforms to the DO findings-report contract and shared schema. Every
finding MUST set `domain` to `"Supply Chain Management"`. Knowledge-backed ids
equal the primary opened article's exact catalog path. The coordinator, not
this leaf, sets `from-sub-skill`.
