---
bc-version: [all]
domain: data-modeling
keywords: [no-series, primary-key, code20, oninsert, autoincrement, number-assignment]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A master table's `No.` primary key comes from a number series in `OnInsert`

## Description

In Business Central, a master table (Customer, Vendor, Item, and any custom equivalent) uses a single primary-key field named `No.` of type `Code[20]`. It is populated from a number series — configured on the feature's application-area setup table — inside the table's `OnInsert` trigger, but only when `No.` is still blank (so a user may still type a manual number when the series allows it). The record also keeps a non-editable `No. Series` `Code[20]` field recording which series produced the number.

This is not an `Integer` `AutoIncrement` key, a GUID, or the `SystemId`. Those are surrogate/system identifiers that users never see and cannot quote; BC's whole document flow — lookups, filtering, printed references, telephone support — depends on a short, human-readable, business-controlled `No.`. Use the modern assignment API described in `use-no-series-codeunit-not-noseriesmanagement.md`.

## Best Practice

`No.` `Code[20]` is the sole primary key; a non-editable `No. Series` `Code[20]` field records the source series. `OnInsert` checks `if "No." = ''`, reads the setup table, `TestField`s the configured series, stores it in `No. Series`, and assigns `No.` from the series.

See sample: `master-table-no-from-number-series-in-oninsert.good.al`.

## Anti Pattern

An `Integer` `AutoIncrement` (or GUID / `SystemId`) primary key used as the business key, with no `OnInsert` number assignment. Records get an opaque identifier no user can reference, and the master no longer participates in the standard numbering and manual-entry behavior every other BC master follows.

See sample: `master-table-no-from-number-series-in-oninsert.bad.al`.
