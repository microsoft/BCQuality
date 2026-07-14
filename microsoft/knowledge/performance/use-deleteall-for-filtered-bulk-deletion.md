---
bc-version: [all]
domain: performance
keywords: [deleteall, bulk-delete, sql, ondelete, trigger-bypass]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use DeleteAll for filtered bulk deletion

> Contributions welcome — open a PR to refine or extend this article.

## Description

`DeleteAll(false)` is eligible for a set-based SQL delete with the record variable's filters applied. It is not guaranteed to stay one statement. The base table `OnDelete` trigger is skipped, but table-extension `OnBeforeDelete` and `OnAfterDelete` triggers still run. Extension event subscribers, global delete triggers, and media fields can also require row processing. `DeleteAll(true)` runs the base table `OnDelete` trigger as well and has no performance advantage over `Delete(true)` in a loop.

## Best Practice

Use filtered `DeleteAll(false)` for purpose-built staging or cleanup tables only after verifying that base-table `OnDelete` logic is unnecessary and installed extensions, subscribers, global triggers, and media fields do not add required per-row behavior or regress the bulk path. If deletion requires per-row business logic, keep an explicit triggered operation instead of simulating trigger execution separately.

See sample: `use-deleteall-for-filtered-bulk-deletion.good.al`.

## Anti Pattern

Iterating with `FindSet` + `Delete(false)` to clear a filtered staging batch that has no delete logic. The reverse mistake is assuming `DeleteAll` is always one SQL statement without checking table extensions and subscribers.

See sample: `use-deleteall-for-filtered-bulk-deletion.bad.al`.
