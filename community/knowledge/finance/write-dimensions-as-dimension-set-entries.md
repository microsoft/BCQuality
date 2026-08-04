---
bc-version: [all]
domain: finance
keywords: [dimensions, dimension-set-id, dimension-set-entry, global-dimension, shortcut-dimension, dimensionmanagement]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Treat the Dimension Set ID as the source of truth for dimensions

## Description

Modern Business Central stores the dimensions of a record as a single `Dimension Set ID` that points at an immutable combination of `Dimension Set Entry` rows. The `Global Dimension 1 Code` / `Global Dimension 2 Code` fields and the `Shortcut Dimension 3..8` fields are denormalized projections the platform keeps in sync — they are not the source of truth, and they cover only a handful of the up to eight dimensions a set can hold. New or merged dimension combinations are obtained from codeunit `DimensionManagement` (for example `GetDimensionSetID`), which returns the `Dimension Set ID` to store on the record.

## Best Practice

When code sets, copies, or merges dimensions, work in terms of `Dimension Set ID` values and resolve or create them through `DimensionManagement`; assign the resulting set ID to the record and let the platform derive the global and shortcut projections. On records that expose shortcut-dimension fields (journal and document lines), call `Validate` on those fields — the field's logic updates the `Dimension Set ID` for you. To combine dimensions from several sources (document plus customer, header plus line) use the dimension-set combination routines instead of copying individual codes.

## Anti Pattern

Direct assignment (`:=`) to `Global Dimension 1 Code` or `Global Dimension 2 Code`, or reading those fields to determine "the dimensions," as if they were the record's dimension state. Detection signal: an assignment of a global/shortcut dimension field with no corresponding `Dimension Set ID` update, or analysis logic that branches on the global-dimension fields rather than the set entries. The projection silently disagrees with the set once a third dimension is involved, so posting and analysis-by-dimension produce wrong results.
