---
bc-version: [all]
domain: performance
keywords: [temporary-table, in-memory, intermediate, working-set]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use temporary tables for intermediate data

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Temporary tables live in memory, not in SQL. They are the correct primary data structure for intermediate results, working sets, and lookup caches that do not need to outlive the current operation. Using a real persisted table for scratch data incurs database round-trips, transaction scope, and locking for data that has no business being persisted.

## Best Practice

Declare the record variable with `temporary` when the data is scratch. Populate it with Insert(false) to avoid firing triggers. Clear the table explicitly with DeleteAll when the variable's scope is long-lived (a SingleInstance codeunit or a reused session variable) and needs to be reset between uses.

See sample: `use-temporary-tables-for-intermediate-data.good.al`.

## Anti Pattern

Writing intermediate results to a real table, processing them, and deleting them afterwards performs the full cost of INSERT and DELETE operations on data that never needed to be transactional.

