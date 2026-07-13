---
bc-version: [21..]
domain: upgrade
keywords: [datatransfer, large-dataset, bulk-update, modifyall, copyfields, new-field]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use `DataTransfer` for bulk updates on large tables

## Description

Tables that can contain more than 300,000 records, and any newly added field on an existing table, should be initialized with `DataTransfer` rather than a `repeat ... Modify ... until Next() = 0` loop. `DataTransfer` issues a single set-based statement to the database; the loop/modify pattern issues one round-trip per row and accumulates write locks for the duration of the upgrade. On the volumes that drive upgrade pain — ledger entries, item ledger entries, price list lines — the difference is the upgrade running for minutes instead of hours.

## Best Practice

For a bulk update use a `DataTransfer` variable: call `SetTables(Database::"...", Database::"...")` (source and destination may be the same table), add filters with `AddSourceFilter`, set the target value with `AddConstantValue` (or copy a source field with `AddFieldValue`), and execute with `CopyFields()`. To express multiple distinct updates against the same table, `Clear` the `DataTransfer` between executions and configure the next one.

See sample: `datatransfer-for-bulk-init.good.al`.

## Anti Pattern

Iterating with `FindSet(true) ... repeat ... Modify() ... until Next() = 0` to set a single field across an entire large table. On 300k+ rows this is the canonical slow-upgrade footgun.

See sample: `datatransfer-for-bulk-init.bad.al`.

## See also

- `datatransfer-skips-triggers-and-subscribers.md` — `DataTransfer` does not raise field validation triggers or event subscribers; if a row needs validation logic, `DataTransfer` is the wrong tool.
