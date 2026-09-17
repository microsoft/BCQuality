---
bc-version: [all]
domain: breaking-changes
keywords: [table-field, tableextension, relocation, field-id, obsoletestate, breaking-change, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Relocating a field to a tableextension in the same app is not a deletion

## Description

Moving a field out of a base-table definition (or a base-app layer modification of one) into a tableextension that `extends` the same table, within the same app and keeping the same field ID and name, is a relocation — not a deletion or a rename. After the move the field still exists on the table: `Rec."Field Name"` and the field ID resolve exactly as before, so dependent extensions that reference the field continue to compile. Nothing in the field's public contract is removed or renamed, so the deprecation lifecycle that protects a genuinely removed field does not apply. LLM reviewers frequently misread the two-sided diff — the field disappearing from the base object and reappearing in the tableextension — as a shipped field being deleted and illegally re-added under the same ID, and demand `ObsoleteState = Pending` staging that this refactor does not need.

## Best Practice

Recognize a field that is removed from a base table (or base-app layer) and re-declared in a tableextension of the same table, with the same field ID and name, as a same-app relocation. Do not flag it as a deleted or renamed shipped field, and do not require `ObsoleteState = Pending`, `ObsoleteReason`, `ObsoleteTag`, or a deprecation window for the move itself. The `obsolete-table-fields-instead-of-deleting-them` and `obsolete-pending-to-removed-staging` rules apply to fields that leave the table's contract entirely, not to fields relocated within the same app under an unchanged ID.
