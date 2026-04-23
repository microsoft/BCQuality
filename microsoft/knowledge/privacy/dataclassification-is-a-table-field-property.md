---
bc-version: [all]
domain: privacy
keywords: [dataclassification, table-field, page, api-page, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# DataClassification is a table-field property, not a page property

## Description

DataClassification governs how the platform handles a field's data in telemetry, data-subject requests, and retention tooling. It is declared on the table field, not on the page that displays the field. Pages — card pages, list pages, API pages — simply render fields sourced from a table. A privacy issue with classification is always an issue on the table definition; the page is a display surface.

## Best Practice

Flag missing or wrong DataClassification on the table field where the data lives. When a field is exposed through an API page or any other page type, the source table's classification governs. Do not report the same issue on every page that happens to include the field.

## Anti Pattern

Reporting a privacy finding on `page 50100 "Customer API"` because it exposes an email field, rather than on `table Customer`'s email field. Fix at the source; the page is not the offender and the same correction applied per-page produces churn without changing the data-classification story.
