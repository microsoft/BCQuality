---
bc-version: [all]
domain: data-modeling
keywords: [prices-including-vat, unit-price, line-amount, direct-unit-cost, prepmt-line-amount, amount-including-vat, sales-line, purchase-line, service-line, net-gross]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Sales, purchase, and service line prices follow the header's Prices Including VAT

> Contributions welcome — open a PR to refine or extend this article.

## Description

Line prices are gross or net depending on the header's `Prices Including VAT`. When the flag is set, `Unit Price` (sales, service), `Direct Unit Cost` (purchase), `Line Amount`, `Line Discount Amount`, `Inv. Discount Amount`, and the prepayment fields `Prepmt. Line Amount`, `Prepmt. Amt. Inv.`, `Prepmt Amt to Deduct`, and `Prepmt Amt Deducted` all include VAT. When it is cleared they exclude it. Only `Amount`, `VAT Base Amount`, and `Prepayment Amount` (always net) and `Amount Including VAT`, `Prepmt. Amt. Incl. VAT`, and `Prepmt. Amount Inv. Incl. VAT` (always gross) keep a fixed basis. Code that mixes the two groups without looking at the header flag is wrong for every document whose customer or vendor uses the other setting.

## Best Practice

When code needs a known basis — exports, integrations, KPIs, custom totals, commission or margin calculations — read `Amount` for net and `Amount Including VAT` for gross. Both are already reduced by line and invoice discounts and are maintained by the line's VAT calculation, so no VAT arithmetic is needed.

When code combines fields, pair fields of the same group. BaseApp's `UpdatePrepmtAmounts` sets `Prepmt. Line Amount` from `Line Amount` minus `Inv. Discount Amount`. This is correct because all three follow the header flag. `Prepmt. Amt. Inv.` pairs with `Prepmt. Line Amount`; `Prepmt. Amount Inv. Incl. VAT` pairs only with other gross values.

When code writes a price from an external source whose basis is known (an EDI price list, an API payload, a web-shop order), get the document header and convert the source price into the header's basis before validating `Unit Price` or `Direct Unit Cost`, using the line's `VAT %` and the currency's `Unit-Amount Rounding Precision`. Alternatively, set `Prices Including VAT` on the header to match the source before the first line is created. Toggling it later on a sales header with priced lines asks the user to confirm a recalculation. Without a UI session, or when validation dialogs are hidden, BaseApp converts all line prices without asking.

The standard price calculation already converts a `Price List Line` whose `Price Includes VAT` differs from the document's setting, so a price it returns is in the document's basis and must not be converted a second time.

On purchase lines, `Unit Cost` and `Unit Cost (LCY)` are derived from `Direct Unit Cost` with VAT removed, so they stay net. Service lines follow the same rule for `Unit Price` and `Line Amount`: they share the caption switch and the `UpdateVATAmounts` split of the sales line.

See sample: [`document-line-prices-follow-prices-including-vat.good.al`](document-line-prices-follow-prices-including-vat.good.al).

## Anti Pattern

Treating `Unit Price`, `Direct Unit Cost`, or `Line Amount` as net by default. Typical signals: summing `Line Amount` as a document's net total, computing VAT as `Line Amount * "VAT %" / 100`, putting a known net or gross external price straight into `Unit Price` or `Direct Unit Cost`, or comparing a line price with `Item."Unit Price"` or `Item."Last Direct Cost"` — all without reading the header's `Prices Including VAT`. For a gross-price customer at 19 % VAT, a net total built from `Line Amount` is 19 % too high, and a net price of 100 imported unconverted yields a net revenue of only 84.03.

Trusting a name instead of the source fields. The public procedure `CalculateOutstandingAmountExclTax` on `Sales Line` and `Purchase Line` returns `Line Amount` minus `Inv. Discount Amount` for the uninvoiced quantity, so its result includes VAT on a `Prices Including VAT` document despite its name. BaseApp only combines it with `Prepmt. Line Amount`, which has the same basis. Extension code that uses it as a net outstanding amount — compared with `Amount`, exported as net, or used to compute VAT — has this defect. The same applies to any variable or procedure named `ExclVAT`, `ExclTax`, or `Net` that is fed from a header-dependent field.

Do not report code that reads the header flag, uses only fixed-basis fields, or only combines fields of the same group (for example, prepayment amounts derived from `Line Amount`, or values copied between two lines of the same document).

See sample: [`document-line-prices-follow-prices-including-vat.bad.al`](document-line-prices-follow-prices-including-vat.bad.al).

## References

- [BCApps: Sales Header `Prices Including VAT` OnValidate recalculates line prices](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesHeader.Table.al).
- [BCApps: Sales Line `UpdateVATAmounts`, `UpdatePrepmtAmounts`, and `CalculateOutstandingAmountExclTax`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesLine.Table.al).
- [BCApps: `Sales Line CaptionClass Mgmt` switches captions to Incl./Excl. VAT](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Sales/Document/SalesLineCaptionClassMgmt.Codeunit.al).
- [BCApps: Purchase Line `UpdateUnitCost` removes VAT from `Direct Unit Cost`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Purchases/Document/PurchaseLine.Table.al).
- [BCApps: Service Line `GetCaptionClass` and `UpdateVATAmounts`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Service/Document/ServiceLine.Table.al).
- [BCApps: `Price Calculation Buffer Mgt.` `ConvertAmountByTax`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Pricing/Calculation/PriceCalculationBufferMgt.Codeunit.al).
