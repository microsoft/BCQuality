---
bc-version: [all]
domain: ui
keywords: [grid, fixed, layout-table, standalone-content, show-caption, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Standalone content in a layout-table grid

## Description

A non-editable field with `ShowCaption = false` is acceptable inside a layout-table grid **only when** the field is **standalone content** — it displays a value that is meaningful on its own (for example a status message or a description) and is **not** intended to label or be labeled by another field in the grid.

Layout tables have no `<th>` column headers, so a captionless field that is meant to participate in a tabular relationship with a neighbour has no accessible label at all.

## Best Practice

Reserve `ShowCaption = false` in a layout-table grid for non-editable, free-standing content cells. If a field's role is to label or annotate another field in the same grid, restructure the grid to meet the data-table conditions (see `grid-data-table-heuristic.md`) instead of hiding the caption.

See sample: [`standalone-content-in-layout-table.good.al`](standalone-content-in-layout-table.good.al).
