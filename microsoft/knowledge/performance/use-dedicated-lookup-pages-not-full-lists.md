---
bc-version: [all]
domain: performance
keywords: [lookuppageid, lookup-page, list-page, factbox, table-relation, dropdown]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Point lookups at a dedicated lookup page, not the full list

> Contributions welcome — open a PR to refine or extend this article.

## Description

A `TableRelation` lookup opens the table's `LookupPageId`. If that is the full list page, the lookup runs that page's triggers, FactBoxes, and calculated fields even though the dropdown never shows them. The base application added dedicated Customer, Vendor, and Item lookup pages for this reason. Agents set `LookupPageId` to the main list because it already exists.

## Best Practice

Give master tables a slim lookup page (`PageType = List`, few columns, no FactBoxes, no heavy `OnAfterGetRecord`) and assign it to `LookupPageId`. Keep the full list for `DrillDownPageId` and the role-explorer entry.

See sample: `use-dedicated-lookup-pages-not-full-lists.good.al`.

## Anti Pattern

`LookupPageId = Page::"... List"` on a table that already has (or should have) a lookup page. Opening a field lookup then pays list-page cost. The signal is `LookupPageId` pointing at a page that declares FactBoxes or a wide repeater.

See sample: `use-dedicated-lookup-pages-not-full-lists.bad.al`.
