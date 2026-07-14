---
bc-version: [all]
domain: performance
keywords: [maintainsiftindex, sift, calcsums, flowfield, write-cost]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose MaintainSIFTIndex by read-write ratio

> Contributions welcome — open a PR to refine or extend this article.

## Description

`MaintainSIFTIndex` on a key decides whether SQL Server maintains the SIFT indexed view as underlying rows change. With `Yes`, writes that affect the key or sum fields also maintain the indexed aggregate. With `No`, that SIFT indexed view is not maintained, so a compatible `CalcSums` or FlowField calculation is computed from the base table instead and may require scanning many rows. There is no deferred "first read rebuild" of the SIFT structure.

## Best Practice

Measure aggregate-read latency and write cost under realistic filters and volumes. Keep `MaintainSIFTIndex = true` when the maintained aggregate materially benefits frequent `CalcSums` or FlowField reads. Consider `false` when writes dominate and the less-frequent aggregate reads can tolerate calculation from the base table.

See sample: `choose-maintainsiftindex-by-read-write-ratio.good.al`.

## Anti Pattern

Leaving `MaintainSIFTIndex = Yes` on every key by reflex or convenience. On write-heavy tables the cumulative cost turns every INSERT or MODIFY into several additional aggregate updates, and the impact compounds in batch imports and posting routines — often without any code-review signal that the property is the cause.
