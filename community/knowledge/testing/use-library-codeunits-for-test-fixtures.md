---
bc-version: [all]
domain: testing
keywords: [library-codeunits, fixtures, test-data, number-series, prerequisite]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Build fixtures with the test Library codeunits, not hand-rolled Init/Insert

## Description

BC ships a layer of test Library codeunits — `LibrarySales`, `LibraryPurchase`, `LibraryERM`, `LibraryInventory`, `LibraryRandom` and many more — whose job is to create valid records. `CreateCustomer` assigns a number from the customer number series, fills the mandatory fields, and satisfies the table relations the platform enforces; `CreateItem` does the same for items. Hand-rolling `Customer.Init`/`Customer.Insert` with invented values skips the number series and any field a future app version adds as mandatory, so the fixture is invalid the moment it is created and rots silently as the schema evolves. Prefer the Library codeunits for prerequisite data: they encode the setup the platform requires and are maintained alongside the base app.

## Best Practice

Reach for the matching Library codeunit before writing manual record setup: `LibrarySales.CreateCustomer`, `LibrarySales.CreateSalesHeader`/`CreateSalesLine`, `LibraryInventory.CreateItem`, `LibraryERM.CreateGLAccount`, and `LibraryRandom.RandInt`/`RandDec` for values. Pass the records they return into the code under test. The fixtures stay valid across upgrades because the library — not your test — owns the knowledge of what a well-formed record requires.

See sample: `use-library-codeunits-for-test-fixtures.good.al`.

## Anti Pattern

`Customer.Init(); Customer."No." := 'X'; Customer.Insert();` — a record with a hand-picked primary key, no number-series entry, and none of the mandatory fields a real customer needs. It compiles and may even insert, but it bypasses setup the production code assumes, and it breaks the first time the schema gains a required field the test does not know about.

See sample: `use-library-codeunits-for-test-fixtures.bad.al`.
