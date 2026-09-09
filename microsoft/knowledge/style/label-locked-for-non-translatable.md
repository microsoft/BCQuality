---
bc-version: [all]
domain: style
keywords: [label, locked, translation, token, url, json, xml]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set `Locked = true` on Labels that must not be translated

## Description

A `Label` is by default surfaced to translators and rewritten per locale. That is wrong for strings that are not natural language: HTTP verbs (`GET`, `PUT`), URL fragments, JSON/XML snippets, content-type strings, GUIDs, application keys, and field tokens used by integrations. Translating these breaks the integration the moment a non-English tenant runs the code. The `Locked = true` parameter on the Label declaration tells the translation pipeline to keep the string verbatim, and signals to reviewers that the value is part of a wire-level contract rather than display text.

## Best Practice

Pair `Locked = true` with the `Tok` suffix for short tokens (`GetMethodTok: Label 'GET', Locked = true;`) and with the `Txt` suffix for telemetry strings that contain format placeholders but should not be localized. The `Locked` parameter and the `Tok` / `Txt` suffix together make the intent unambiguous.

See sample: `label-locked-for-non-translatable.good.al`.

## Anti Pattern

`HttpsUrl: Label 'https://example.com';` or `ContentTypeTok: Label 'application/json';` declared without `Locked = true`. The translator localizes them, the integration fails in production for the affected tenant, and the failure is invisible in the developer's English-locale tests.

See sample: `label-locked-for-non-translatable.bad.al`.

## Exception: seeded master-data codes (e.g. posting group codes)

Do not flag a Label as needing `Locked = true` just because its value is later written into a `Code` field with a `TableRelation`, such as `Default VAT Bus. Posting Group`, `Gen. Bus. Posting Group`, or a dimension code. Across the codebase (see `DemoTool` install/upgrade codeunits per country layer), seed values like `DOMESTIC` are declared as ordinary translatable Labels on purpose: each localization layer/company ships its own translated code, and the matching master-data record (e.g. the `VAT Business Posting Group`) is created with that same translated code in the same locale. Because creation and lookup happen together in the same tenant language, translating the code does not break referential integrity. Locking such a Label would instead diverge it from the localized master data it is meant to match. Only require `Locked = true` when the string crosses a locale boundary on its own (URLs, HTTP verbs, JSON/XML/API contract literals, GUIDs) — not for domestic seed/default codes that are created and consumed within the same tenant.
