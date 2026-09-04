---
bc-version: [all]
domain: data-modeling
keywords: [dimensions, dimensionmanagement, global-dimension, shortcut-dimension, default-dimension, validateshortcutdimcode, createdim]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire dimension support through DimensionManagement, not ad hoc fields

> Contributions welcome — open a PR to refine or extend this article.

## Description

Adding dimension support to a custom master or document table is not just a matter of adding a `Code[20]` field. Business Central expects a specific set of hooks into `Codeunit "Dimension Management"` so a dimension value is validated, persisted as a Default Dimension record, and flows through to transactions the same way it does for every standard table. Skipping any one hook produces a field that looks correct in the designer but silently fails to save, validate, or carry through to postings.

## Best Practice

A master table should validate its dimension fields through `ValidateShortcutDimCode` and `SaveDefaultDim`, and create/delete the matching Default Dimension records in `OnInsert`/`OnDelete`. A document table should add Shortcut Dimension fields validated the same way, and call `CreateDim` to pull dimension values from the related master record whenever the field that attaches the document to that master changes.

See sample: `dimension-management-wiring.good.al`.

## Anti Pattern

Adding a dimension-looking field with only a `TableRelation` to Dimension Value, and no call into `DimensionManagement` at all. The field accepts input but never becomes a real Default Dimension record, so it does not validate against blocked values and does not flow into postings.

See sample: `dimension-management-wiring.bad.al`.
