---
bc-version: [all]
domain: data-modeling
keywords: [document-header, initrecord, number-series, default-values, oninsert, initialization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Initialize document defaults in `InitRecord` after assigning the number

## Description

Business Central document headers assign their number series first and then call an `InitRecord` procedure that owns the remaining business defaults, such as posting and document dates. Keeping that sequence and extensibility point makes initialization consistent for every creation path and lets extensions subscribe around one documented operation. Defaults scattered across page triggers or unrelated helpers can differ between UI, API, test, and background creation.

## Best Practice

In the document table's insert path, assign the document number and then call `InitRecord`. Keep the default assignments in that procedure and expose narrow before/after events when other extensions must participate.

See sample: `initialize-document-defaults-in-initrecord.good.al`.

## Anti Pattern

Assigning document defaults in a page trigger, or scattering them directly through `OnInsert` with no `InitRecord` boundary. Non-page creation paths can then miss the defaults, and extensions have no stable initialization hook.

See sample: `initialize-document-defaults-in-initrecord.bad.al`.

## Reference

[Use the InitRecord function](https://learn.microsoft.com/en-us/training/modules/use-document-standards-business-central/3-use-initrecord-function)
