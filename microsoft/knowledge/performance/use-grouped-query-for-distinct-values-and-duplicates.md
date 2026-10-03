---
bc-version: [all]
domain: performance
keywords: [duplicate, distinct, select-distinct, count, having, group-by, columnfilter, method-count, query]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use a grouped query for distinct values and duplicate detection

## Description

The AL `Record` type has no `SELECT DISTINCT` or `GROUP BY ... HAVING`. Code that must find which values of a field occur more than once in a table is therefore often written as a loop over the table that, for every row, filters a second record variable on that row's value and calls `Count()`. That sends one extra SQL statement per looped row, so an unfiltered loop costs as many statements as the table has rows, to answer a question about the whole table. A query object answers it in one statement: when any column has an aggregate `Method`, every other `column` becomes an implicit grouping key, so the dataset has one row per distinct combination. A `ColumnFilter` on a non-aggregated column is applied like a `WHERE` clause; a `ColumnFilter` on an aggregated column is applied like a `HAVING` clause, after grouping. A `Method = Count` column with `ColumnFilter = <column> = filter(> 1)` therefore returns only the duplicate groups. This complements [aggregate-before-persisting-intermediate-results](aggregate-before-persisting-intermediate-results.md), which covers grouped totals.

## Best Practice

Declare one plain `column` per field of the combination to check, plus a `column` with `Method = Count` and no source field. For a distinct list, read the rows and ignore the count. For duplicates, set `ColumnFilter` on the count column to `filter(> 1)`; one successful `Read()` proves a duplicate exists. Restrict rows with `SetRange`/`SetFilter` on plain columns, or with a `filter` element, which restricts rows but is not included in the dataset. Every extra `column` changes the grouping grain. A runtime `SetFilter` or `SetRange` on the count column replaces its `ColumnFilter` ([setfilter-overwrites-query-columnfilter](../query/setfilter-overwrites-query-columnfilter.md)). Base Application uses this shape to reject duplicate descriptions, for example query 762 "Acc. Sched. Line Desc. Count".

See sample: [`use-grouped-query-for-distinct-values-and-duplicates.good.al`](use-grouped-query-for-distinct-values-and-duplicates.good.al).

## Anti Pattern

A loop over a table (`FindSet` ... `Next`) that, for each row, sets a filter on a second record variable of the same table, over the same rows, to the current row's value and calls `Count()`, `IsEmpty()`, or `FindFirst()` only to learn whether the value occurs more than once. Do not flag:

- a single uniqueness check for one record, for example in `OnValidate` or before `Insert`;
- an outer loop bounded to one parent, such as the lines of one document, where the statement count does not grow with the table;
- a lookup against a different subset than the one being looped, for example looping quote lines and looking up contract lines;
- a loop that acts on each row it finds, such as marking or updating it, rather than only answering a table-level question;
- a loop where the record being filtered and counted is temporary, which makes no database calls.

See sample: [`use-grouped-query-for-distinct-values-and-duplicates.bad.al`](use-grouped-query-for-distinct-values-and-duplicates.bad.al).

## References

- [Aggregating data in query objects](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-query-totals-grouping): an aggregate `Method` groups the dataset by the other columns; a `Count` column takes only a name; "Using a query to get distinct values".
- [Filtering in query objects](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-query-filters): `ColumnFilter` can be applied to aggregated columns; filters on columns with a totals method correspond to a `HAVING` clause, others to `WHERE`; a filter row is not included in the dataset.
- Base Application: [AccSchedLineDescCount.Query.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/FinancialReports/AccSchedLineDescCount.Query.al#L15-L37) (query 762), used by `CheckDuplicateAccScheduleLineDescription` in [AccSchedChartManagement.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/FinancialReports/AccSchedChartManagement.Codeunit.al#L390-L398). The same shape appears in [ColmLaytColmHeaderCount.Query.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/FinancialReports/ColmLaytColmHeaderCount.Query.al) and [Inventory/Analysis/AnalysisLineDescCount.Query.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Inventory/Analysis/AnalysisLineDescCount.Query.al).
- A legitimate per-row lookup that this rule must not flag: [ServiceContractHeader.Table.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Service/Contract/ServiceContractHeader.Table.al#L2692-L2705) loops one quote's lines, looks up contract lines for each service item, and marks each hit.
