---
bc-version: [all]
domain: performance
keywords: [report-layout, word-layout, rdlc, document-report, sandbox-app-domain, rendering]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Document reports should default to a Word layout, not RDLC

> Contributions welcome — open a PR to refine or extend this article.

## Description
A document report — an invoice, statement, order confirmation, or any report meant to be printed, emailed, or exported as a single-record document — should default to a `Word` rendering layout rather than `RDLC`. This is Microsoft's own documented recommendation, not a style preference: RDLC layouts run in a sandboxed app domain that only lives for the current report invocation, which makes UI-adjacent actions like emailing the resulting document slower than the equivalent Word layout, which isn't subject to that sandbox constraint. Tabular or list reports with heavy aggregation are a separate case and often still fit RDLC or Excel better — the deciding question is whether the report is one structured document per record, not "RDLC vs. Word" as a blanket choice.

## Best Practice
Set `DefaultRenderingLayout = Word` on a document report and provide a `.docx` layout file, reserving RDLC for reports whose output is a data listing rather than a per-record document — the shape Word's table-based layout model handles poorly.

## Anti Pattern
Defaulting a new document report to RDLC because it's the more familiar tool, or because a copied template happened to use it, inherits RDLC's sandboxed-app-domain performance cost for a report shape that gains nothing from it. A reviewer can spot this by a document-style report (single record, Header/Lines, meant for printing or emailing) whose `DefaultRenderingLayout` is `RDLC` with no data-listing/aggregation reason for the choice.
