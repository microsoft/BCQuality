---
bc-version: [all]
domain: performance
keywords: [flowfield, sumindexfields, sift, key, calcformula, aa0232]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A FlowField needs a source-table key that covers its CalcFormula

## Description

A FlowField is computed by SQL on demand. CodeCop AA0232 — "FlowFields should be indexed with SumIndexFields on corresponding keys" — captures the indexing requirement: the source table must declare a key that includes the fields the `CalcFormula` filters on, with the aggregated field listed in that key's `SumIndexFields`. When that alignment is in place, the platform answers `CalcFields`/`CalcSums` from SIFT; without it, the same query falls back to a row-by-row aggregation on what is often a ledger-scale table. Per the upstream guidance, "Missing SIFT indices cause performance issues on List pages."

## Best Practice

When introducing or changing a FlowField, walk the `CalcFormula`'s `WHERE` clause field by field and verify the source table has a key whose key fields cover those filters, with the aggregated field in `SumIndexFields`. The same applies when the destination side of the FlowField filter is a list-page column: the page filter triggers the FlowField on every visible row, and only SIFT keeps that affordable.

See sample: [`flowfield-source-key-needs-sumindexfields.good.al`](flowfield-source-key-needs-sumindexfields.good.al).

## Anti Pattern

A `sum` FlowField against a large source table with no matching SIFT key. Each calculation aggregates rows directly; on a ledger-sized source the FlowField becomes the slowest column on every page that displays it. Pointing an existing FlowField's `CalcFormula` at a larger source table without verifying the new source's keys is the same trap a step removed — the upstream review guidance flags it as "CalcFormula changed to larger source table".

See sample: [`flowfield-source-key-needs-sumindexfields.bad.al`](flowfield-source-key-needs-sumindexfields.bad.al).
