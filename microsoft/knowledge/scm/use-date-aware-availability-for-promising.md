---
bc-version: [all]
domain: scm
keywords: [available-to-promise, calcqtyavailabletopromise, inventory, shipment-date, gross-requirement, scheduled-receipt, location-filter, variant-filter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use date-aware availability for promising

## Description

`Item.Inventory` is an on-hand quantity, not an available-to-promise answer. Promising additional demand must account for the requested date, location and variant, reservations, scheduled receipts, existing requirements, and demand within the configured lookahead. An on-hand comparison can promise inventory already committed elsewhere and miss incoming supply.

## Best Practice

For additional demand not already recorded on a source line, `"Available to Promise".CalcQtyAvailableToPromise` uses the Item's location/variant filters, date range ending on the shipment date, and configured period/lookahead horizon. Its result and the additional quantity are compared in base units. A fresh calculation context or the codeunit's recalculation support avoids carrying cached quantities between unrelated items or requests.

The source-aware order-promising/availability workflow accounts for an existing sales line's own quantity or delta; applying an additional-demand calculation to that line can double-count it. Assembly and production requirements/supply likewise participate in the standard availability context, not just a sales-only stock subtraction.

An ATP result is not a reservation or a guarantee of warehouse pickability. Lot/serial constraints, bins, warehouse activity, and later concurrent changes still need their own checks. Conversely, an on-hand display, valuation report, or deliberately immediate-stock-only check can use `Item.Inventory`: it answers a different business question from ATP.

See sample: [`use-date-aware-availability-for-promising.good.al`](use-date-aware-availability-for-promising.good.al).

## Anti Pattern

`CalcFields(Inventory)` or an equivalent item-ledger quantity sum used as the complete decision for a dated additional-demand promise ignores existing demand and incoming supply, even with location/variant filters. An Inventory FlowField read for an on-hand display has no such promising contract.

Losing location, variant, date, or source-line context changes the calculation's business meaning. Another supported workflow that preserves the same availability semantics does not have to call this exact API.

See sample: [`use-date-aware-availability-for-promising.bad.al`](use-date-aware-availability-for-promising.bad.al).

## References

- [Calculate order-promising dates](https://learn.microsoft.com/en-us/dynamics365/business-central/sales-how-to-calculate-order-promising-dates)
- [Availability in the warehouse](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-availability-in-the-warehouse)
- [BaseApp ATP calculation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Availability/AvailabletoPromise.Codeunit.al#L52-L184)
- [Forward-demand lookahead](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Availability/AvailabletoPromise.Codeunit.al#L295-L356)
