---
bc-version: [all]
domain: ui
keywords: [grid, nested-grid, fixed, data-table, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Nested grids are not supported

## Description

A grid nested inside another grid is not a supported pattern in Business Central. Even if an inner grid independently meets the data-table heuristic, the outer grid fails because its groups contain non-field children (the inner grids). The result is broken table semantics for both layers.

Always flag a nested grid as a violation. The fix is to restructure the page so there is at most one grid in any branch of the layout tree, choosing either a data-table or a layout-table arrangement.

## Anti Pattern

Wrapping a working data-table grid inside another grid in an attempt to compose two tabular regions side by side. The outer grid silently degrades to layout-table rendering, the inner grid's headers are no longer associated with the outer structure, and editable fields with `ShowCaption = false` lose their labels.

See sample: [`no-nested-grids.bad.al`](no-nested-grids.bad.al).
