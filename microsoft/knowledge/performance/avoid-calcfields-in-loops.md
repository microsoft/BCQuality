---
bc-version: [all]
domain: performance
keywords: [calcfields, flowfield, loop, n-plus-one]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not call CalcFields inside loops

## Description

CalcFields evaluates one or more FlowFields for the current record by issuing a separate SQL aggregation. Called inside a loop over a record set, it becomes an N+1 problem: one aggregate per row. For any non-trivial set on a ledger-entry-backed FlowField this is orders of magnitude slower than the equivalent batched query.

## Best Practice

Move CalcFields out of the iteration. If the total is what you need, use CalcSums on the filtered parent set. If row-by-row FlowField values are needed, reshape the computation so the aggregate runs once — for example by joining against a temporary table populated in a single batched query.

See sample: `avoid-calcfields-in-loops.good.al`.

## Anti Pattern

Calling CalcFields inside `repeat ... until Next() = 0` on a hot parent record is the textbook N+1 pattern. Even a modest parent set size (hundreds of rows) turns into thousands of round-trips.

See sample: `avoid-calcfields-in-loops.bad.al`.

