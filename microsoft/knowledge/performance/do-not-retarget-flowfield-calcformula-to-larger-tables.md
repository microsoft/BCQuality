---
bc-version: [all]
domain: performance
keywords: [flowfield, calcformula, regression, source-table, sift]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not retarget a FlowField's CalcFormula to a larger source table

## Description

A FlowField's CalcFormula is evaluated every time the field is read — every time the page renders, every CalcFields call, every list page filter that references the field. Changing the CalcFormula's source table from a smaller, bounded, or already-filtered table to a larger unfiltered one multiplies the per-read cost. A common shape is the refactor from "Posted X" to "X" — the unposted line table is typically an order of magnitude larger and carries rows that the original FlowField never considered. The change compiles and may look like a simple scope widening; the performance impact is not visible until production load.

## Best Practice

When a FlowField CalcFormula changes source table, evaluate the before/after row counts, ensure a SIFT key exists on the new source that matches the formula's filters (see `add-sift-keys-for-flowfields`), and verify no existing callers rely on the tighter scope. If the widening is intentional, the corresponding SIFT keys on the new source must ship in the same PR.

## Anti Pattern

Changing a `sum("Posted Expense Report Line"."Amount" where(...))` formula to `sum("Expense Report Line"."Amount" where(...))` without touching the source table's keys. Every list page and dashboard that reads the FlowField now aggregates over the unposted table too, almost always without a supporting SIFT key.
