---
kind: action-skill
id: al-finance-review
version: 1
title: AL Finance review
description: Reviews financial journal posting, ledger corrections, applications, VAT handling, and posting-linked dimensions against BCQuality Finance guidance.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL Finance review

Reviews the `finance` knowledge domain. This is a leaf action skill composed by
`al-code-review`; it invokes no other skills. Application-area metadata does
not gate Finance coverage; resolved source records and operations do.

## Source

Apply the source-surface gate in Relevance before retrieving knowledge.
If it passes, use READ's **Bounded retrieval for review skills** workflow with
`-Domain finance`. Consume every catalog page across enabled layers, preserving
each exact path and applicability metadata. Do not select a top-k catalog or
deduplicate by basename. Open complete bodies only for exact Worklist paths,
in stable chunks of at most eight, consuming every continuation. If the helper
or prepared index is unavailable or invalid, use READ's explicit path-discovery
and bounded native-read fallback; a retrieval error is not an empty corpus.

## Relevance

Apply READ's frontmatter matching rules using only known task dimensions.
Use the target application version from `app.json` when available; do not invent
a country or application area from a filename or UI `ApplicationArea` token.
Retain conditional articles only when configured, cap resulting confidence at
`medium`, and name every unknown dimension in the finding.

Inspect the supplied AL scope and its enclosing declarations. Admit only
changed executable behavior involving at least one of these surfaces:

- General-journal construction or posting, journal-batch processing, or an
  event subscriber whose resolved publisher is in the financial posting path.
- Writes or correction/application/reversal calls involving `G/L Entry`,
  `Cust. Ledger Entry`, `Vendor Ledger Entry`, `Detailed Cust. Ledg. Entry`,
  `Detailed Vendor Ledg. Entry`, `VAT Entry`, or financial-posting/G/L-register
  records.
- Dimension transfer or dimension-set mutation connected by visible data flow
  to an existing general journal, financial posting document, or Finance-owned
  ledger record.

Exclude `Item Ledger Entry`, `Value Entry`, Capacity/Warehouse entries,
`Item Application Entry`, and other inventory-posting records owned by SCM.
Do not adopt their findings when the SCM skill is absent or disabled. For one
inventory-originated posting bypass, equivalent findings have one SCM primary
owner; distinct independent financial defects remain Finance. Classify the
operation and actual record, not an inventory/finance word in a module name.

Return `not-applicable` when none is present. Imports, object names, comments,
read-only ledger displays, generic `Amount`/`Date`/`Open` fields, and calls to
`DimensionManagement` without posting-linked context do not establish relevance.
For a diff, retain surrounding variable types, field provenance, event
attributes, and reachable helpers; do not review isolated added lines without
the context needed to classify their record or call.

## Worklist

Match the complete relevant catalog's keywords, titles, and descriptions to
the admitted source surfaces. Add an exact catalog path only when its concern
maps to the changed behavior; generic financial vocabulary is not enough.
The following deterministic cues must select their named articles even if
keyword ranking would otherwise omit them:

- Persistent Finance-owned ledger inserts reached from extension posting
  code — `post-ledger-entries-through-posting-codeunits`.
- Persisted general-journal lines posted through a line-codeunit loop or custom
  aggregate check, with visible template/document/date balancing context —
  `preserve-journal-batch-document-balance`.
- Imported net/tax/gross values mapped into `Gen. Journal Line.Amount`, with
  evidence of the VAT posting mode and posting-setup combination —
  `normal-vat-journal-amount-includes-vat`.
- Persisted original Finance accounting-value changes, deletion of Finance rows, or
  fabricated reversal flags/links — `do-not-modify-or-delete-posted-ledger-entries`.
- Customer/vendor settlement/reopening code writing `Open`, closure fields,
  detailed customer/vendor application amounts, or unapplication flags —
  `apply-ledger-entries-through-application-codeunits`.
- A due-date change persisted on an existing customer/vendor ledger entry —
  `change-ledger-due-dates-through-entry-edit`.
- A `Reversal Entry.ReverseTransaction` or `ReverseRegister` argument with
  visible ledger-entry, transaction, or register provenance —
  `reverse-transactions-by-transaction-number`.
- A complete Finance posting-dimension transfer represented by shortcut/global
  fields or a `Dimension Set ID` assignment —
  `write-dimensions-as-dimension-set-entries`.
- A dimension/value membership change on `Dimension Set Entry`, reached from
  a general-journal/financial-document/Finance-ledger set ID —
  `do-not-edit-shared-dimension-sets`.

These are retrieval cues, not findings. Use the selected articles' normative
exceptions and ownership boundaries to classify standard workflows, temporary
records, operational edits, and extension fields. Do not select a Finance
ledger rule from `*Ledger Entry` or `Insert`/`Modify` alone. Finance does not
own SCM records, generic custom-table/master dimension wiring, number-series
API migration, or general AL validation, locking, transaction, and event-style
advice. Do not add those concerns as Finance agent findings.

Resolve actual normative conflicts across layers per READ and record suppressed
candidates per DO. Keep every remaining exact path in a stable worklist.
Return `no-knowledge` if no applicable Finance knowledge survives filtering or
configuration; return `completed` with no findings when applicable knowledge
exists but no article matches the admitted changes.

## Action

Evaluate every worklist article in full against the changed behavior and its
surrounding control flow. Establish record type, existing versus newly prepared
state, temporariness, fields actually persisted, argument provenance, and the
posting/edit API boundary before emitting a finding. Do not infer a financial
defect from a method name, missing external setup, or unsupported speculation
about callers.

Use the most specific article for the correction: application-state, due-date,
and shared-dimension findings must not also become generic posted-row findings
for the same change. Do not emit an equivalent Finance finding for the
financial-row leg of one SCM-owned inventory posting bypass; evaluate a
distinct financial defect only when its corrective action is independent.
Emit `major` for a demonstrated financial-correctness
violation and reserve `blocker` for directly evidenced destructive corruption
under DO's severity rules. Applicability alone produces no finding.

Set `high` confidence only for established source evidence and known matching
context. Domain-scoped agent findings follow DO's precision bar and remain
capped at `minor`/`medium`; do not broaden this pass into other AL domains.
Provide literal `suggested-code` for complete, local, unambiguous fixes.
Otherwise give `suggested-code-omission-reason`, particularly when selecting
the correct posting workflow requires business context.

Follow DO's acceptance gate and outcome rules. Report `partial` rather than
silently dropping worklist items when a budget is reached, and `failed` for an
unrecoverable retrieval or evaluation error.

## Output

Output conforms to the DO findings-report contract. Every finding this skill
emits MUST set `findings[].domain` to `"Finance"`.
