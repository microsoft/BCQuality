---
bc-version: [all]
domain: privacy
keywords: [data-classification, table-level, field-inheritance, tableextension, appsourcecop, as0016, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Table-level DataClassification is inherited by fields

## Description

A valid table-level `DataClassification` is the effective default for the Normal fields declared inside that table object when they do not declare their own value, and AppSourceCop AS0016 accepts those fields rather than reporting them as unclassified. A field-level value overrides that default only for the field on which it is set. The default does not cross object boundaries: a `tableextension` cannot set the table-level property, and the fields it adds do not inherit the base table's value, so every Normal field a table extension adds must classify itself. FlowFields and FlowFilters are handled separately by the platform and are covered by `flowfield-flowfilter-classification-systemmetadata.md`.

## Best Practice

Use a table-level classification when it accurately describes the table's fields, and add a field-level classification only where a field stores a different kind of data. Do not flag a Normal field solely because it omits an explicit property when its own table supplies a valid default; verify whether the inherited value matches the field's data instead. A `tableextension` has no default to inherit, so require an explicit `DataClassification` on every Normal field it adds.

See sample: [`table-level-data-classification-cascades.good.al`](table-level-data-classification-cascades.good.al).

## Anti Pattern

Reporting every Normal field without an explicit `DataClassification` when its own table already supplies a valid default, or requiring redundant field-level declarations that repeat the table value. The mirror-image mistake is waving through an unclassified Normal field added by a `tableextension` because the base table carries a default — a table extension inherits nothing. A real issue exists when neither scope supplies a valid classification, when a field's data requires an override of the inherited value, or when a Normal field added by a `tableextension` lacks a valid explicit `DataClassification`.
