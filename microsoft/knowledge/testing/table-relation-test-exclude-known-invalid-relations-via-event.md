---
bc-version: [all]
domain: testing
keywords: [table-relation-test, tablerelationsmetadata, onafterremovetablerelation, field-length, field-type]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Exclude a known-valid TableRelation exception via OnAfterRemoveTableRelation

## Description

Codeunit 134926 "Table Relation Test" walks every `TableRelation` field property in the app and fails the moment a related field's type or length doesn't match what the relation requires — the related field must match the largest related field's length, and its type must match (except a field may relate to both `Code` and `Text`, which resolves to `Text`). A field with a legitimate, intentional relation shape has no per-field override in its own object definition; the check runs across the whole app with no built-in escape hatch.

## Best Practice

Subscribe to `OnAfterRemoveTableRelation` and call the codeunit's own `RemoveTableRelation(TableRelationsMetadata, TableID, FieldID, RelatedTableID, RelatedFieldID)` to strike the one known-valid relation before the test evaluates it, scoped as narrowly as the exception actually is.

See sample: `table-relation-test-exclude-known-invalid-relations-via-event.good.al`.

## Anti Pattern

Excluding an entire table's relations (or disabling the whole test codeunit) to work around one known exception. This discards the check's coverage for every other relation on that table, or in the app, not just the one that needed an exception.

See sample: `table-relation-test-exclude-known-invalid-relations-via-event.bad.al`.
