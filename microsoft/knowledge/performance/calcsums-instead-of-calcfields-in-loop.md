---
bc-version: [all]
domain: performance
keywords: [calcfields, calcsums, loop, flowfield, n-plus-one, aggregation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use CalcSums to aggregate, not CalcFields inside a loop

## Description

`CalcFields` materializes FlowField values for one record. Each call against a persistent table is "a separate SQL query"; running it inside a `repeat ... until Next() = 0` over a large table issues one query per row on top of the iteration itself. `CalcSums` answers the same aggregation question — "give me the sum of this FlowField over the filtered set" — as a single SQL statement. Per the upstream guidance, `CalcFields` inside loops on large persistent tables is "a performance problem"; the aggregation form is `CalcSums()`.

## Best Practice

When the procedure totals a FlowField (or several) across a filtered set, set the filters, then call `CalcSums("Field 1", "Field 2", ...)`. The platform issues one query; the result is read off the record's FlowField slot. Single `CalcFields` outside loops is fine, and `CalcFields` on the current row in a page's `OnAfterGetRecord` or in `OnValidate` is the standard pattern — those are per-action, not per-row over a large set.

See sample: [`calcsums-instead-of-calcfields-in-loop.good.al`](calcsums-instead-of-calcfields-in-loop.good.al).

## Anti Pattern

`if CustLedgerEntry.FindSet() then repeat CustLedgerEntry.CalcFields("Remaining Amount"); Total += CustLedgerEntry."Remaining Amount"; until CustLedgerEntry.Next() = 0;` — exactly the upstream-flagged shape. The iteration is the cheap part; the per-row `CalcFields` is what scales linearly with table size.

See sample: [`calcsums-instead-of-calcfields-in-loop.bad.al`](calcsums-instead-of-calcfields-in-loop.bad.al).
