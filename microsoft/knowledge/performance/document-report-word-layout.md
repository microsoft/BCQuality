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

For a document report — an invoice, statement, order confirmation, or any report meant to be printed, emailed, or exported as a single-record document — Microsoft's own guidance recommends a `Word` rendering layout over `RDLC`: "RDL layouts can result in slower performance with document reports, regarding actions that are related to the user interface (for example, like sending emails) compared to Word layouts," and "we recommend that you design Word layouts instead of RDL" for this report shape (see Sources). This is a documented recommendation, not a universal guarantee that Word outperforms RDLC for every workload, and it does not apply to every report: tabular/list reports with heavy aggregation or calculated columns are still often a better fit for RDLC or Excel.

## Best Practice

For document reports, prefer a `Word` layout (`DefaultRenderingLayout = Word`) over RDLC unless specific layout requirements favor RDLC. Reserve RDLC (or Excel) for reports that represent a data listing rather than a document.

## Sources

- [Report Design Overview](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-report-design-overview)
- [Creating an RDL layout report](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-report-performance)
- [Troubleshooting reports / Report performance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-reports-troubleshooting)

See sample: `document-report-word-layout.good.al`.

## Anti Pattern

Defaulting a document report's layout to RDLC out of habit or because a template happened to use it. This inherits RDLC's sandboxed-app-domain performance cost with no benefit tied to the report's actual content or calculation needs.

See sample: `document-report-word-layout.bad.al`.
