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

Codeunit 134926 "Table Relation Test" (shipped in BCApps' test app — only consumers that depend on the BC test libraries can subscribe to it) reads Table Relations Metadata tenant-wide across every installed app, not just the current one, and fails the moment a related field's type or length doesn't match what the relation requires — the related field must match the largest related field's length, and its type must match (except a field may relate to both `Code` and `Text`, which resolves to `Text`). A field with a legitimate, intentional relation shape has no per-field override in its own object definition; the check runs with no built-in escape hatch. The validation test method itself is `[Scope('OnPrem')]`: it only runs from an on-premises test surface, not from a cloud-targeted test app, so this whole exception mechanism — and the check it works around — is only reachable where that test can actually execute.

## Best Practice

Subscribe to `OnAfterRemoveTableRelation` and call the codeunit's own `RemoveTableRelation(TableRelationsMetadata, TableID, FieldID, RelatedTableID, RelatedFieldID)` to strike the one known-valid relation before the test evaluates it, scoped as narrowly as the exception actually is. Because the test itself is `[Scope('OnPrem')]`, do not recommend subscribing to it as a way to guard a cloud-targeted app's test suite — the subscription has no effect where the test never runs.

See sample: `table-relation-test-exclude-known-invalid-relations-via-event.good.al`.

## Anti Pattern

Excluding an entire table's relations (or disabling the whole test codeunit) to work around one known exception. This discards the check's coverage for every other relation on that table, or in the app, not just the one that needed an exception.

See sample: `table-relation-test-exclude-known-invalid-relations-via-event.bad.al`.

## Source

The `OnAfterRemoveTableRelation` exclusion technique is drawn from Luc van Vugt's "How-to: Test your Table Relations (2)": https://www.fluxxus.nl/index.php/bc/how-to-test-your-table-relations-2/. The codeunit/event signature, the `[Scope('OnPrem')]` boundary, and the tenant-wide `Table Relations Metadata` scope described above were verified directly against BCApps' `codeunit 134926 "Table Relation Test"` source, not taken from the post.
