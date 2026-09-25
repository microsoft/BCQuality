---
bc-version: [all]
domain: performance
keywords: [calcfields, calcsums, loop, flowfield, source-field, sumindexfields, aggregation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use CalcSums for stored-field totals, not as a shortcut for FlowFields

## Description

`CalcFields` evaluates a FlowField for one record; `CalcSums` totals stored numeric fields in a filtered source table. They do not generally answer the same question. A loop that adds a normal source field for one total can often use one `CalcSums`, possibly backed by a compatible SIFT index. A loop that adds calculated FlowFields cannot be replaced with `CalcSums` on those FlowFields: each `CalcFormula` may depend on its parent record, FlowFilters, and the selected parent set. `CalcFields` requests can also use a recent calculation cache, so source-level call counts are not SQL statement counts.

## Best Practice

When only one total over stored source fields is needed, set the source-table filters and call `CalcSums` on those fields; select an appropriate current key with `SumIndexFields` when relying on SIFT, and measure the read/write trade-off. If the inputs are FlowFields, derive any proposed source aggregation from their `CalcFormula`, including the selected parent set and FlowFilters, and verify equivalent results before replacing the loop. When every row needs its own FlowField value, [use `SetAutoCalcFields`](use-setautocalcfields-for-per-row-flowfields.md) where appropriate rather than replacing row values with one total. See [SIFT trade-offs](choose-maintainsiftindex-by-read-write-ratio.md).

See sample: [`calcsums-instead-of-calcfields-in-loop.good.al`](calcsums-instead-of-calcfields-in-loop.good.al).

## Anti Pattern

Looping over filtered `Cust. Ledger Entry` records and adding the stored `"Sales (LCY)"` field when the only output is its total. The opposite mistake is proposing `Customer.CalcSums(Balance)` as a generic replacement for adding selected customers' FlowField balances; that changes or fails to express the required calculation.

See sample: [`calcsums-instead-of-calcfields-in-loop.bad.al`](calcsums-instead-of-calcfields-in-loop.bad.al).

## References

- [CalcFields and CalcSums operate on different field calculations](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-calcfields-calcsums-fielderror-fieldname-init-testfield-and-validate-methods).
- [Record.CalcSums](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-calcsums-method).
