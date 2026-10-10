---
bc-version: [all]
domain: performance
keywords: [selectivity, low-cardinality, boolean-key, status-field, leading-column, key-width, write-amplification, includedfields]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep low-selectivity fields out of key columns

## Description

Not every filtered field earns a key column. A Boolean, a small Option/Enum, or a status flag (`Processed`, `Blocked`, `Status`) has few distinct values. As a **leading** key column it helps only reads that filter it with an equality predicate: a read that does not filter it cannot seek on that index, and a `<>` or range filter on it yields a broad range scan. As a **trailing** column, after selective columns have narrowed the range to a few rows, it saves almost nothing, because SQL Server evaluates the remaining rows as a residual predicate. In both positions it widens every index row and adds write cost, most of all when the process the key serves updates that same field. This complements [read-pattern key design](design-covering-keys-from-read-pattern.md), which says which predicates a key should support, not which ones it should leave out.

## Best Practice

Build key columns from the predicates the read **seeks on**, with the most selective equality filters first, for example `"Batch No."` or `"Customer No."`. Leave a low-selectivity filter as a residual predicate. Before adding any column, check whether the process the key serves also writes it with `Modify`, `ModifyAll`, or `Validate`. If it does, the column belongs neither in the key nor in `IncludedFields`: every such write also maintains the index, and an `UPDATE` reaches the clustered row anyway, so covering saves the writer no lookup. Where a low-selectivity sort is a functional requirement, remember that a matching key does not make the read selective (see [sort guidance](setcurrentkey-sets-sort-order-not-index-hint.md)). See sample: [`keep-low-selectivity-fields-out-of-key-columns.good.al`](keep-low-selectivity-fields-out-of-key-columns.good.al).

Legitimate exceptions, which a reviewer must not report:

- **SIFT.** A key whose `SumIndexFields` serves a FlowField or `CalcSums` must contain every field the `CalcFormula` or `CalcSums` filters on, in that order, selective or not; otherwise the platform cannot use the aggregate (see [FlowField SIFT keys](flowfield-source-key-needs-sumindexfields.md)).
- **Read-heavy covering.** For a FlowField `Count`/`Exist`, a `Query`, or a `CalcSums` without SIFT, a low-selectivity field the read needs may go into `IncludedFields` rather than the key, provided the process does not also update it.
- **Skewed distribution.** A field filtered on its rare value (for example `Status = Error` among mostly processed rows) can be selective despite its type. The justification must come from the actual data distribution, not from the field type.
- **Uniqueness.** A field that is part of a required unique combination stays in that key.

## Anti Pattern

A key that leads with a Boolean or status field, such as `(Processed, "Batch No.")`, or that appends one after selective columns merely because the read also filters it. The signal: a low-selectivity field appears in a key's field list or in `IncludedFields`, and the code that filters on it also changes it, typically through `ModifyAll(Processed, true)` after the loop. Every such write then moves rows in the index while the read gains nothing. See sample: [`keep-low-selectivity-fields-out-of-key-columns.bad.al`](keep-low-selectivity-fields-out-of-key-columns.bad.al).

## References

- [Table keys: benefits, costs, and constraints](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-keys).
- [Table keys and performance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-table-keys-and-performance).
- [SQL Server index design guide: column order and selectivity](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide).
- [SIFT and SQL Server](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sift-and-sql-server).
