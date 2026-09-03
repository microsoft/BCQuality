---
bc-version: [all]
domain: ui
keywords: [factbox, subpagelink, listpart, cardpart, page-part, related-information, flowfield-sift]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Filter ListPart FactBoxes With SubPageLink To The Parent Record

> Contributions welcome — open a PR to refine or extend this article.

## Description
A FactBox is a page `part` that surfaces related data beside the main record so users avoid navigating away. Every FactBox runs a database query as its host page loads, so an unfiltered one is a hidden performance tax paid on every page open. The remedial trap: a `ListPart` FactBox with no `SubPageLink` does not show "the related rows" — it loads and pages through the entire source table, because nothing ties it to the host record. This makes correct `SubPageLink` linkage, not visual layout, the load-bearing design decision.

## Best Practice
Give every `ListPart` FactBox a `SubPageLink` that maps a field on the part's source table to a `field()` of the host record (for example `SubPageLink = "Document No." = field("No.")`), so it returns only rows belonging to the current record. Prefer a `CardPart` when you only need summary figures (balance, availability, status) — it reads a single record and avoids list overhead entirely. When a FactBox shows FlowFields, ensure the calculated total is backed by a SIFT key (`MaintainSIFTIndex`) so the sum is read from the index rather than aggregated row-by-row on each load. Keep FactBox count modest and avoid heavy `OnAfterGetRecord` logic in the part.

## Anti Pattern
Adding a `ListPart` FactBox without a `SubPageLink`, expecting it to "just show related lines." The consequence is a full-table scan on every page load that grows with the dataset and is felt worst on list pages, where the FactBox re-queries on each row selection. Reviewer signal: any `part(...)` referencing a list-type page part where the `SubPageLink` property is absent, or a FactBox FlowField filtered on non-indexed fields. A second smell is duplicating data already on the page or stacking many FactBoxes, which multiplies queries for little context gain.
