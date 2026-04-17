---
bc-version: [26..28]
domain: performance
keywords: [calcsums, sift, sum, aggregate, totals]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use CalcSums to aggregate filtered sets

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

When the task is to compute a sum over a filtered set, CalcSums lets the platform push the aggregation down to SQL using SIFT indexes. Iterating rows in AL to accumulate a total transports every row's data to the runtime only to discard it after adding one field. On ledger-entry-scale tables this difference is dramatic. The same SIFT infrastructure backs Sum-style FlowFields; when the value you need is already declared as a FlowField, calling CalcSums on the underlying table with the correct filters produces the same aggregate.

## Best Practice

Set the required filters on the record, then call CalcSums on the field you want aggregated. Ensure the table has a key whose SumIndexFields includes the summed field and whose key prefix matches the filters (see add-sift-keys-for-flowfields).

See sample: `samples/performance/use-calcsums-for-flowfield-totals/good.al`.

## Anti Pattern

Looping a filtered set with FindSet and adding a field to an accumulator on every iteration performs work in AL that SQL already knows how to do in one aggregate query.

See sample: `samples/performance/use-calcsums-for-flowfield-totals/bad.al`.

