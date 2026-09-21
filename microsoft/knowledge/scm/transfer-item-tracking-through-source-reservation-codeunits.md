---
bc-version: [all]
domain: scm
keywords: [reservation-entry, tracking-specification, sales-line-reserve, transfersalelinetosalesline, transferreserventry, copyitemtracking, quantity-base]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Transfer item tracking through source reservation codeunits

## Description

Moving lot/serial tracking between document lines is a source-ownership operation, not a copy of visible tracking fields. Partial movement must retain the old source's remainder, destination units of measure, quantities to handle/invoice, status, sign, and any reservation counterpart. Repointing a `"Reservation Entry"` loses this coordination; inserting a `"Tracking Specification"` row alone does not book the destination's source tracking.

## Best Practice

Reservation codeunits provide source-specific tracking workflows. For the tracking portion of blanket-sales-order or quote conversion to a sales order, `"Sales Line-Reserve".TransferSaleLineToSalesLine` takes the existing source line, prepared destination line, and quantity to transfer in **base units**. It delegates the source/status and quantity movement to `"Create Reserv. Entry".TransferReservEntry`.

The caller still owns document conversion and destination-line preparation; this method does not create a sales order. The source and destination must have compatible item, variant, location, and source identity. Purchases, transfers, assembly, and production have their own source-specific wrappers rather than sharing the sales conversion contract.

`"Item Tracking Management".CopyItemTracking` serves a different purpose: it creates Prospect copies, not a transfer of reservation ownership. That is valid for its intended copy workflow. Temporary Tracking Specification processing and persisted historical tracking specifications are also normal; the working/historic representation differs from the current source booking.

See sample: [`transfer-item-tracking-through-source-reservation-codeunits.good.al`](transfer-item-tracking-through-source-reservation-codeunits.good.al).

## Anti Pattern

Direct rewrites of persistent `"Reservation Entry"` source type/subtype, ID, reference number, or quantities do not perform the source-line conversion or partial tracking-transfer workflow. Changing only `"Quantity (Base)"` and source keys can drop the remainder or leave the other tracking/reservation quantities attached to the wrong source.

A tracking copy cannot replace movement of an existing binding reservation. Legitimate Prospect copying, temporary tracking buffers, historical tracking reads, and source-specific engine calls serve distinct purposes and are not independent reservation transfers.

See sample: [`transfer-item-tracking-through-source-reservation-codeunits.bad.al`](transfer-item-tracking-through-source-reservation-codeunits.bad.al).

## References

- [Item Tracking Lines window design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-tracking-lines-window)
- [Active versus historic item-tracking entries](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-active-versus-historic-item-tracking-entries)
- [Item tracking and reservations](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-tracking-and-reservations)
- [BaseApp sales tracking transfer](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Sales/Document/SalesLineReserve.Codeunit.al#L532-L578)
- [Base-unit conversion caller](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Sales/Document/BlanketSalesOrdertoOrder.Codeunit.al#L195-L198)
- [Prospect-copy API](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Tracking/ItemTrackingManagement.Codeunit.al#L575-L657)
