---
bc-version: [all]
domain: upgrade
keywords: [initvalue, new-field, existing-rows, default-value, table-extension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `InitValue` does not back-fill existing rows

## Description

`InitValue` on a field defines the value the platform assigns when a *new* record is inserted. It does not touch rows that already exist when the field is added. When a new field is added to an existing table — directly or via a table extension — every pre-existing row receives the datatype default (`false` for Boolean, `0` for numeric, empty for text), not the `InitValue`. If the intended semantics require existing rows to carry the `InitValue`, the change is incomplete without an upgrade routine that sets the field on those rows.

Several legitimate cases do NOT need upgrade code:
- New fields on brand-new tables (no existing rows).
- New `Boolean` fields without `InitValue` where the datatype default `false` is the intended value.
- New fields on configuration / setup tables that have no meaningful "existing data".
- Informational or optional fields (logging, preferences, tracking) where `false` / empty is a valid state.

## Best Practice

When a new field on an existing table has an `InitValue` that matters, ship an upgrade procedure that walks the existing rows and sets the field to the same value — typically via `DataTransfer.AddConstantValue` for performance — guarded by an upgrade tag.

See sample: [`initvalue-does-not-update-existing-rows.good.al`](initvalue-does-not-update-existing-rows.good.al).

## Anti Pattern

Adding a field with `InitValue = true;` (or any non-default `InitValue`) and shipping no upgrade code. Existing rows silently carry the datatype default, leaving the table in two states: rows created before the upgrade with the wrong value, and rows created after with the right one.

See sample: [`initvalue-does-not-update-existing-rows.bad.al`](initvalue-does-not-update-existing-rows.bad.al).
