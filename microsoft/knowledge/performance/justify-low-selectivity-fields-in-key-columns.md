---
bc-version: [all]
domain: performance
keywords: [boolean, key, modifyall, selectivity, low-cardinality, leading-column, status-field, write-amplification, includedfields]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Justify low-selectivity fields in key columns

## Description

A Boolean, small Option/Enum, or status field (`Processed`, `Blocked`, `Status`) in a key is a cost that needs a reason. It widens every index row, and every write that changes the field also maintains the index. Whether it pays for itself depends on the reads: with equality filters on all leading columns, `(Processed, "Batch No.")` seeks on both, and for a queue whose unprocessed rows are a small slice of a large batch it can beat `("Batch No.")`. A read that does **not** filter the leading field gets no seek from the index at all, because SQL Server cannot skip an unfiltered leading column. This complements [read-pattern key design](design-covering-keys-from-read-pattern.md), which says which predicates a key should support but not what an added column costs.

## Best Practice

Before adding a low-selectivity field to a key's columns or to `IncludedFields`, name the read it serves and the evidence that it helps. Acceptable evidence includes:

- the read filters the field with an equality predicate on the rare side of a skewed distribution, as in a status queue;
- the key carries `SumIndexFields` for a FlowField or `CalcSums` that filters on the field, in which case the field must be in the key (see [FlowField SIFT keys](flowfield-source-key-needs-sumindexfields.md));
- the field is part of a required unique combination;
- a plan, telemetry, or index-usage measurement shows the read benefit outweighs the maintenance cost.

Weigh that benefit against how often the field is written. A field that the same process changes, for example through `ModifyAll(Processed, true)` after its loop, is maintained in the index on every such write, whether it sits in the key or in `IncludedFields`. Without a named read and evidence, leave the field as a residual predicate. Do not remove an existing justified state or queue index merely because the field has few values. See sample: [`justify-low-selectivity-fields-in-key-columns.good.al`](justify-low-selectivity-fields-in-key-columns.good.al).

## Anti Pattern

A key that **leads** with a low-selectivity field that the reads it is meant to serve do not filter. The index cannot be used for a seek by those reads, yet every write of the field still maintains it. Signals: a key starting with a Boolean, Option, Enum, or status field; a reader of that table that filters only later key fields; and often a `Modify` or `ModifyAll` of the leading field in the same process. Do not report a low-selectivity column merely for being low-selectivity: when a read filters it with equality, the finding needs workload, distribution, or plan evidence. See sample: [`justify-low-selectivity-fields-in-key-columns.bad.al`](justify-low-selectivity-fields-in-key-columns.bad.al).

## References

- [Table keys: benefits, costs, and constraints](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-keys).
- [Table keys and performance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-table-keys-and-performance).
- [Manage index usage (BC 2026 release wave 1 and later)](https://learn.microsoft.com/en-us/dynamics365/business-central/manage-indexes).
- [SQL Server index design guide](https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide).
- [SIFT and SQL Server](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sift-and-sql-server).
