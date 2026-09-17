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
sub-skills and is composed by `al-code-review`. It accepts diffs, individual
files, and complete app folders; for a folder, inspect every relevant AL file,
not a representative sample. A folder supplies no historical baseline.

## Source

Apply the source-surface gate in Relevance before retrieving knowledge. If the
gate passes, use READ's **Bounded retrieval for review skills** workflow with
`-Domain scm` and `-Technologies @('al')`. Consume every catalog page across
enabled layers, preserving exact paths, complete keywords, applicability, and
unknown dimensions. Select articles using catalog metadata only; never use an
index row as the basis for a finding.

Entry owns index preparation. Do not rebuild the index in this leaf. When a
helper or prepared index is unavailable or invalid, follow READ's explicit
path-discovery and bounded native-read fallback through EOF. A retrieval
failure is not an empty or clean review.

## Relevance

First inspect the supplied scope for an SCM source surface: a changed
procedure, trigger, subscriber, or bound action that writes or posts inventory,
cost, application, reservation, tracking, warehouse, transfer, or planning
state, or calculates availability for a supply/demand decision. Resolve record
and codeunit declarations, source tables, event publishers, and nearby calls
within the supplied scope. Do not infer object identity from a variable name.

An `Item` reference, a field caption, an unrelated ledger read, an object name
containing "warehouse", or a broad `ApplicationArea` alone does not pass this
gate. Comments and display strings are not execution evidence. When no source
surface passes, return `not-applicable` with zero coverage and no article-body
reads. In a mixed diff, worklist only the relevant procedures and their visible
supporting context, not every AL file in the app. Unknown application areas do
not by themselves exclude codeunits or subscribers.

For candidates, apply READ's frontmatter matching semantics:

- `bc-version`: the target BC major version from application dependency or
  host context, not the extension's own version; otherwise unknown.
- `technologies`: AL.
- `countries`: the known target localization or host context; otherwise
  unknown, not a guess based on the developer's language.
- `application-area`: the actual known task/object areas, not a substituted
  `[all]`. Use explicit inventory, warehousing, assembly, manufacturing, or
  supply-chain context to narrow the relevant source, not as proof of a defect.

Discard nonmatching articles. Retain conditionally applicable articles only
when configuration permits; cap their findings at `medium` confidence and
name every unknown dimension in the message.

## Worklist

Extract deterministic tokens from the gated source: resolved object/type
names, quoted field names, methods, enum members, and called publishers.
Lowercase invariantly, replace punctuation and whitespace runs with one hyphen,
and trim leading/trailing hyphens. Thus `"Item Ledger Entry"` becomes
`item-ledger-entry`, `"Qty. (Base)"` becomes `qty-base`, and `RunWithCheck`
becomes `runwithcheck`. Apply the same normalization to catalog keywords.
Match whole normalized tokens/phrases, not substrings such as `item` in an
unrelated identifier. Do not manufacture synonyms that are not supported by
the changed source or the targeted cues.

Select a catalog row only when a keyword intersects these tokens, or its
path/title/description identifies the same gated source surface **and
operation**. Object declarations establish context; field assignments, calls,
and decision logic establish the operation to evaluate. A shared table name
does not select every rule using that table.

Use these targeted candidate-selection cues, resolving each slug to its
actual enabled catalog paths. They select articles to read, not findings to
emit; all platform reasoning and exceptions remain in those articles.

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
| `"Requisition Line"` action-message execution, accepted planning suggestions, `"Req. Wksh.-Make Order"`, `CarryOutBatchAction`, or linked supply creation/change plus requisition-line deletion | `carry-out-requisition-actions-through-the-standard-workflow` |

Do not select a cue solely from a caption, comment, or unrelated declaration.
Use the same gates for clean supported calls so their article exclusions are
evaluated, not just suspicious writes. Applicability is never an anti-pattern.

Resolve normative conflicts per READ after reading the selected complete
articles. Keep enabled-layer candidates additive unless guidance actually
contradicts; do not deduplicate merely by filename. Record losing candidates
in `suppressed` with `layer-precedence`, and configuration-hidden candidates
with `configuration`. Noncandidates are not suppressions.

Order exact worklisted paths ordinally and retrieve complete bodies in stable
chunks of at most eight, following every continuation within each chunk.
Never turn the chunk size into a top-eight cutoff. Read samples only when
needed, via their exact READ links and bounded sample retrieval.

## Action

Evaluate the visible source against each opened article's normative Best
Practice and Anti Pattern, including its scope and exclusions. Establish the
record's persistence, caller contract, document type/state, and affected
operation from evidence before reporting. Consult the article for treatment
of temporary buffers, supported publisher parameters, managed posting paths,
and legitimate read-only calculations; the skill itself defines no BC rule.
Do not infer missing work in an unseen caller or report every use of a routed
API. A supported alternative is not a defect.

Emit only a concrete violation with its business consequence and supported
remediation. Use `major` for a demonstrated material SCM defect, `minor` for
a narrower best-practice conflict, and `blocker` only if the opened article
establishes a violated platform-level guarantee. Relevance alone produces no
finding. Deduplicate overlapping findings that prescribe the same correction;
prefer the article that owns the specific operation and retain any other
applicable article as a supporting reference.

Copy `findings[].id` verbatim from the primary article's exact catalog path;
it must equal `references[0].path`. Cite only complete articles actually read.
Use `high` confidence only for unambiguous source evidence with known
applicability, `medium` for justified inference or conditional applicability.
Never label a guessed API signature or missing workflow context high confidence.

Agent findings are optional and strictly SCM-scoped. Follow DO's precision
bar: concrete, material defects only, with `references: []`, an `agent:` id,
severity at most `minor`, and confidence at most `medium`. Omit generic AL,
style, performance, privacy, and unrelated technical findings owned by other
leaves. Do not invent a finding to compensate for an empty worklist.

For an unambiguous local fix, supply literal replacement AL in
`suggested-code`, with a location range covering exactly those lines. Do not
replace an entire business workflow with a sample call that omits the
caller's setup, filters, source identity, or validations. When a mechanical-
looking fix cannot be expressed safely, give `suggested-code-omission-reason`.

Outcomes follow DO: `completed` after evaluating the complete worklist,
including a clean result; `not-applicable` when the source gate fails;
`no-knowledge` when no applicable corpus survives filtering/configuration;
`partial` when only part of the worklist was evaluated; `failed` when no
reliable result can be produced. A source match with no matching article is
`completed` with an empty worklist, not a claimed evaluation of every SCM
concern. Explain partial/failed results and report accurate coverage.

## Output

Return one strict JSON findings-report per DO and
`schemas/findings-report.schema.json`, with no surrounding prose. Every
finding, including an agent finding, must have
`domain: "Supply Chain Management"`. Do not set `from-sub-skill` in a leaf
report; the coordinator adds it. All locations must identify existing lines
in the supplied source, and any range must start at `location.line`.

A knowledge-backed finding with an exact article id:

```json
{
  "skill": { "id": "al-scm-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/scm/cancel-reservations-through-reservation-management.md",
      "severity": "major",
      "message": "This cancellation deletes only the negative reservation row. Use Reservation Engine Mgt. cancellation so counterpart and surviving tracking are handled by the owning workflow.",
      "location": { "file": "src/CancelReservation.Codeunit.al", "line": 16 },
      "references": [
        { "path": "microsoft/knowledge/scm/cancel-reservations-through-reservation-management.md" }
      ],
      "confidence": "high",
      "domain": "Supply Chain Management",
      "suggested-code-omission-reason": "The replacement also requires a codeunit declaration outside the reported line."
    }
  ],
  "suppressed": []
}
```

An unrelated AL change, excluded before article retrieval:

```json
{
  "skill": { "id": "al-scm-review", "version": 1 },
  "outcome": "not-applicable",
  "outcome-reason": "The supplied AL changes contain no SCM posting, state mutation, or supply/demand availability surface.",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
