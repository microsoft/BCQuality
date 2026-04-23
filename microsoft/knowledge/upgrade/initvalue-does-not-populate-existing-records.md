---
bc-version: [all]
domain: upgrade
keywords: [initvalue, field, upgrade, existing-records, migration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# InitValue on a new field does not populate existing rows

## Description

The `InitValue` property sets a field's default for rows created after the field exists. Rows that already exist when the field is added keep the data-type default (empty text, zero, false, epoch date) — InitValue does not retroactively apply. Shipping a new field with `InitValue = true` on an existing table produces a silently inconsistent dataset: new rows match the intended default, existing rows do not, and callers that do not distinguish the two read the wrong state for existing data.

## Best Practice

When adding a field to an existing table with a meaningful default, write an upgrade step that populates existing rows with the same value, guarded by its own upgrade tag. Use `DataTransfer` with `AddConstantValue` for set-based initialization (see `use-datatransfer-for-large-dataset-initialization`). Exceptions: brand-new tables, new Boolean fields where `false` is the correct value for existing rows, and informational fields where empty is an acceptable state.

See sample: `initvalue-does-not-populate-existing-records.good.al`.

## Anti Pattern

Adding `field(100; "Is Active"; Boolean) { InitValue = true; }` to an existing business table without upgrade code. New records are Active; every existing record is silently inactive. The bug surfaces later as "why is this data missing from the default report?"

See sample: `initvalue-does-not-populate-existing-records.bad.al`.
