---
bc-version: [all]
domain: data-modeling
keywords: [primary-key, modify, rename, quantity, aggregation, temporary-buffer, insert]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Modify does not rename a record's primary key

## Description

Assigning a new value to a primary-key field on a retrieved AL record and calling `Modify` is not a rename of the stored row. This is easy to miss when a quantity being accumulated is itself part of the destination's primary key. Conversely, accumulating that quantity with `Modify` in a separate temporary buffer whose primary key excludes it is a valid pattern, even when the final persistent table includes quantity in its key.

## Best Practice

Read the table definition of the exact record variable receiving `Modify`; do not infer its key from the destination table or from a similarly named variable. Use `Modify` for non-primary-key updates. When an existing row really needs a new primary-key value, retain its original key in the record variable, calculate the new value separately, and pass the complete new key in declared order to `Rename`, including unchanged components.

`Rename` is not an unconditional replacement: check that the table permits renaming, the new key is unique, and the record is current. The API documents restrictions for tables with an `Option` field in the primary key and tables whose document number cannot be renamed for business or legal reasons. Do not generalize those restrictions to every composite key or every `Enum`. `Rename` does not run `OnModify`; keep any required non-key modification separate rather than assuming it is performed by the rename.

For repeated-row aggregation, a separate temporary buffer can use the complete grouping identity as its primary key and keep the accumulated quantity outside that key. Look up and populate the same normalized grouping values, modify only the buffer's non-key total, then insert one completed persistent row per group. Preserve distinctions such as receipt or lot; do not merge rows merely because their item matches. Temporary storage alone is not the fix: a temporary variable of the original table still has that table's key.

A `Record ... temporary` variable and a table declared `TableType = Temporary` both support this pattern; the latter needs runtime 6.0 / BC 17 or later. A plain record variable can therefore still be temporary because of its table definition. Do not report a primary-key mutation when the changed field is non-key in that actual buffer, or when key fields are assigned before a new row's `Insert`. Neither a permitted record rename nor a separate buffer changes the published destination table's key schema.

See sample: [`modify-does-not-rename-primary-key.good.al`](modify-does-not-rename-primary-key.good.al).

## Anti Pattern

Retrieving a row, changing its key quantity in place, and calling `Modify` as though it would move that row to the new key. Switching to `Modify(true)` only requests `OnModify`; it does not select the rename operation. The mirror-image review error is carrying this finding forward after aggregation has moved to a separate buffer with a non-key quantity. Establish the receiver's actual key and the read-to-write path before reporting either case.

See sample: [`modify-does-not-rename-primary-key.bad.al`](modify-does-not-rename-primary-key.bad.al).

## References

- [Record.Rename: primary-key changes, restrictions, freshness and OnModify](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-rename-method).
- [Record.Modify: updating a record and the RunTrigger argument](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-modify-method).
- [Table keys: primary-key identity and uniqueness](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-keys).
- [Temporary tables: record variables and table definitions](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-temporary-tables).
- [TableType: Temporary starts at runtime 6.0](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-tabletype-property) and [runtime-to-BC version mapping](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-choosing-runtime).
- Related, distinct concerns: [published key schemas](do-not-change-primary-key.md) and [aggregation performance](../performance/aggregate-before-persisting-intermediate-results.md).
