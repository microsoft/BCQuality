---
bc-version: [all]
domain: style
keywords: [label, placeholder, comment, locked, maxlength, localization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Label placeholders need a Comment; locked strings need Locked = true

## Description

AL Labels accept optional properties — `Comment`, `Locked`, `MaxLength` — that travel with the string to localization. The Comment is the translator's only signal for what `%1` and `%2` mean; without it, `'Document %1 has errors in %2.'` translates unpredictably because the translator has to guess whether %1 is a document number, document type, or document name. `Locked = true` marks a string as non-translatable — URLs, JSON keys, short command tokens — and keeps the localization pipeline from translating literals that must stay verbatim. `MaxLength` limits how much of the label survives truncation. The Comment is required whenever placeholders are not self-evident; Locked is required on any non-text value.

## Best Practice

For placeholders, write `Comment = '%1 = Customer No., %2 = Document Type'` alongside the Label. For URLs, HTTP methods, JSON keys, and similar literals, set `Locked = true` and use the `Tok` suffix (see `apply-approved-label-suffixes`). For captions with a tight visual budget, set `MaxLength` to the enforceable length. When the placeholder meaning is obvious (`'Customer %1 not found.'`) the Comment is optional.

See sample: `include-comment-on-labels-with-placeholders.good.al`.

## Anti Pattern

`CustomerLocationErr: Label 'Customer %1 not found in %2.';` with no Comment — translators will not know which identifier maps to which placeholder. `HttpsUrl: Label 'https://example.com';` with no Locked — the URL enters the localization pipeline and may be translated into a broken address.

See sample: `include-comment-on-labels-with-placeholders.bad.al`.
