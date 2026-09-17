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

The posting entry point for a prepared standalone item-journal movement is `"Item Jnl.-Post Line".RunWithCheck`. Persisted journal batches use `"Item Jnl.-Post Batch"`; sales, purchase, transfer, assembly, and production transactions retain their owning document/posting orchestration. Those workflows create the ledger, value, and application records together with their required checks.

Supported posting events enrich validated journal/source data within the owning workflow. Read-only ledger queries, temporary ledger previews, extension-owned metadata fields, and publisher parameters consumed by the poster are not independent ledger posting. A temporary item-journal buffer can still produce persistent entries when passed to a posting codeunit. A publisher's `var` parameter or `IsHandled` flag alone does not supply the missing quantity/cost coordination; the normal engine's own inserts operate within that coordination.

Not every value entry points to an item ledger entry: capacity and production WIP have their own supported posting relationships. Assembly and manufacturing posting retain order/component/routing and capacity context; one bare output/consumption call is not full order completion.

The clean sample takes an already prepared positive-adjustment journal line. It is not a substitute for journal preparation, batch revaluation, warehouse reconciliation, or source-document posting.

See sample: [`post-item-ledger-changes-through-item-journals.good.al`](post-item-ledger-changes-through-item-journals.good.al).

## Anti Pattern

Independent inserts/deletes of persistent `"Item Ledger Entry"` or `"Value Entry"` transaction rows, or overwrites of posted quantity, remaining quantity, application identity, or cost amounts, bypass the coordinated receipt, shipment, adjustment, or cost-correction workflow. `Insert(true)`, `Modify(true)`, and balanced-looking quantities do not supply that orchestration: stock can change without the corresponding application/value graph, or downstream cost flow can remain stale.

A table declaration or custom annotation-field update does not change inventory quantities or costs and is outside this transaction-state concern.

See sample: [`post-item-ledger-changes-through-item-journals.bad.al`](post-item-ledger-changes-through-item-journals.bad.al).

## References

- [Inventory posting design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-inventory-posting)
- [Item application design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-application)
- [BaseApp item-journal posting entry point](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostLine.Codeunit.al#L162-L179)
- [Assembly-order posting context](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-assembly-order-posting)
- [Production-order posting context](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-production-order-posting)
