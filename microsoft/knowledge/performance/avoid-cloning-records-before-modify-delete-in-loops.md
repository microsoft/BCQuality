---
bc-version: [all]
domain: performance
keywords: [clone, clone-before-write, copy, gettable, by-value, copied-record, writing-helper]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid cloning records before Modify or Delete in loops

## Description

Microsoft's [AL database-method performance guidance](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-al-database-methods-and-performance-on-server#insert-modify-delete-and-locktable) states that cloning an iterated record before `Modify` or `Delete` restarts the SQL `SELECT` and issues an extra SQL statement for every row. The runtime treats `Record.Copy`, `RecordRef.GetTable`, and passing a record by value to a writing helper as clones in this situation.

## Best Practice

Use `FindSet(true)` when the loop writes the traversed rows, and call `Modify` or `Delete` on that iterating record variable. If generic code is required, open and iterate the `RecordRef` directly instead of calling `GetTable` for each typed record. Keep a per-row loop when validation or row-specific behavior is required; this rule does not imply that `ModifyAll` or `DeleteAll` is equivalent.

See sample: `avoid-cloning-records-before-modify-delete-in-loops.good.al`.

## Anti Pattern

Inside an active traversal, copy the current row, convert it with `RecordRef.GetTable`, or pass it without `var` to a helper, then call `Modify` or `Delete` on that clone. Do not flag read-only snapshots, temporary records, or copies used to write a different target table; the documented extra-statement concern is clone-before-write on the traversed table.

See sample: `avoid-cloning-records-before-modify-delete-in-loops.bad.al`.
