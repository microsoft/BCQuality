---
bc-version: [all]
domain: scm
keywords: [quantity-base, qty-per-unit-of-measure, unit-of-measure-code, unit-of-measure-management, calcbaseqty, getqtyperunitofmeasure, qty-rounding-precision, item-journal-line]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Derive base quantities through the line's unit of measure

## Description

Inventory, item ledger entries, reservations, item tracking, and warehouse quantities are measured in the item's base unit of measure. Document and journal lines hold `Quantity` in the line's `"Unit of Measure Code"`, together with `"Qty. per Unit of Measure"` and base-unit fields such as `"Quantity (Base)"`. Ten boxes of twelve pieces are 120 base units, not 10. When a line's `Quantity` is validated, the table derives the base quantity through its `CalcBaseQty` procedure. That procedure calls `"Unit of Measure Management".CalcBaseQty` with the line's quantity rounding precision and raises an error when rounding would turn a non-zero quantity into a zero base quantity. Code that bypasses this conversion creates a line whose quantity and base quantity disagree, or makes a stock decision in the wrong unit.

## Best Practice

On a document or journal line, validate `"Unit of Measure Code"` before `Quantity`, and validate both. Validating the unit of measure sets `"Qty. per Unit of Measure"` from the item unit of measure; validating the quantity then fills the base fields with the correct rounding. Compare line quantities with inventory or availability in base units, for example `"Quantity (Base)"` or `"Outstanding Qty. (Base)"`.

Outside a line, get the factor with `"Unit of Measure Management".GetQtyPerUnitOfMeasure(Item, UnitOfMeasureCode)` and convert with its `CalcBaseQty` or `CalcQtyFromBase` procedures instead of multiplying by hand. Pass the item unit's quantity rounding precision where the available overload accepts it.

Reading these fields for display, reporting, or a temporary buffer that is never posted is not a conversion defect. Code that proves the line uses the base unit of measure (`"Qty. per Unit of Measure"` equal to 1) is also correct, but don't assume this from the item alone, because a line can use another unit.

See sample: [`derive-base-quantities-through-the-line-unit-of-measure.good.al`](derive-base-quantities-through-the-line-unit-of-measure.good.al).

## Anti Pattern

Assigning `Quantity` directly on an item journal, sales, purchase, or transfer line and then inserting, modifying, or posting it. Also assigning a base field such as `"Quantity (Base)" := Quantity`, multiplying by a hard-coded or separately looked-up factor without the line's rounding, or comparing a line's `Quantity` with `Item.Inventory` or another base-unit value. Detection signal: a direct `:=` to `Quantity`, `"Qty. per Unit of Measure"`, or a `(Base)` quantity field on a persisted or posted line, or a comparison between a non-base line quantity and an inventory quantity.

See sample: [`derive-base-quantities-through-the-line-unit-of-measure.bad.al`](derive-base-quantities-through-the-line-unit-of-measure.bad.al).

## References

- [Set up units of measure, including quantity rounding precision](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-how-setup-units-of-measure)
- [BCApps: Unit of Measure Management conversions](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/BaseApp/Foundation/UOM/UnitofMeasureManagement.Codeunit.al)
- [BCApps: Item Journal Line quantity validation and CalcBaseQty](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/BaseApp/Inventory/Journal/ItemJournalLine.Table.al)
- [BCApps: Sales Line quantity validation and CalcBaseQty](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/BaseApp/Sales/Document/SalesLine.Table.al)
