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

For an additional demand not already recorded on a source line, use `"Available to Promise".CalcQtyAvailableToPromise` with the Item's location/variant filters, date range ending on the shipment date, and the configured period/lookahead horizon. Compare in base units. Use a fresh calculation context or the codeunit's recalculation support rather than carrying cached quantities between unrelated items or requests.

For an existing sales-line change, retain the source-aware order-promising/availability workflow, which accounts for the line's own quantity or delta; blindly applying an additional-demand calculation can double-count that line. Assembly and production requirements/supply likewise need the standard availability context, not just a sales-only stock subtraction.

An ATP result is not a reservation or a guarantee of warehouse pickability. Lot/serial constraints, bins, warehouse activity, and later concurrent changes still need their own checks. Conversely, an on-hand display, valuation report, or deliberately immediate-stock-only check is allowed to use `Item.Inventory`; do not replace its distinct business question with ATP.

## Anti Pattern

Report `CalcFields(Inventory)` or an equivalent sum of item ledger quantities used as the complete decision for a dated additional-demand promise, including code that applies location/variant filters but ignores other demand and supply. Require explicit promising intent; an Inventory FlowField read alone is not a finding.

Also report a visible loss of location, variant, date, or source-line context in that calculation. Do not invent missing demand in an unseen caller or require this exact API when a visible supported workflow already supplies the correct availability semantics.

## Samples

- [`use-date-aware-availability-for-promising.bad.al`](use-date-aware-availability-for-promising.bad.al)
- [`use-date-aware-availability-for-promising.good.al`](use-date-aware-availability-for-promising.good.al)

## References

- [Calculate order-promising dates](https://learn.microsoft.com/en-us/dynamics365/business-central/sales-how-to-calculate-order-promising-dates)
- [Availability in the warehouse](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-availability-in-the-warehouse)
- [BaseApp ATP calculation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Availability/AvailabletoPromise.Codeunit.al#L52-L184)
- [Forward-demand lookahead](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Availability/AvailabletoPromise.Codeunit.al#L295-L356)
