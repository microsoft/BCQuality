---
bc-version: [all]
domain: scm
keywords: [item-ledger-entry, value-entry, item-journal-line, item-jnl-post-line, runwithcheck, inventory-posting]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Post item ledger changes through item journals

## Description

An item ledger entry is not an independently insertable stock balance. Posting connects its quantity to item applications, reservations, tracking, and one or more value entries; expected cost, invoicing, revaluation, and later cost adjustment can produce different value entries for the same item entry. Running a table's insert trigger does not run this posting workflow or its configured inventory-to-G/L integration.

## Best Practice

For a prepared standalone item-journal movement, enter through codeunit `"Item Jnl.-Post Line".RunWithCheck`. For a persisted journal batch, use `"Item Jnl.-Post Batch"`; for a sales, purchase, transfer, assembly, or production transaction, retain that workflow's owning document/posting orchestration rather than replacing it with a naked journal call. Let the posting engine create the ledger, value, and application records and perform its checks.

Extend supported posting events and pass validated journal/source data into the owning workflow. Read-only ledger queries, temporary previews, extension-owned metadata fields, and supported publisher parameters consumed by the poster are not independent ledger posting and must not be flagged merely because they assign record fields. A publisher's `var` parameter or `IsHandled` flag is not blanket authorization to recreate quantity/cost state. A change inside the posting engine itself requires tracing that engine's surrounding invariants, not a ban on its own inserts.

Do not require every value entry to point to an item ledger entry: capacity and production WIP have their own supported posting relationships. Assembly and manufacturing posting retain order/component/routing and capacity context; one bare output/consumption call is not full order completion.

The clean sample takes an already prepared positive-adjustment journal line. It is not a substitute for journal preparation, batch revaluation, warehouse reconciliation, or source-document posting.

## Anti Pattern

Report extension code that independently inserts/deletes persistent `"Item Ledger Entry"` or `"Value Entry"` transaction rows, or overwrites posted quantity, remaining quantity, application identity, or cost amounts to implement a receipt, shipment, adjustment, or cost correction. `Insert(true)`, `Modify(true)`, and balanced-looking quantities do not supply the missing posting orchestration.

Require evidence of a persistent transaction mutation and its business purpose; a table declaration or a write to a custom annotation field is insufficient. For a more specific revaluation or application defect, prefer the corresponding SCM article rather than reporting the same correction twice.

## Samples

- [`post-item-ledger-changes-through-item-journals.bad.al`](post-item-ledger-changes-through-item-journals.bad.al)
- [`post-item-ledger-changes-through-item-journals.good.al`](post-item-ledger-changes-through-item-journals.good.al)

## References

- [Inventory posting design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-inventory-posting)
- [Item application design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-application)
- [BaseApp item-journal posting entry point](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostLine.Codeunit.al#L162-L179)
- [Assembly-order posting context](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-assembly-order-posting)
- [Production-order posting context](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-production-order-posting)
