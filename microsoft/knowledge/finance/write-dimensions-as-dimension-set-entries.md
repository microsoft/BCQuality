---
bc-version: [all]
domain: finance
keywords: [dimension-set-id, shortcut-dimension, global-dimension, journal-line, posting, copy-dimensions]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Copy complete posting dimension sets, not only shortcut projections

## Description

When a journal line or posting document inherits dimensions, its `Dimension Set ID` identifies the complete combination of `Dimension Set Entry` rows. Global and shortcut dimensions expose selected dimensions, not the complete set; the eight shortcut dimensions are not a limit on set membership. Copying only these projections can leave the destination's posting dimensions unchanged or silently lose dimensions outside the shortcuts.

## Best Practice

For an intentional **complete** dimension transfer, copy the source set ID and synchronize the destination's projections through its supported validation or dimension-management routine. On `Gen. Journal Line`, `Validate("Dimension Set ID", SourceSetID)` updates the two shortcut fields. Do not assume another table has the same validation trigger.

When line-specific dimensions must survive a header change, use the appropriate set-combination or delta routine instead of blindly replacing the line's entire set. Reading or filtering a known global dimension is legitimate; it is not a claim to enumerate every dimension. This rule owns transfers through general-journal and financial-document posting records, not writes to Item, Value, Capacity, Warehouse, or inventory-application records owned by SCM. Generic custom-table or master `Default Dimension` wiring belongs to data modeling.

See sample: [`write-dimensions-as-dimension-set-entries.good.al`](write-dimensions-as-dimension-set-entries.good.al).

## Anti Pattern

A routine intended to copy **all** posting dimensions copies only global/shortcut codes, or assigns a set ID without synchronizing the destination's stored projections. Require evidence of a complete-transfer intent and inspect surrounding validation; an explicit change to one selected dimension or a read-only filter is not this defect.

See sample: [`write-dimensions-as-dimension-set-entries.bad.al`](write-dimensions-as-dimension-set-entries.bad.al).

## References

- [Dimension set entries overview](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-dimension-set-entries-overview).
- [DimensionManagement API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/microsoft.finance.dimension.dimensionmanagement).
- [BCApps: Gen. Journal Line dimension validation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Journal/GenJournalLine.Table.al).
