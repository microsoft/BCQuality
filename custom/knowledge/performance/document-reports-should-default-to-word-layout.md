---
bc-version: [all]
domain: performance
keywords: [report-layout, word-layout, rdlc, document-report, sandbox-app-domain, rendering]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Document reports should default to a Word layout, not RDLC

## Description

When a new or extended report is a document report — an invoice,
statement, order confirmation, or any report meant to be printed, emailed,
or exported as a single-record document — its default rendering layout
should be `Word`, not `RDLC`. This is Microsoft's own current
recommendation, not just a style preference: RDLC layouts run in a
sandboxed app domain that only lives for the current report invocation,
which is slower for UI-related actions (like sending the resulting
document by email) than a Word layout, which is not subject to that
sandbox constraint.

This does not apply uniformly to every report. Tabular/list reports with
heavy aggregation or complex calculated columns are still often a better
fit for RDLC (or Excel), because Word's table-based layout model doesn't
handle that as well. The distinguishing question is whether the report
represents one structured document per record (Word) or a data listing
(RDLC/Excel) — not "RDLC vs. Word" as a blanket choice.

## Best Practice

```al
report 50100 "Sales Quote Confirmation"
{
    // ...
    rendering
    {
        layout(Word)
        {
            Type = Word;
            LayoutFile = './Layouts/SalesQuoteConfirmation.docx';
            Caption = 'Word Layout';
        }
    }

    DefaultRenderingLayout = Word;
}
```

## Anti Pattern

```al
report 50100 "Sales Quote Confirmation"
{
    // ...
    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './Layouts/SalesQuoteConfirmation.rdl';
        }
    }

    DefaultRenderingLayout = RDLC;
}
```

Building a document report's default layout in RDLC by default — because
it's the more familiar tool, or because a template happened to use it —
inherits RDLC's sandboxed-app-domain performance cost for no reason tied
to the report's actual content or calculation needs.

## Source

Microsoft Learn, "Creating an RDL layout report" and "(Obsolete) Set the
Layout Used by a Report": "RDL layouts can result in slower performance
with document reports... we recommend that you design Word layouts
instead of RDL... reports are not impacted by the security constraints on
sandbox app domains like they are with RDL layouts" — and "Document
reports (not lists) that use a Word report layout are typically faster
than those that use an RDLC report layout." Verified 2026-08-12.
