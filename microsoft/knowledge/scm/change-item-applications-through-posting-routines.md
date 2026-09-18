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

The Application Worksheet provides the interactive correction workflow. A narrowly controlled programmatic correction of an ordinary quantity application uses the same `"Item Jnl.-Post Line"` instance for `UnApply`, a reload of the affected outbound item entry, and `ReApply` to the compatible inbound entry. Its finalization lifecycle includes `RedoApplications`, `CostAdjust`, and `ClearApplicationLog`.

The posting routines enforce inventory-period, correction, transfer, and drop-shipment restrictions. Entries with `"Transferred-from Entry No."`, outbound transfers, and special application types are outside the ordinary-sales sample's scope. Application-check bypasses remove those protections, and the worksheet's multi-step recovery flags belong to its UI lifecycle rather than a standalone transaction.

`CostAdjust` honors automatic-cost-adjustment setup; calling it does not mean all costs are settled when adjustment is disabled or deferred. Scheduled/manual adjustment remains necessary in those configurations. Temporary application projections, extension metadata, and source-document reservation/order-tracking changes are not edits to the persistent item-application graph.

See sample: [`change-item-applications-through-posting-routines.good.al`](change-item-applications-through-posting-routines.good.al).

## Anti Pattern

Independent `Modify`, `Delete`, or replacement `Insert` operations on persistent `"Item Application Entry"` rows can repoint a receipt/shipment application without updating remaining quantities or cost propagation. Valid item numbers, matching quantities, and running table triggers do not complete reapplication.

Omitting finalization or committing between unapply and reapply exposes an incomplete replacement. The standard posting/application workflow's internal table writes differ because they participate in that lifecycle.

See sample: [`change-item-applications-through-posting-routines.bad.al`](change-item-applications-through-posting-routines.bad.al).

## References

- [Item application design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-application)
- [Cost adjustment design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-cost-adjustment)
- [BaseApp application finalization sequence](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Ledger/ApplicationWorksheet.Page.al#L495-L503)
- [BaseApp reapplication and cost-adjustment lifecycle](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostLine.Codeunit.al#L5464-L5538)
