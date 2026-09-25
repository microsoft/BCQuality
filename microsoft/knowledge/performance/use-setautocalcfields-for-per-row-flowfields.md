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

Call `SetAutoCalcFields` before `FindSet` when every returned row needs the same FlowField for a comparison, branch, or per-record action. For one total of a **stored source field**, consider `CalcSums` instead (see [stored-field totals versus FlowFields](calcsums-instead-of-calcfields-in-loop.md)). If the required result is a total of selected FlowField values, derive the underlying source filters from `CalcFormula`; do not sum the FlowField directly with `CalcSums`.

See sample: [`use-setautocalcfields-for-per-row-flowfields.good.al`](use-setautocalcfields-for-per-row-flowfields.good.al).

## Anti Pattern

Calling `CalcFields` inside the loop when every iteration reads the same FlowField. A compatible recent result can be cached, so do not equate each call with a SQL statement. Do not replace row-specific decisions with `CalcSums`; an aggregate cannot preserve which rows met the condition.

See sample: [`use-setautocalcfields-for-per-row-flowfields.bad.al`](use-setautocalcfields-for-per-row-flowfields.bad.al).
