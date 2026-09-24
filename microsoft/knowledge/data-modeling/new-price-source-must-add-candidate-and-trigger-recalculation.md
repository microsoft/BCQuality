---
bc-version: [all]
domain: data-modeling
keywords: [price-calculation, price-source, onafteraddsources, recalculation, pricing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A new price source needs both a calculation candidate and a recalculation trigger

## Description

Making a custom field usable as a price source on a sales line is two
separate, independent pieces of wiring, and doing only one produces a
line that looks like it's using the new source without ever actually
being priced by it. `codeunit "Sales Line - Price"` publishes
`OnAfterAddSources(SalesHeader: Record "Sales Header"; SalesLine: Record
"Sales Line"; PriceType: Enum "Price Type"; var PriceSourceList: Codeunit
"Price Source List")` — subscribing here and calling
`PriceSourceList.Add(SourceType, SourceNo)` makes the source a candidate
the calculation considers. But nothing about that subscription causes
the price to be *recalculated* when the source field's value changes on
an existing line. That's the second, separate piece, and it needs to be
wired correctly: `Sales Line`'s `procedure
UpdateUnitPriceByField(CalledByFieldNo: Integer)` only recalculates if
the field was already *planned* — internally it exits immediately unless
`procedure PlanPriceCalcByField(CurrPriceFieldNo: Integer)` was already
called for that same field number. Calling `UpdateUnitPriceByField` on
its own, without a matching `PlanPriceCalcByField` call first, compiles
fine and looks correct, but silently recalculates nothing. `Sales Line`
also exposes `procedure UpdateUnitPrice(CalledByFieldNo: Integer)`, a
convenience wrapper that does both steps in the right order (plan, then
update) in one call — this is the method the base app itself calls from
*outside* `Sales Line` to trigger recalculation for a field it just
changed (see `Inventory/Item/Catalog/ItemReferenceManagement.Codeunit.al`:
`SalesLine.UpdateUnitPrice(SalesLine.FieldNo("Item Reference No."))`), and
it's what a custom price source field's own trigger should call too — the
same way Microsoft's own Location example is wired from a `Sales Line`
validation event, not from the price source registration itself.

Add the source without wiring recalculation, and the failure hides
easily: a *new* line still prices correctly, because the field already
holds its value when calculation first runs on insert. The gap only
shows up when someone *changes* the source field's value on an existing
line — the price silently keeps its old value until something unrelated
happens to trigger recalculation.

## Best Practice

Wire both halves together whenever a field becomes a price source: an
`OnAfterAddSources` subscriber that adds it via `PriceSourceList.Add`, and
a trigger on the field itself (its own `OnValidate`, or a matching
`OnAfterValidate` integration event) that calls
`SalesLine.UpdateUnitPrice(SalesLine.FieldNo(<TheField>))`. Calling
`UpdateUnitPriceByField` directly, without first calling
`PlanPriceCalcByField` for that same field number, is *not* equivalent —
it exits immediately and recalculates nothing. `UpdateUnitPrice` does
both calls, in the correct order, in one step.

See sample: [`new-price-source-must-add-candidate-and-trigger-recalculation.good.al`](new-price-source-must-add-candidate-and-trigger-recalculation.good.al).

## Anti Pattern

Subscribing to `OnAfterAddSources` to register a custom field as a price
source, without also triggering recalculation (via `UpdateUnitPrice`, or
the `PlanPriceCalcByField` + `UpdateUnitPriceByField` pair) from that
field's own validation. The field is a genuine, working calculation
candidate — new lines price correctly — but editing the field on an
existing line leaves the unit price stale, with nothing to indicate why.

See sample: [`new-price-source-must-add-candidate-and-trigger-recalculation.bad.al`](new-price-source-must-add-candidate-and-trigger-recalculation.bad.al).

## Source

BCApps (`src/Layers/W1/BaseApp/`): `Sales/Pricing/SalesLinePrice.Codeunit.al`
(`local procedure OnAfterAddSources(SalesHeader: Record "Sales Header";
SalesLine: Record "Sales Line"; PriceType: Enum "Price Type"; var
PriceSourceList: Codeunit "Price Source List")`); `Pricing/Source/PriceSourceList.Codeunit.al`
(`procedure Add(SourceType: Enum "Price Source Type"; SourceNo: Code[20])`);
`Sales/Document/SalesLine.Table.al` (`procedure
PlanPriceCalcByField(CurrPriceFieldNo: Integer)`; `procedure
UpdateUnitPrice(CalledByFieldNo: Integer)`; `procedure
UpdateUnitPriceByField(CalledByFieldNo: Integer)`, which exits immediately
unless `FieldCausedPriceCalculation` already equals `CalledByFieldNo` —
the state `PlanPriceCalcByField` sets). External, idiomatic use of the
one-call form: `Inventory/Item/Catalog/ItemReferenceManagement.Codeunit.al`
(`SalesLine.UpdateUnitPrice(SalesLine.FieldNo("Item Reference No."))`).

Microsoft Learn, "Extending Price Calculations" (Location example): "To
recalculate the price, we can subscribe to events that pass the sales
line by reference... We'll call the UpdateUnitPriceByLocationCode()
method, which is a simplified version of the UpdateUnitPriceByField()
method... To add the location in the source list for price calculations,
we'll subscribe to the OnAfterAddSources event of Codeunit 'Sales Line -
Price,' and add the Location Code as a source."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
