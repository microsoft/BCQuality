---
bc-version: [all]
domain: scm
keywords: [transfer-header, transfer-line, transferorder-post-shipment, transferorder-post-receipt, in-transit-code, last-shipment-no, item-application-entry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Post transfers through shipment and receipt codeunits

## Description

A two-step transfer order preserves a continuous quantity, reservation, and cost/application lineage from the source through in-transit to the destination. Its shipment and receipt workflows also own posted documents and derived lines for partial receipt. Posting an item-journal movement and manually marking a transfer header or line as shipped is not equivalent, even if the total quantities balance.

## Best Practice

A prepared non-direct transfer order without required warehouse documents uses `"TransferOrder-Post Shipment".Run` at shipment and `"TransferOrder-Post Receipt".Run` at receipt, with the actual `"Transfer Header"`. Validated source quantities to ship/receive prepare the operation; posted quantity counters are results of posting.

Required warehouse shipment or receipt enters the warehouse document posting workflow, which invokes the transfer poster with its real source context. Direct transfers have their configured standard workflow; the two-step sample's in-transit guard is not a universal requirement.

Standalone item reclassification journals and bin movements are legitimate separate operations, not completion of an existing transfer order. Tracking/application splits and average-cost handling mean transfers do not have one fixed item-entry count or a nonzero `"Transferred-from Entry No."` on every application.

See sample: [`post-transfers-through-shipment-and-receipt-codeunits.good.al`](post-transfers-through-shipment-and-receipt-codeunits.good.al).

## Anti Pattern

Ad-hoc item postings, independent positive/negative adjustments, manually created posted-transfer rows, and direct shipment/receipt-counter changes cannot substitute for transfer-order posting. Updating `"Last Shipment No."` after a bare item-journal call does not create the posted shipment, source-line progress, or transfer application lineage.

Changing an existing item ledger entry's location or inventing application links does not repair that missing workflow. Metadata enrichment within the normal shipment/receipt or direct-transfer workflow is distinct from replacing the posting operation.

See sample: [`post-transfers-through-shipment-and-receipt-codeunits.bad.al`](post-transfers-through-shipment-and-receipt-codeunits.bad.al).

## References

- [Transfer inventory between locations](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-how-transfer-between-locations)
- [Item application design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-application)
- [Cost adjustment design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-cost-adjustment)
- [BaseApp shipment journal/source linkage](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Transfer/TransferOrderPostShipment.Codeunit.al#L292-L336)
- [Partial-receipt derived-line handling](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Transfer/TransferOrderPostReceipt.Codeunit.al#L457-L529)
- [Transfer application and average-cost branches](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostLine.Codeunit.al#L1911-L1976)
