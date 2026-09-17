---
bc-version: [all]
domain: performance
keywords: [maintainsqlindex, key, sift, flowfield, sum, count, table-scan]
technologies: [al]
countries: [w1]
application-area: [all]
---

# MaintainSQLIndex = false on a key disables SIFT for FlowFields that depend on it

## Description

`MaintainSQLIndex = false` on a key tells the platform not to materialize that key as a SQL index. Per the upstream guidance, when a FlowField's source key carries that property, "SIFT cannot function, COUNT/SUM will table-scan." The flag is sometimes set to save write-path cost on a rarely-queried key, but if a `CalcFormula` aggregates through that exact key, the FlowField loses its index — every `CalcFields`/`CalcSums`/list-page filter that triggers it runs without one.

## Best Practice

When changing a key property to `MaintainSQLIndex = false`, find every FlowField whose `CalcFormula` filters on that key and verify another key covers the same fields. When adding a FlowField whose source table has only a `MaintainSQLIndex = false` key for its filter columns, add a fully-indexed key (or accept that the FlowField cannot ride SIFT and reshape the design — see `flowfield-source-key-needs-sumindexfields.md`).

See sample: [`maintainsqlindex-false-breaks-flowfield-sift.bad.al`](maintainsqlindex-false-breaks-flowfield-sift.bad.al).

## Anti Pattern

A FlowField whose `CalcFormula`'s `WHERE` columns line up with a key that has `MaintainSQLIndex = false`. The schema looks correct — the key exists, the SumIndexFields are listed — but at runtime the platform has no SQL index to use, and the aggregation table-scans on every invocation.
