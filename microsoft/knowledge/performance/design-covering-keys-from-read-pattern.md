---
bc-version: [19..]
domain: performance
keywords: [includedfields, covering-index, secondary-key, filter, projection, selectivity, key, setrange]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Design a covering key from the measured read pattern

## Description

A secondary key should serve a particular read, not a list of fields that happen to look important. The order of key fields affects which filters and sort orders it can support; `IncludedFields` supplies non-key payload columns without making them ordered key columns. `SetCurrentKey` sets an order, not an index hint (see [sort guidance](setcurrentkey-sets-sort-order-not-index-hint.md)). Coverage alone does not make a query selective.

## Best Practice

For a costly, frequent read, establish its equality and range filters, joins, required ordering, actual SQL projection, cardinality, and existing physical indexes. Test a key whose leading fields support the useful predicates; for example, customer equality followed by a posting-date range. On a nonclustered secondary key, consider `IncludedFields` for small payload fields read but not filtered or ordered. Check the generated SQL (including implicitly selected and extension fields) before calling an index covering, and measure reads, sorts, lookups, latency, and write overhead. The [Database Missing Indexes page](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/database-missing-indexes) supplies candidates, not a mandate to add every suggested key.

`IncludedFields` requires runtime 8.0 (BC 19) or later and cannot be set on a primary or clustered secondary key. An included field does not participate in `SetCurrentKey` matching or maintain a SIFT sum. If the item is also a selective predicate or required ordering column, evaluate it as a key field instead. Respect table-extension key field-ownership restrictions. See sample: [`design-covering-keys-from-read-pattern.good.al`](design-covering-keys-from-read-pattern.good.al).

## Anti Pattern

Adding a key on output-only fields or requesting an unrelated `SetCurrentKey` ordering to "force" the optimizer to use that key, without establishing the read's filters or validating its plan. Do not report every uncovered read as a defect: a small table, a low-frequency query, or a write-heavy table may be better without another maintained index. See sample: [`design-covering-keys-from-read-pattern.bad.al`](design-covering-keys-from-read-pattern.bad.al).

## References

- [Table keys, included columns, and extension restrictions](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-keys).
- [IncludedFields property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-includedfields-property).
- [Table keys and performance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-table-keys-and-performance).
