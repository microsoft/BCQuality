---
bc-version: [all]
domain: data-modeling
keywords: [report-selections, report-selection-usage, enumextension, document-layouts, custom-report-selection]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register a new document type through Report Selections, and extend the Document Layouts filter

## Description

A custom document that needs to be printed or emailed should be registered
through `table 77 "Report Selections"`, not given its own bespoke
report/layout lookup. `enum 77 "Report Selection Usage"` is
`Extensible = true` specifically so a new document type can add its own
usage value via an `enumextension`, then register a default report for it
with `ReportSelections.InsertRecord(Usage, Sequence, ReportID)` — the same
mechanism every standard Sales/Purchase/Service document uses.

Registering through table 77 also brings per-account customization for
free: `table 9657 "Custom Report Selection"` (surfaced as the "Document
Layouts" action on the Customer and Vendor cards) lets one specific
account override both the report and the layout, and the platform's
lookup checks that table first before falling back to the tenant-wide
default. But the "Copy from Report Selection" action on the Document
Layouts pages — the convenience button a user actually uses to seed a
per-account override — filters to a **hardcoded** list of usage values
(`FilterCustomerUsageReportSelections`/`FilterVendorUsageReportSelections`
on `page 9657 "Customer Report Selections"`/`page 9658 "Vendor Report
Selections"`). A new custom usage value is not included automatically. Both
pages publish `OnAfterFilterCustomerUsageReportSelections(var
ReportSelections: Record "Report Selections")` /
`OnAfterFilterVendorUsageReportSelections(...)` for exactly this reason —
real BCApps localization apps (e.g. the Czech Compensation localization,
`ReportSelectionHandlerCZC.Codeunit.al`) subscribe to both events and
extend the filter with `StrSubstNo('%1|%2', ReportSelections.GetFilter(Usage),
UsageFilter)`, appending to whatever filter already exists rather than
replacing it.

## Best Practice

Add the new usage value via `enumextension ... extends "Report Selection
Usage"`, register a tenant-wide default row with
`ReportSelections.InsertRecord(...)`, and subscribe to both
`OnAfterFilterCustomerUsageReportSelections` and
`OnAfterFilterVendorUsageReportSelections` — even if the document only
ever applies to one counterparty side — appending to the existing filter
rather than overwriting it. Treat the registration and the filter
subscription as one inseparable step: shipping one without the other
leaves per-account layout customization silently unreachable through the
standard UI.

See sample: `extend-report-selection-usage-for-new-document-types.good.al`.

## Anti Pattern

Adding a new `Report Selection Usage` value and registering a default
report, but never subscribing to the filter events. The tenant-wide
default works, so the gap isn't visible in testing — but a user who opens
"Document Layouts" on a specific customer or vendor and clicks "Copy from
Report Selection" to start a per-account override will never see the new
document type in the list, with no error and no visible sign that
anything is missing.

See sample: `extend-report-selection-usage-for-new-document-types.bad.al`.

## Source

BCApps `ReportSelections.Table.al` (table 77, `InsertRecord` at line 344),
`ReportSelectionUsage.Enum.al` (enum 77, `Extensible = true`),
`CustomReportSelection.Table.al` (table 9657), `CustomerReportSelections.Page.al`
(page 9657, `FilterCustomerUsageReportSelections` and
`OnAfterFilterCustomerUsageReportSelections` at line 335),
`VendorReportSelections.Page.al` (page 9658, `OnAfterFilterVendorUsageReportSelections`
at line 296) — all under `src/Layers/W1/BaseApp/`. Real subscriber
precedent: `src/Apps/CZ/CompensationLocalization/app/Src/Codeunits/ReportSelectionHandlerCZC.Codeunit.al`,
`GetUsageFilter` (line 104) and both event subscribers (lines 38, 66).
