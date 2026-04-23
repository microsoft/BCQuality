---
bc-version: [all]
domain: performance
keywords: [maintainsiftindex, sift, calcsums, flowfield, write-cost]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose MaintainSIFTIndex by read-write ratio

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

`MaintainSIFTIndex` on a key decides whether the SIFT aggregate structure is updated on every `INSERT`, `MODIFY`, and `DELETE` that touches the key's fields. With `Yes`, `CalcSums` and FlowField reads are immediate — but every write pays the cost of updating the aggregate. With `No`, writes are cheaper but the first aggregate read after a change has to rebuild. Neither value is universally correct; the right choice depends on how often the aggregate is read versus how often the underlying rows are written.

## Best Practice

Measure read-to-write ratios for the key's SIFT fields under realistic workloads. Set `MaintainSIFTIndex = Yes` only on keys whose aggregates are read far more often than the rows are written (reporting keys on reference tables, dashboards). Set `No` on keys whose rows are written heavily and whose aggregates are read rarely (transactional ledger entries, import-staging tables).

See sample: `choose-maintainsiftindex-by-read-write-ratio.good.al`.

## Anti Pattern

Leaving `MaintainSIFTIndex = Yes` on every key by reflex or convenience. On write-heavy tables the cumulative cost turns every INSERT or MODIFY into several additional aggregate updates, and the impact compounds in batch imports and posting routines — often without any code-review signal that the property is the cause.
