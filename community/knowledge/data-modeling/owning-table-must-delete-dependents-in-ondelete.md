---
bc-version: [all]
domain: data-modeling
keywords: [ondelete, cascade, table-relation, orphan-records, header-line, dependent-records, referential-integrity]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A table that owns dependent records must delete them in `OnDelete`

## Description

`TableRelation` looks like referential integrity but only performs lookup and input validation. AL has **no cascading delete**: deleting a parent record leaves every dependent row untouched, and no error is raised.

What makes this specifically missable is an asymmetry. The platform *does* keep references correct on **rename** — renaming a record updates it in all other locations that declare a `TableRelation` to it, with no code. Delete has no equivalent. Same relation, same metadata, opposite behaviour. A developer who correctly learns that `TableRelation` "keeps references consistent" from the rename case, and generalises it to delete, ships orphans.

Orphaned rows are usually invisible, because a dependent table rarely has a page of its own. They inflate the table, break later reconciliation, and are re-encountered by duplicate checks when the parent key is reused.

This applies to internal, staging and `SystemMetadata` tables too. A table having no delete action in the UI today is not protection: a permission set that grants `D` on the table is evidence that deletion is anticipated.

See also `validate-table-relation-false-suppresses-rename-propagation.md` for the two preconditions on the rename half of this asymmetry.

## Best Practice

The owning table implements `OnDelete` and deletes its dependents there, filtered on the foreign key. Declare `Permissions = tabledata <dependent> = rd` on the owning table — granting delete rights only on the parent is a common miss that makes the trigger fail for a non-`SUPER` user. This mirrors the base application, where every header table deletes its own lines.

See sample: `owning-table-must-delete-dependents-in-ondelete.good.al`.

## Anti Pattern

A parent table with dependent rows and no `OnDelete` trigger, where the dependent's foreign-key field declares a `TableRelation` back to the parent. The relation reads as if it guarantees integrity; it does not.

Detection signal: a table declares `TableRelation` to table X, and table X has no `OnDelete` trigger. Whether a delete path currently exists in the UI is irrelevant to the finding.

See sample: `owning-table-must-delete-dependents-in-ondelete.bad.al`.
