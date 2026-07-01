---
bc-version: [all]
domain: data-modeling
keywords: [setup-table, insertallowed, deleteallowed, getrecordonce, primary-key, card-page]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A setup table is a singleton: one blank-keyed row, no insert or delete

## Description

An application-area setup table (`Sales & Receivables Setup`, `Inventory Setup`, and any custom `* Setup`) holds exactly one record per company. Its primary key is a single `Code[10]` field named `Primary Key`, and the row's value is left blank. Nothing else identifies the row — there is only ever one.

The setup **card** page enforces the singleton: `InsertAllowed = false` and `DeleteAllowed = false` stop a second row or an empty table, and the page guarantees the row exists on first open — typically `OnOpenPage` with `if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end;`, or a `GetRecordOnce` helper on the table. Consuming code then reads it with a plain `Get()`. The read side needs no access optimization — see `singleton-setup-tables-need-no-access-optimization.md`.

## Best Practice

`Primary Key` `Code[10]` is the sole key; the setup is surfaced through a Card page with `InsertAllowed = false`, `DeleteAllowed = false`, and an open-time guard that inserts the blank row if it is missing.

See sample: `setup-table-is-a-singleton.good.al`.

## Anti Pattern

An `Integer` / `AutoIncrement` key, a page that allows insert or delete, or a List page over the setup table. Any of these lets the table hold zero or many rows, so "the setup" becomes ambiguous and `Get()` may fail or read the wrong record.

See sample: `setup-table-is-a-singleton.bad.al`.
