---
bc-version: [all]
domain: data-modeling
keywords: [report-selections, report-selection-usage, enumextension, document-layouts, custom-report-selection]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register a new document type through Report Selections, and wire it into Document Layouts correctly

## Description

A custom document that needs printing/emailing should be registered
through `table 77 "Report Selections"`. `enum 77 "Report Selection Usage"`
is `Extensible = true` for exactly this: add a value via `enumextension`,
then `ReportSelections.InsertRecord(Usage, Sequence, ReportID)` for a
tenant-wide default — the mechanism every standard document uses.

That alone does not make the value usable in "Document Layouts"
(`page 9657 "Customer Report Selections"` / `page 9658 "Vendor Report
Selections"`, table 9657 "Custom Report Selection"). Both pages hide
`enum 77` behind their own page-facing enum — `enum 9657 "Custom Report
Selection Sales"` (customer) / `enum 9658 "Report Selection Usage Vendor"`
(vendor) — in a field named `Usage2`. A new value stays invisible there
until that page enum is extended too and three events are handled:
`OnAfterOnMapTableUsageValueToPageValue` / `OnMapTableUsageValueToPage
ValueOnCaseElse` (Usage column display), `OnValidateUsage2OnCaseElse`
(picking it from the dropdown), and `OnAfterFilterCustomerUsageReport
Selections` / `OnAfterFilterVendorUsageReportSelections` (the **"Copy from
Report Selection"** action only — a hardcoded-list filter, nothing more).

Which side(s) need this depends on the counterparty the document actually
applies to — not "always both." BCApps' `ReportSelectionHandlerCZZ`
(Advance Payments) partitions strictly: `"Sales Advance..."` usages get
only the customer-side triad, `"Purchase Advance..."` only the vendor-side
triad. `ReportSelectionHandlerCZC` (Compensation) subscribes both sides —
legitimately, since that document posts to both ledgers, not by default.

## Best Practice

1. Add the usage value (`enumextension ... extends "Report Selection
   Usage"`) and register the tenant-wide default.
2. Decide which counterparty(ies) apply — customer, vendor, or both.
3. For each applicable side, extend the matching page enum
   (`"Custom Report Selection Sales"` / `"Report Selection Usage Vendor"`)
   and subscribe to that page's map, validate, and filter events —
   appending with `StrSubstNo('%1|%2', ReportSelections.GetFilter(Usage),
   UsageFilter)`, never overwriting.
4. Do not subscribe the other side for a one-sided document: skip the
   triad and the value is unreachable in Document Layouts; wire both sides
   needlessly and the picker is cluttered with a value that never applies.

See sample: [`extend-report-selection-usage-for-new-document-types.good.al`](extend-report-selection-usage-for-new-document-types.good.al)
(customer-only document — only the customer-side enum and triad added).

## Anti Pattern

1. Register the usage value but add no page-enum extension and no
   subscribers. Works via the tenant-wide default, so it's invisible in
   testing — but Document Layouts shows the value's rows blank, can't offer
   it in the Usage dropdown, and "Copy from Report Selection" never lists
   it. See sample: [`extend-report-selection-usage-for-new-document-types.bad.al`](extend-report-selection-usage-for-new-document-types.bad.al).
2. Subscribe both counterparties' triads for a one-sided document. This is
   the overbroad default Jesper Schulz-Wedde's review caught: it
   contradicts how `ReportSelectionHandlerCZZ` actually partitions its
   usages, and clutters the other counterparty's picker with a value that
   will never resolve a report there.

## Source

`ReportSelections.Table.al` (table 77, `InsertRecord` line 344),
`ReportSelectionUsage.Enum.al` (enum 77, `Extensible = true`),
`CustomReportSelection.Table.al` (table 9657) — all under
`src/Layers/W1/BaseApp/Foundation/Reporting/`.

`CustomerReportSelections.Page.al` (page 9657, `.../Sales/Setup/`):
`FilterCustomerUsageReportSelections` (307),
`OnAfterFilterCustomerUsageReportSelections` (335),
`OnAfterOnMapTableUsageValueToPageValue` (325),
`OnValidateUsage2OnCaseElse` (330); enum `CustomReportSelectionSales.Enum.al`
(9657, same folder). `VendorReportSelections.Page.al` (page 9658,
`.../Purchases/Setup/`): `FilterVendorUsageReportSelections` (281),
`OnAfterFilterVendorUsageReportSelections` (296),
`OnMapTableUsageValueToPageValueOnCaseElse` (301),
`OnValidateUsage2OnCaseElse` (306); enum `ReportSelectionUsageVendor.Enum.al`
(9658, same folder).

Partitioning precedent: `.../AdvancePaymentsLocalization/app/Src/Codeunits/
ReportSelectionHandlerCZZ.Codeunit.al` (codeunit 31420) — customer-only
triad (47, 58, 69) for `"Sales Advance..."`, vendor-only triad (80, 91,
102) for `"Purchase Advance..."`, never both for one usage. Enum
extensions: `CustomReportSelSalesCZZ.EnumExt.al` (31008), `ReportSelUsage
VendorCZZ.EnumExt.al` (11708).

Contrast (two-sided): `.../CompensationLocalization/app/Src/Codeunits/
ReportSelectionHandlerCZC.Codeunit.al` (codeunit 11765) subscribes both
triads (16/27/38, 44/55/66) for `"Compensation CZC"`, which posts to both
a customer and a vendor ledger. (Lines as of `main`; may shift by version.)
