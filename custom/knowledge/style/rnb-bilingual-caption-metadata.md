---
bc-version: [all]
domain: style
keywords: [caption, nld, dutch, translation, comment, localization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add RNB Dutch Metadata to New Captions

## Description

RNB requires new user-facing captions authored in AL to carry English source text and a Dutch metadata comment in the established `[NLD = ...]` form. This is organization policy; it does not change the platform's caption inheritance behavior or replace the localization build workflow.

## Best Practice

When a new user-facing field, action, or other control needs its own caption, provide English text and the expected Dutch comment, for example `Caption = 'External reference', Comment = '[NLD = Externe referentie]'`. Ensure the consuming localization workflow produces the actual Dutch translation. A comment is not, by itself, proof that the translation is shipped. Let a page field inherit its table-field caption when that is the intended wording; do not add a duplicate page caption just to satisfy this convention.

## Anti Pattern

A newly added standalone user-facing caption has no English source text, or omits the RNB `[NLD = ...]` metadata comment. Do not report an omitted page-level caption when the bound source table field already provides the intended caption, or flag API contract names as UI captions.

See sample: [`rnb-bilingual-caption-metadata.good.al`](rnb-bilingual-caption-metadata.good.al) and [`rnb-bilingual-caption-metadata.bad.al`](rnb-bilingual-caption-metadata.bad.al).

## Applies to

This is RNB localization policy, not a Business Central requirement. The shared caption rule is [caption-required-on-page-fields.md](../../../microsoft/knowledge/style/caption-required-on-page-fields.md).