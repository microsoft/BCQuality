---
bc-version: [all]
domain: performance
keywords: [setautocalcfields, calcfields, calcsums, flowfield, loop, per-row]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SetAutoCalcFields when each iterated row needs a FlowField

## Description

`Record.SetAutoCalcFields` has been available since runtime 1.0 and makes the specified FlowFields calculate as records are retrieved. Microsoft's [AL database-method performance guidance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-al-database-methods-and-performance-on-server#setautocalcfields) uses it to remove an explicit `CalcFields` call from every iteration when each row's FlowField drives a branch. This is different from `CalcSums`, which returns a total for the filtered set rather than a value for each row.

## Best Practice

Call `SetAutoCalcFields` before `FindSet` when every returned row needs the same FlowField for a comparison, branch, or per-record action. Use `CalcSums` instead when the required result is one aggregate over the filtered set (see `calcsums-instead-of-calcfields-in-loop.md`).

See sample: `use-setautocalcfields-for-per-row-flowfields.good.al`.

## Anti Pattern

Calling `CalcFields` inside the loop when every iteration reads the same FlowField. Each `CalcFields` request requires a separate SQL statement unless a compatible recent result is cached. Do not replace row-specific decisions with `CalcSums`; an aggregate cannot preserve which rows met the condition.

See sample: `use-setautocalcfields-for-per-row-flowfields.bad.al`.
