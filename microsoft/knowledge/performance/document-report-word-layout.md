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

A document report — an invoice, statement, order confirmation, or any report meant to be printed, emailed, or exported as a single-record document — should default to a `Word` rendering layout rather than `RDLC`. RDLC layouts run in a sandboxed app domain that only lives for the current report invocation, which is slower for UI-related actions such as emailing the resulting document, than a Word layout, which is not subject to that sandbox constraint. This does not apply to every report: tabular/list reports with heavy aggregation or calculated columns are still often a better fit for RDLC or Excel.

## Best Practice

Set `DefaultRenderingLayout = Word` and define a `Word` layout for reports that represent one structured document per record. Reserve RDLC (or Excel) for reports that represent a data listing rather than a document.

See sample: `document-report-word-layout.good.al`.

## Anti Pattern

Defaulting a document report's layout to RDLC out of habit or because a template happened to use it. This inherits RDLC's sandboxed-app-domain performance cost with no benefit tied to the report's actual content or calculation needs.

See sample: `document-report-word-layout.bad.al`.
