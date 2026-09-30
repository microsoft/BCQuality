---
bc-version: [all]
domain: data-modeling
keywords: [prices-including-vat, unit-price, line-amount, direct-unit-cost, prepmt-line-amount, amount-including-vat, sales-line, purchase-line, net-gross]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Sales and purchase line prices follow the header's Prices Including VAT

> Contributions welcome — open a PR to refine or extend this article.

## Description

Line prices are gross or net depending on the header's `Prices Including VAT`. When the flag is set, `Unit Price` (sales), `Direct Unit Cost` (purchase), `Line Amount`, `Line Discount Amount`, `Inv. Discount Amount`, and `Prepmt. Line Amount` all include VAT; when it is cleared they exclude it. Only `Amount` (always net), `Amount Including VAT` (always gross), and `VAT Base Amount` keep a fixed basis. Code that reads or writes the price fields without looking at the header flag is wrong for every document whose customer or vendor uses the other setting.

## Best Practice

When code needs a known basis — exports, integrations, KPIs, custom totals, commission or margin calculations — read `Amount` for net and `Amount Including VAT` for gross. Both are already reduced by line and invoice discounts and are maintained by the line's VAT calculation, so no VAT arithmetic is needed.

When code writes a price from an external source whose basis is known (an EDI price list, an API payload, a web-shop order), get the document header and convert the source price into the header's basis before validating `Unit Price` or `Direct Unit Cost`, using the line's `VAT %` and the currency's `Unit-Amount Rounding Precision`. Alternatively, set `Prices Including VAT` on the header to match the source before the first line is created. Toggling it later on a header with priced lines asks the user to confirm a recalculation. Without a UI session, or when validation dialogs are hidden, BaseApp converts all line prices without asking.

The standard price calculation already converts a `Price List Line` whose `Price Includes VAT` differs from the document's setting, so a price it returns is in the document's basis and must not be converted a second time.

The same rule applies to the purchase mirror fields. On purchase lines, `Unit Cost` and `Unit Cost (LCY)` are derived from `Direct Unit Cost` with VAT removed, so they stay net.

See sample: [`document-line-prices-follow-prices-including-vat.good.al`](document-line-prices-follow-prices-including-vat.good.al).

## Anti Pattern

Treating `Unit Price`, `Direct Unit Cost`, or `Line Amount` as net by default. Typical signals: summing `Line Amount` as a document's net total, computing VAT as `Line Amount * "VAT %" / 100`, putting a known net or gross external price straight into `Unit Price` or `Direct Unit Cost`, or comparing a line price with `Item."Unit Price"` or `Item."Last Direct Cost"` — all without reading the header's `Prices Including VAT`. For a gross-price customer at 19 % VAT, a net total built from `Line Amount` is 19 % too high, and a net price of 100 imported unconverted yields a net revenue of only 84.03. A variable or procedure name ending in `ExclVAT` or `Net` that is fed from `Line Amount` is a strong signal of this mistake. BaseApp's own `CalculateOutstandingAmountExclTax` shows that the name alone guarantees nothing: it returns a value based on `Line Amount`.

Do not report code that reads the header flag, uses `Amount` or `Amount Including VAT`, or only passes values between two lines of the same document (same basis on both sides).

See sample: [`document-line-prices-follow-prices-including-vat.bad.al`](document-line-prices-follow-prices-including-vat.bad.al).

## References

- [BCApps: Sales Header `Prices Including VAT` OnValidate recalculates line prices](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesHeader.Table.al).
- [BCApps: Sales Line `UpdateVATAmounts` derives `Amount` from `Line Amount` per basis](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesLine.Table.al).
- [BCApps: `Sales Line CaptionClass Mgmt` switches captions to Incl./Excl. VAT](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesLineCaptionClassMgmt.Codeunit.al).
- [BCApps: Purchase Line `UpdateUnitCost` removes VAT from `Direct Unit Cost`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Purchases/Document/PurchaseLine.Table.al).
- [BCApps: `Price Calculation Buffer Mgt.` `ConvertAmountByTax`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Pricing/Calculation/PriceCalculationBufferMgt.Codeunit.al).
