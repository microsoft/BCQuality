---
bc-version: [all]
domain: data-modeling
keywords: [init, insert, primary-key, autoincrement, entry-no, record-variable, reuse, findset, transferfields, clear]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `Init()` keeps the primary key: reset it before inserting from a reused record variable

## Description

`Record.Init()` assigns default values to the fields of a record but, per Microsoft Learn, "Primary key and timestamp fields aren't initialized." A record variable that was just used to read (`Get`, `FindSet`/`Next`, `FindLast`), to copy (`TransferFields`), or to `Insert` still holds that record's key after `Init()`. If the code then assigns the other fields and calls `Insert` without assigning a new value to the key field(s) that distinguish the new row, it inserts with the old key, and the insert fails (or, with `if Insert() then;`, silently does nothing).

The case most often missed is an `AutoIncrement` key such as `"Entry No."`, because the code never assigns it on purpose. Learn states that the property assigns numbers automatically and that to insert a record you must "be sure that the value in this field is blank before you insert the record". A value left over from a preceding read is not blank.

The defect does not show while the table, or the filtered set the code reads first, is empty, so tests on fresh data pass. It appears once a matching row exists, or on the second iteration of an insert loop, where the variable holds the number the platform assigned on the first `Insert`.

## Best Practice

Make the key of the inserted row the key you intend, by one of these means:

- Read with one record variable and insert with another, so the insert variable never holds a read key.
- `Clear` the variable before `Init()` when the same variable must be reused.
- Reset an `AutoIncrement` key explicitly after `Init()` or `TransferFields`, as Base Application code does: `EDocMappingLog."Entry No." := 0;` after `TransferFields` in a copy loop in the E-Documents app, and `Rec."Entry No." := 0;` after `Rec.Init()` in the Data Archive app.

Not affected: a variable that has not read, copied or inserted anything since it was declared or cleared; code that assigns a new value to the key field(s) that distinguish each new row between `Init()` and `Insert()` (for example a `"Line No."` counter, while `"Document Type"` and `"Document No."` stay the same); the singleton shape `if not Get() then begin Init(); Insert(); end;`, where the failed `Get` read nothing; and temporary records, where Learn states that `AutoIncrement` does not work, so the code assigns the key itself.

See sample: [`init-does-not-reset-primary-key-before-reinsert.good.al`](init-does-not-reset-primary-key-before-reinsert.good.al).

## Anti Pattern

A record variable reads rows (or was just inserted), then `Init()` is called, fields other than the primary key are assigned, and `Insert` follows, with no `Clear`, no separate variable, and no new value for the key field(s) that distinguish the new row. A typical shape sums existing rows in a `FindSet` loop and then creates a new row with the same variable.

See sample: [`init-does-not-reset-primary-key-before-reinsert.bad.al`](init-does-not-reset-primary-key-before-reinsert.bad.al).

## References

- [Learn: Record.Init() method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-init-method), Remarks.
- [Learn: AutoIncrement property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-autoincrement-property), Remarks.
- [BCApps: E-Documents copy loop resetting `"Entry No."`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/EDocument/App/src/Integration/Send/EDocRecurrentBatchSend.Codeunit.al#L79-L84) on an [`AutoIncrement` key](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/EDocument/App/src/Mapping/EDocMappingLog.Table.al#L17-L21).
- [BCApps: Data Archive `Init()` followed by `"Entry No." := 0`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/DataArchive/App/src/DataArchiveMediaField.Table.al#L59-L67) on an [`AutoIncrement` key](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/DataArchive/App/src/DataArchiveMediaField.Table.al#L24-L29).
