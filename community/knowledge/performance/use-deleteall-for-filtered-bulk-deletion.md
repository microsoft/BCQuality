---
bc-version: [all]
domain: performance
keywords: [deleteall, bulk-delete, sql, ondelete, trigger-bypass]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use DeleteAll for filtered bulk deletion

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

`DeleteAll` translates to a single SQL `DELETE` with the record variable's current filters applied as the WHERE clause. A loop of `FindSet` + `Delete` instead issues one SQL statement per row. On any dataset larger than a handful of records, the gap is an order of magnitude or more. The tradeoff is that `DeleteAll` bypasses the `OnDelete` table trigger, so the decision hinges on whether that trigger's logic is required for this specific deletion.

## Best Practice

After narrowing the record set with `SetRange`/`SetFilter`, use `DeleteAll` whenever the `OnDelete` trigger has no logic that this call depends on — typically the case for housekeeping routines, staging-table cleanup, and deletions already validated upstream. When the trigger IS required, either keep the explicit loop-plus-`Delete` pattern and comment why, or pre-run the trigger logic against a temporary buffer and then `DeleteAll` the primary table.

See sample: `use-deleteall-for-filtered-bulk-deletion.good.al`.

## Anti Pattern

Iterating with `FindSet` + `Delete` to clear a filtered set of records that carry no meaningful `OnDelete` logic. Every row pays a full AL round-trip; on a ten-thousand-row cleanup the loop can take minutes where `DeleteAll` takes under a second.

See sample: `use-deleteall-for-filtered-bulk-deletion.bad.al`.
