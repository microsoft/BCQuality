---
bc-version: [all]
domain: data-modeling
keywords: [report-selections, document-sending-profile, print, email, post-and-send]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A document's own Print/Email actions call Report Selections directly; Document Sending Profile is scoped to Post-and-Send

## Description

`table 60 "Document Sending Profile"` is not a general gateway that every
print/email path should route through — it exists specifically for the
combined **Post and Send** action: "You can set each customer up with a
preferred method of sending sales documents, so that you do not have to
select a sending option every time you choose the Post and Send action"
(Microsoft Learn, "Set Up Document Sending Profiles"). A document's own, ordinary
Print/Email ribbon actions call `table 77 "Report Selections"` directly
and are not affected by any Document Sending Profile at all. This is the
pattern BC's own base application uses for a document's plain print/email
actions: the Sales Order's "Print Confirmation"/"Email Confirmation"
actions (`codeunit "Document-Print"`, `PrintSalesOrder`/`EmailSalesHeader`)
call `ReportSelections.PrintWithDialogForCust`/`SendEmailToCust` directly,
and the posted `Purch. Inv. Header`'s own `PrintRecords` does the same
through `ReportSelection.PrintWithDialogForVend` — no customer's or
vendor's actually assigned Document Sending Profile is consulted by
either.

The unposted `Purchase Header`'s own `PrintRecords` is a partial exception
worth naming precisely: it calls `DocumentSendingProfile.TrySendToPrinterVendor(...)`,
but only as a stateless, never-`Get`'d local record carrying print-dialog
options, never a vendor's actually configured profile — that helper still
resolves the report through `ReportSelections.PrintWithDialogForVend(...)`,
the same as everywhere else.

Only the combined Post-and-Send flow resolves through Document Sending
Profile: `Sales-Post and Send` calls `Sales Invoice Header.SendProfile`,
which calls `DocumentSendingProfile.Send(...)`, which then decides
Print/Email/Disk/Electronic based on the customer's assigned profile and
only *then* calls back into `Report Selections` (for the PDF cases) or
`Electronic Document Format` (for machine-readable cases).

Whether a document needs outbound distribution at all isn't determined by
Customer-vs-Vendor, but by whether the document is genuinely *outbound* to
its counterparty. A posted Purchase Invoice records what a vendor already
billed you — nothing to send back — and its posted `Purch. Inv. Header`
exposes only a bare `PrintRecords`, no `SendProfile`/`SendRecords`/email at
all. A Purchase *Order* is genuinely outbound before posting, which is why
the full `SendProfile`/`SendRecords`/`PrintRecords` triplet lives on the
unposted `Purchase Header` instead.

## Best Practice

For a document's own interactive Print/Email actions, call the relevant
`Report Selections` procedure directly —
`PrintForCust`/`PrintWithDialogForCust`/`SendEmailToCust` for a
customer-facing document, `PrintWithDialogForVend`/`SendEmailToVendor` for
a vendor-facing one — using the usage value registered per
`extend-report-selection-usage-for-new-document-types.md`. Wire into
`Document Sending Profile` only when specifically building a combined
Post-and-Send action for that document. Before adding any send capability
at all, confirm the document is genuinely outbound to the counterparty
it's attached to; a document that only records something already received
needs print-for-reference at most, not a send path.

See sample: `document-print-and-email-actions-call-report-selections-directly.good.al`.

## Anti Pattern

Routing a document's plain, on-demand "Email" button through
`DocumentSendingProfile.Send`/`SendVendor` instead of calling
`ReportSelections.SendEmailToCust`/`SendEmailToVendor` directly. The
button's outcome now silently depends on that customer's or vendor's
assigned Document Sending Profile — if its `"E-Mail"` option happens to be
`No`, clicking "Email" does nothing observable, with no indication to the
user that a profile setting (meant for the Post-and-Send flow) is the
reason. A second version of the same mistake: adding an email action to a
document that only receives from its counterparty and was never meant to
send anything back.

See sample: `document-print-and-email-actions-call-report-selections-directly.bad.al`.

## Source

BCApps `DocumentPrint.Codeunit.al` (`EmailSalesHeader`/`DoPrintSalesHeader`/`PrintSalesOrder`,
calling `ReportSelections.SendEmailToCust`/`PrintForCust`/`PrintWithDialogForCust`
directly), `PurchaseHeader.Table.al` (`SendProfile` at line ~6387, calling
`DocumentSendingProfile.SendVendor`), `PurchInvHeader.Table.al` (`PrintRecords`
calling `ReportSelection.PrintWithDialogForVend` directly, no send capability),
`SalesPost.Codeunit.al`
(`SendPostedDocumentRecord` at line 7660 → `SalesInvHeader.SendProfile` at
lines 7680/7699 → `DocumentSendingProfile.Send`),
`DocumentSendingProfile.Table.al` (table 60; `TrySendToPrinterVendor` at
line 552 and `SendToPrinterVendor` at line 716, called from
`PurchaseHeader.PrintRecords` at line 6357) — all under
`src/Layers/W1/BaseApp/`. Microsoft Learn, "Set Up Document Sending Profiles":
https://learn.microsoft.com/dynamics365/business-central/sales-how-setup-document-send-profiles
