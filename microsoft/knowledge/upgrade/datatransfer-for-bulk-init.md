---
bc-version: [21..]
domain: upgrade
keywords: [datatransfer, findset, modify, bulk-update, copyfields, new-field, modifyall, field-copy]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer `DataTransfer` for set-based upgrade field updates

## Description

`DataTransfer` performs supported field initialization and field-to-field copies using set-based SQL instead of per-record AL writes. There is no minimum record count for using it; the benefit of avoiding per-row work grows with the data, and an upgrade must handle the data in each company. BCQuality recommends choosing a safe set-based operation during design, without waiting for the table to become large.

## Best Practice

In upgrade code, prefer `DataTransfer` over an otherwise equivalent `FindSet ... Modify ... Next` loop, regardless of current record count. Use `SetTables` (the same table for an in-place update), `AddSourceFilter`, `AddConstantValue` or `AddFieldValue`, then `CopyFields`. Clear the variable before configuring a different transfer.

Check that the tables and fields are supported and that the filters and field mappings preserve the intended result. Non-SQL, system, and virtual tables are not supported; the destination must not be audited or obsolete. For cross-table field copies, use `AddJoin` on source fields that identify source rows uniquely; the runtime rejects non-unique joins. Only matching destination rows are updated. Before bypassing row-level logic, apply [the trigger and subscriber guidance](datatransfer-skips-triggers-and-subscribers.md); a newly added field alone does not establish that the bypass is safe.

Keep record-based processing when required validation, table triggers, subscribers, or transformations cannot be preserved by the transfer. A value computed once and applied to a filtered set can still be a `DataTransfer` constant. Explain a non-obvious constraint rather than choosing a loop solely because the current table is small. An equivalent existing `ModifyAll` call and a `Get`/`Modify` update of one known record are not violations merely because they do not use `DataTransfer`.

See sample: [`datatransfer-for-bulk-init.good.al`](datatransfer-for-bulk-init.good.al).

## Anti Pattern

An unbounded upgrade loop that only assigns a constant or copies a field and calls `Modify`, when an equivalent `DataTransfer` is supported and no required per-row effects would be lost. Assuming that `DataTransfer` is available only above a row-count threshold is also incorrect. Do not infer a material performance defect from an operation whose row count is bounded by design (for example, one setup record) or from the absence of `DataTransfer` alone; the preference does not justify dropping required business logic.

See sample: [`datatransfer-for-bulk-init.bad.al`](datatransfer-for-bulk-init.bad.al).

## References

- [Microsoft Learn: Transferring data between tables using DataTransfer](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-data-transfer) — set-based operations, supported tables, and source-join uniqueness.
- [Use ModifyAll only for equivalent bulk assignments](../performance/prefer-modifyall-over-per-row-modify.md) — the existing set-based alternative and its semantic constraints.
