---
bc-version: [all]
domain: performance
keywords: [maintainsqlindex, sift, sumindexfields, flowfield, calcsums, key]
technologies: [al]
countries: [w1]
application-area: [all]
---

# MaintainSQLIndex = false on a key disables SIFT for the FlowFields that depend on it

## Description

SIFT relies on the underlying SQL index being maintained by the platform. Setting `MaintainSQLIndex = false` on a key drops the SQL index without dropping the AL key declaration — the key compiles, FlowFields that reference its SumIndexFields compile, and CalcSums calls against matching filters compile. At runtime, however, the SIFT optimization silently cannot engage, and every aggregate falls back to a table scan. The symptom is a FlowField whose read time degrades linearly with row count, with no code-level signal pointing at the key property as the cause.

## Best Practice

Keep `MaintainSQLIndex = true` (the default) on any key whose SumIndexFields back a FlowField or that callers use with CalcSums. When a key is genuinely unused and the SQL index cost is the concern, remove the key entirely rather than leaving it in place with `MaintainSQLIndex = false`. If the FlowField is still needed, pick a different key that is maintained.

## Anti Pattern

A source-table key declared with `SumIndexFields` and `MaintainSQLIndex = false`, with a FlowField referencing those sum fields. The FlowField appears to work in development against small datasets and becomes a full table scan on production-scale data, with no error message and no obvious culprit in the code under review.
