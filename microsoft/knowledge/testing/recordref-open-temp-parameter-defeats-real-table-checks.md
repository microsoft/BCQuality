---
bc-version: [all]
domain: testing
keywords: [recordref, open, temporary, isempty, existence-check, uniqueness]
technologies: [al]
countries: [w1]
application-area: [all]
---

# RecordRef.Open with Temp = true cannot check the real table

## Description

`RecordRef.Open(No: Integer [, Temp: Boolean] [, CompanyName: Text])` always takes a real table number. When `Temp` is `true`, though, the `RecordRef` refers to a temporary instance of that table. That instance starts empty and never contains the persisted rows. Microsoft Learn's example opens table 27 temporarily and notes that `Find('-')` "returns false" because "there are no records in a temporary table". So `IsEmpty`, `Find*`, `Next`, `Get` or `Count` on a temp-opened `RecordRef` only sees rows the same code inserted into it. These calls can't answer "does this value already exist in the table?"

The defect is easy to miss at the call site. `Temp` is a positional, unnamed Boolean, the table number is genuine, and the code compiles without a diagnostic. The usual shape is a generate-until-unused loop: the code sets a range on a field and repeats `until RecRef.IsEmpty()`. That loop exits on its first pass and returns a value that may already exist. The defect then shows up later as a duplicate-key error or a wrong lookup, often only once the table holds data.

The shape occurs wherever `RecordRef` is used. This article sits in the testing domain because generic test-library helpers, which work on any table number, are where it typically appears. For how specific `LibraryUtility` helpers behave, including `GenerateRandomCode`'s temporary open, see [`use-generateguid-for-unique-test-fixture-values.md`](use-generateguid-for-unique-test-fixture-values.md). That article owns guidance on which helper to call.

## Best Practice

When the code that follows has to see persisted rows, open with `Temp = false` or omit the parameter. Learn's first example omits it so the table "will not be open as temporary table".

`Temp = true` is correct when the `RecordRef` is deliberately a scratch instance that never answers existence questions about the real table, for example:

- A field-validation sandbox: insert a temporary row, then `Validate` a field on it.
- Parsing a table view with `SetView` and reading `GetFilter`.
- Reading table metadata such as `SystemIdNo`.

See sample: [`recordref-open-temp-parameter-defeats-real-table-checks.good.al`](recordref-open-temp-parameter-defeats-real-table-checks.good.al).

## Anti Pattern

`RecRef.Open(<table>, true[, ...])` followed, on the same `RecordRef` and with no `Insert` into it, by `IsEmpty`, `Find`, `FindFirst`, `FindLast`, `FindSet`, `Next`, `Get` or `Count` whose result decides whether a value already exists in the table. The classic case is a uniqueness loop ending `until RecRef.IsEmpty()`.

See sample: [`recordref-open-temp-parameter-defeats-real-table-checks.bad.al`](recordref-open-temp-parameter-defeats-real-table-checks.bad.al).

## Source

- [RecordRef.Open method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/recordref/recordref-open-method): the syntax, Example 1 (parameters omitted, not temporary) and Example 2 (temporary open is empty, `Find('-')` returns false).
- BCApps [`src/Layers/W1/Tests/ApplicationTestLibrary/LibraryUtility.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/Tests/ApplicationTestLibrary/LibraryUtility.Codeunit.al): `GenerateRandomCode` opens with `true` at line 288 and loops `until RecRef.IsEmpty()`. `GenerateRandomCodeWithLength` opens with `false` at line 309.
- Legitimate `Temp = true` uses in BCApps W1:
  - [`src/Layers/W1/BaseApp/Inventory/Item/ItemTempl.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Inventory/Item/ItemTempl.Table.al) line 1255: temporary `Item` insert plus `Validate`.
  - [`src/Apps/W1/Quality Management/app/src/Utilities/QltyFilterHelpers.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Apps/W1/Quality%20Management/app/src/Utilities/QltyFilterHelpers.Codeunit.al) line 942: `SetView` plus `GetFilter`.
  - [`src/Layers/W1/BaseApp/Integration/SynchEngine/IntegrationRecordSynch.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Integration/SynchEngine/IntegrationRecordSynch.Codeunit.al) line 221: `SplitLocalTableFilter` splits a table filter, reading only `SystemIdNo` from the temporary open.
