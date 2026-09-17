---
bc-version: [all]
domain: ui
keywords: [grid, fixed, data-table, heuristic, show-caption, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Grid and fixed-layout data-table heuristic

## Description

Business Central renders `grid()` and `fixed()` layouts in two modes. The mode is chosen automatically by a client heuristic. A grid renders as a **data table** (HTML `<table>` with row/column semantics) only when **all** of the following are true:

- All direct children of the grid/fixed are groups (no loose fields).
- Every child of every group is a field (no nested groups or other controls).
- All fields have `ShowCaption = false`.

The heuristic checks field captions only — group `ShowCaption` is not part of the check. A group with a visible caption inside a data-table grid does **not** break the heuristic and is not a violation. However, groups in a data table should also have `ShowCaption = false` for correct visual presentation.

Any grid or fixed layout that does not meet all three conditions renders as a layout table (visual column arrangement, no table semantics).

## Best Practice

If you intend a grid or fixed layout to render as a data table, satisfy all three conditions and verify the resulting markup matches your intent. If you do not need tabular semantics, prefer simple groups over grid or fixed layouts — they reflow better and produce correct semantic markup automatically.

See sample: [`grid-data-table-heuristic.good.al`](grid-data-table-heuristic.good.al).
