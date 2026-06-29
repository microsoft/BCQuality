---
bc-version: [all]
domain: testing
keywords: [tablerelation, prerequisite, validate, foreign-key, test-data]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Create related records before inserting test data that points to them

## Description

A field with a `TableRelation` is checked when you `Validate` it or call `Insert(true)`: the platform confirms the referenced parent record exists. Test data assembled bottom-up — a sales line before its item, a ledger entry before its account — fails this check with a relation error, again a runtime abort rather than an assertion. Order matters: every record a foreign key points to must already exist when the dependent record is validated or inserted. The fix is to build fixtures top-down, parent before child, so each `TableRelation` resolves.

## Best Practice

Create prerequisite records first, then reference their primary keys from dependent records. Use the test Library codeunits, which create valid parents that satisfy mandatory fields and number series: `LibraryInventory.CreateItem` before a sales line that points at it, `LibrarySales.CreateCustomer` before a sales header. `Validate` the foreign-key field so the relation — and any field-validation logic — runs exactly as it would in production.

See sample: `tablerelation-requires-prerequisite-records.good.al`.

## Anti Pattern

Assigning an invented foreign key — `SalesLine."No." := 'GHOST'` — and calling `Insert(true)` (or `Validate`) without creating the parent. The `TableRelation` check rejects the row, the test aborts before its assertions, and the failure reads as a data error instead of the missing-setup bug it is.

See sample: `tablerelation-requires-prerequisite-records.bad.al`.
