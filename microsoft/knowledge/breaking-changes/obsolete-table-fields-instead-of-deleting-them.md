---
bc-version: [all]
domain: breaking-changes
keywords: [table-field, obsoletestate, obsoletereason, obsoletetag, pending, removed, data-loss]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Obsolete published table fields instead of deleting, renaming, or renumbering them

## Description

A shipped table field carries both a source-level contract and persisted data. Renaming a field while retaining its ID is prohibited by AppSourceCop AS0005 and can break dependent extensions, but it is not inherently a drop-and-readd operation and should not be described as automatic data loss. Deleting the field or replacing it under a different ID is the data-loss risk: the old field storage is no longer represented unless data is migrated. The supported path is to keep the old field and obsolete it, add a replacement under a new ID, and migrate values before later removal.

## Best Practice

Keep the old field's ID, name, and type unchanged. Add the replacement as a separate field under an unused ID, then mark the old field `ObsoleteState = Pending` with an `ObsoleteReason` that names the replacement and an `ObsoleteTag` recording the obsoletion version. Keep the old field readable so an upgrade codeunit can copy its data during the deprecation window. Move it to `ObsoleteState = Removed` only in a later release, after the window has passed and data has migrated.

See sample: `obsolete-table-fields-instead-of-deleting-them.good.al`.

## Anti Pattern

Renaming published `Email` to `Contact Email` with the same ID violates the compatibility contract and AS0005, even though the retained ID does not itself imply a fresh empty column. Deleting `Email` or changing its ID additionally risks losing its stored values. Detection: any previously shipped field whose name changes at the same ID, or whose original ID disappears without the unchanged field being retained as `Pending` and its data migrated to a separate replacement field.

See sample: `obsolete-table-fields-instead-of-deleting-them.bad.al`.
