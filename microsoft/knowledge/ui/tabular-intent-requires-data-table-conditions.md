---
bc-version: [all]
domain: ui
keywords: [grid, fixed, tabular-intent, data-table, accidental-mix, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Tabular intent requires data-table conditions

## Description

The most common accessibility bug in grid layouts is partially following the data-table conventions. A developer arranges fields with **tabular intent** — one field acts as a label or row header for another — but the grid does not satisfy all the data-table heuristic conditions. The client falls back to layout-table rendering, and the tabular relationships between fields are lost: a screen reader announces each field independently with no programmatic association.

Flag a grid as an accessibility issue when any of these are true:

- An editable field has `ShowCaption = false` and the grid does not meet all data-table conditions.
- Fields are arranged so that one field is clearly intended to label or describe another field (tabular data intent), but the grid does not meet all data-table conditions.

Both manifestations have the same root cause: tabular semantics were intended but the heuristic ultimately rendered the grid as a layout table.

## Anti Pattern

A single field that keeps its visible caption is enough to demote an entire would-be data-table grid into a layout table — and silently strip the labels off its sibling captionless fields. Either restructure to meet all three conditions, or restore captions on every editable field.

See sample: [`tabular-intent-requires-data-table-conditions.bad.al`](tabular-intent-requires-data-table-conditions.bad.al).
