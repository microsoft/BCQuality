---
bc-version: [all]
domain: upgrade
keywords: [primary-key, field-type, breaking-change, integer-to-biginteger, existing-data]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Primary-key and field-type changes are safe only on tables without existing data

## Description

Primary-key changes and field-type changes (for example widening `Integer` to `BigInteger`) rewrite the on-disk layout of every row in the table. On a new feature table that ships in the same change as the modification, no rows exist and the change is free. On an existing table that already holds tenant data — base-app tables, ledger entries, anything that has been live across releases — the same change can fail outright (key uniqueness violations, value overflow on conversion) or require a full table rewrite during the upgrade window. Either way, the change needs an explicit migration design, not just a metadata edit.

## Best Practice

Treat primary-key and field-type changes as restricted to tables introduced in the same change. For changes on tables with existing data, design and ship the corresponding upgrade procedure (typically backed by `DataTransfer` and an upgrade tag) that guarantees the new layout is achievable for every row, and verify with concrete evidence that the existing values fit the new constraint (no PK collisions, no value-range overflow).

See sample: [`breaking-changes-only-on-tables-without-data.good.al`](breaking-changes-only-on-tables-without-data.good.al).

## Anti Pattern

Changing the primary key on a base-app table, or widening / narrowing a field type on a table that has been shipping for releases, with no accompanying upgrade plan. The change compiles cleanly and may even deploy on an empty-ish tenant, then fails on customers who actually have data.

See sample: [`breaking-changes-only-on-tables-without-data.bad.al`](breaking-changes-only-on-tables-without-data.bad.al).
