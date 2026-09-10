---
bc-version: [all]
domain: data-modeling
keywords: [dimensions, dimensionmanagement, global-dimension, shortcut-dimension, default-dimension, validatedimvaluecode, getdefaultdimid]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire dimension support through DimensionManagement, not ad hoc fields

> Contributions welcome — open a PR to refine or extend this article.

## Description

Adding dimension support to a custom table is not just a matter of adding a `Code[20]` field, and master tables and document/transactional tables wire into `Codeunit "Dimension Management"` through two different models — treating them as one mechanism is itself the mistake this article corrects:

- **Master data** (a custom master table, e.g. "Course") persists **Default Dimension** records: each shortcut dimension field validates through `ValidateDimValueCode`, then the result is saved via `SaveDefaultDim`, and `DeleteDefaultDim` removes them again in `OnDelete`. The master record itself carries no `Dimension Set ID` field.
- **Transactional/document data** (a custom document or journal-line table) carries a single **`Dimension Set ID`** field — a pointer to a shared, deduplicated set of dimension values in `Dimension Set Entry`, assembled from whatever the document inherited plus whatever the user overrode. A document does not acquire that ID by calling `SaveDefaultDim`; it builds a source list with `AddDimSource` (naming the related master table and its key, e.g. `Database::Customer`), then calls `GetDefaultDimID` to compute a new `Dimension Set ID` that inherits the master's Default Dimension records. Editing a shortcut dimension field directly on the document validates through `ValidateShortcutDimValues`, which updates the same `Dimension Set ID` in place rather than writing a separate Default Dimension record.

Skipping the model that actually matches the table's kind produces a field that looks correct in the designer but silently fails to save, validate, or carry through to postings — or, for a document, one that never picks up the customer's/vendor's own dimensions at all.

## Best Practice

For a master table, validate each shortcut dimension field through `ValidateDimValueCode`, save the result with `SaveDefaultDim`, and delete the matching Default Dimension records in `OnDelete`.

For a document table, when the field that attaches the document to a master record changes (e.g. `Customer No.`), call `AddDimSource` naming that master table and key, then `GetDefaultDimID` to compute the document's new `Dimension Set ID`, inheriting the master's Default Dimension records. Validate the document's own Shortcut Dimension fields through `ValidateShortcutDimValues`, which updates that same `Dimension Set ID` rather than persisting a separate Default Dimension record.

See sample: `dimension-management-wiring.good.al`.

## Anti Pattern

Adding a dimension-looking field with only a `TableRelation` to Dimension Value, and no call into `DimensionManagement` at all. The field accepts input but never becomes a real Default Dimension record, so it does not validate against blocked values and does not flow into postings.

See sample: `dimension-management-wiring.bad.al`.
