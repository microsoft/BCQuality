---
bc-version: [all]
domain: scm
keywords: [item-application-entry, inbound-item-entry-no, unapply, reapply, redoapplications, costadjust, application-worksheet]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Change item applications through posting routines

## Description

An `"Item Application Entry"` connects quantity application to cost flow; changing its inbound entry number is not merely fixing a foreign key. Unapplication/reapplication also affects ledger remaining quantities, open states, valuation, and entries needing cost adjustment. Direct edits can leave a plausible application row attached to inconsistent inventory and costs.

## Best Practice

Prefer the Application Worksheet for interactive corrections. For a narrowly controlled programmatic correction of an ordinary quantity application, use the same `"Item Jnl.-Post Line"` instance for `UnApply`, reload the affected outbound item entry, then `ReApply` it to the compatible inbound entry. Complete the application's `RedoApplications`, `CostAdjust`, and `ClearApplicationLog` lifecycle; do not commit a half-completed replacement.

Respect the posting routines' inventory-period, correction, transfer, and drop-shipment restrictions rather than bypassing them. `"Transferred-from Entry No."`, outbound transfers, and special application types are not permission to reuse the ordinary-sales sample unchecked. Do not enable application-check bypasses or borrow the worksheet's multi-step recovery flags for a standalone transaction.

`CostAdjust` honors automatic-cost-adjustment setup; calling it does not promise that all costs are settled when adjustment is disabled or deferred. Retain the required scheduled/manual adjustment process. Temporary application projections, extension metadata, and source-document reservation/order-tracking changes are not edits to the persistent item-application graph.

## Anti Pattern

Report independent `Modify`, `Delete`, or replacement `Insert` operations on persistent `"Item Application Entry"` rows used to repoint a receipt/shipment application, including a change to `"Inbound Item Entry No."` that leaves remaining quantities and cost propagation untouched. Valid item numbers, matching quantities, or running table triggers do not complete reapplication.

Also report a visibly incomplete custom unapply/reapply transaction that omits finalization or commits between the two operations. Do not flag code merely because the standard posting/application workflow internally writes these tables.

## Samples

- [`change-item-applications-through-posting-routines.bad.al`](change-item-applications-through-posting-routines.bad.al)
- [`change-item-applications-through-posting-routines.good.al`](change-item-applications-through-posting-routines.good.al)

## References

- [Item application design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-application)
- [Cost adjustment design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-cost-adjustment)
- [BaseApp application finalization sequence](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Ledger/ApplicationWorksheet.Page.al#L495-L503)
- [BaseApp reapplication and cost-adjustment lifecycle](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostLine.Codeunit.al#L5464-L5538)
