---
bc-version: [all]
domain: performance
keywords: [deleteall, bulk-delete, sql, ondelete, trigger-bypass, security-filtering, media, companion-fields]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use DeleteAll for filtered bulk deletion

> Contributions welcome — open a PR to refine or extend this article.

## Description

`DeleteAll(false)` is eligible for a set-based SQL delete with the record variable's filters applied, but it is not guaranteed to stay one statement. Microsoft documents that `DeleteAll` [reverts to individual calls](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-al-database-methods-and-performance-on-server#modifyall-and-deleteall) when the table has trigger code, related delete/global/database event subscribers, active security filtering, `Media` or `MediaSet` fields, or fields added through companion tables. Setting `RunTrigger` to false skips the base table `OnDelete` trigger, but [table-extension `OnBeforeDelete` and `OnAfterDelete` triggers still run](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-deleteall-method#remarks).

## Best Practice

Use filtered `DeleteAll(false)` for purpose-built staging or cleanup tables only after verifying that base-table `OnDelete` logic is unnecessary and that trigger code, related subscribers, security filtering, media fields, and companion fields do not add required per-row behavior or regress the bulk path. If deletion requires per-row business logic, keep an explicit triggered operation instead of simulating trigger execution separately.

See sample: `use-deleteall-for-filtered-bulk-deletion.good.al`.

## Anti Pattern

Iterating with `FindSet` + `Delete(false)` to clear a filtered staging batch that has no delete logic or fallback condition. The reverse mistake is assuming `DeleteAll` is always one SQL statement without checking the documented fallback conditions.

See sample: `use-deleteall-for-filtered-bulk-deletion.bad.al`.
