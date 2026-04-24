---
bc-version: [all]
domain: upgrade
keywords: [datatransfer, initvalue, large-dataset, bulk-update, upgrade]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use DataTransfer to initialize large tables in upgrade; not FindSet plus Modify

## Description

An upgrade that populates a new field on millions of existing rows with a FindSet+Modify loop pays a round-trip and a per-row trigger invocation for every row — turning a multi-hour upgrade into a multi-day one on ledger-entry-scale tables. `DataTransfer` pushes the update to SQL as a single set-based operation using source filters and constant values, which is the supported platform mechanism for this scenario. The tradeoff: DataTransfer bypasses validation triggers and event subscribers — if the step depends on trigger logic, that has to be reconstructed explicitly.

## Best Practice

Use DataTransfer when initializing a new field on an existing table that **can contain more than 300,000 records**, or whenever a new field is added to an existing table and the initialization must run across all existing rows. Tables in the ledger-entry and document-line category reliably exceed this threshold; treat them as requiring DataTransfer by default.

Set tables, add source filters, add constant values, call CopyFields, clear, and repeat for additional slices. When trigger or subscriber behaviour is required, do that work separately against a filtered result set so the bulk update remains set-based.

See sample: `use-datatransfer-for-large-dataset-initialization.good.al`.

## Anti Pattern

`FindSet(true)` + `Modify()` in a loop as the initialization path for a new field across an entire existing table. The resulting upgrade time is proportional to the row count; for a ten-million-row ledger-entry table it is the single largest step in the release.

See sample: `use-datatransfer-for-large-dataset-initialization.bad.al`.
