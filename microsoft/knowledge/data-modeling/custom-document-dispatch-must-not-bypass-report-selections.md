---
bc-version: [all]
domain: data-modeling
keywords: [report-selections, document-layouts, custom-report-layout, email-attachment, bespoke-dispatch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Custom document dispatch must not bypass Report Selections

## Description

A codeunit that hardcodes which report to run (`Report.RunModal(MyReportId, ...)`)
and builds its own email directly, instead of registering the document
through `table 77 "Report Selections"` and calling its own
Print/Email procedures, works for the one case it was written for — and
loses everything the platform's registry provides for free. `Report
Selections` carries its own attachment/email-body configuration per usage
(`"Use for Email Attachment"`, `"Use for Email Body"`, `"Email Body Layout
Code"`, `"Email Body Layout Type"`, `"Custom Report Layout Code"`), and
`table 9657 "Custom Report Selection"` (the "Document Layouts" page on the
Customer/Vendor card) lets one specific account override the report or
layout without touching code at all. None of that exists for a document
whose dispatch was hand-rolled: there is no registry row to point
"Document Layouts" at, so an admin who goes looking for where to change
this document's layout — the same place they'd look for every other
document in the system — finds nothing, because the document was never
registered there.

## Best Practice

Register the document under a `Report Selection Usage` value (see
`extend-report-selection-usage-for-new-document-types.md`) and dispatch
through `Report Selections`' own Print/Email procedures (see
`document-print-and-email-actions-call-report-selections-directly.md`),
even when the surrounding business logic — which counterparty to use,
what validation must pass before sending — is genuinely specific to the
document. Custom logic belongs around the call to `Report Selections`,
not instead of it.

See sample: `custom-document-dispatch-must-not-bypass-report-selections.good.al`.

## Anti Pattern

A codeunit that runs a hardcoded report ID and builds its own email
message directly, with no `Report Selections` row backing it. It works for
the default case, but the report/layout cannot be changed per account
without a code change and a new release, and the document is invisible to
"Document Layouts" — the standard place every other document's
distribution is configured.

See sample: `custom-document-dispatch-must-not-bypass-report-selections.bad.al`.

## Source

BCApps `ReportSelections.Table.al` (table 77 — fields 19–26 for email
attachment/body configuration; `SendEmailToCust`/`PrintWithDialogForCust`
as the registry-backed dispatch entry points) and
`CustomReportSelection.Table.al` (table 9657, the per-account override
backing the "Document Layouts" page) — both under
`src/Layers/W1/BaseApp/Foundation/Reporting/`.
