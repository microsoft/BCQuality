---
bc-version: [all]
domain: breaking-changes
keywords: [table-field, obsoletestate, obsoletereason, obsoletetag, pending, removed, data-loss]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Obsolete published table fields instead of deleting or renaming them

## Description

A table field that has shipped carries two contracts at once: extensions reference it by name, and the database holds data in its column. Deleting the field, or renaming it (which the platform treats as drop-plus-add), breaks dependent code at compile time and discards the stored data — a silent data-loss event on upgrade. The fix is the same staged lifecycle used for objects: set `ObsoleteState = Pending` together with `ObsoleteReason` and an `ObsoleteTag` naming the target version, ship the new field alongside, migrate data during the window, and only switch the old field to `ObsoleteState = Removed` in a later release once nothing depends on it. LLMs often "tidy" a schema by renaming a field in place, not realizing this is both a breaking change and a data-loss risk.

## Best Practice

Add the replacement field, then mark the old field `ObsoleteState = Pending` with an `ObsoleteReason` that names the replacement and an `ObsoleteTag` carrying the target version (for example `'25.0'`). Keep the obsolete field readable so an upgrade codeunit can copy its data into the new field during the deprecation window. Move it to `ObsoleteState = Removed` only in a later major version, after the window has passed and data has migrated.

See sample: `obsolete-table-fields-instead-of-deleting-them.good.al`.

## Anti Pattern

Renaming the published `Email` field to `Contact Email` directly in the table — or deleting it — so dependent extensions that reference `Email` break and the column's stored values are orphaned on upgrade. Detection: a previously shipped field removed or renamed in a table or table extension with no `ObsoleteState = Pending` step preserving the original. Obsolete the field through the lifecycle instead.

See sample: `obsolete-table-fields-instead-of-deleting-them.bad.al`.
