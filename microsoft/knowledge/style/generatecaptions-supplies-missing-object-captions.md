---
bc-version: [all]
domain: style
keywords: [generatecaptions, caption, translation-file, xliff, app-json, object-caption, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `GenerateCaptions` supplies captions for objects that declare none

## Description

The `GenerateCaptions` compiler feature in `app.json` generates a caption from the object name for pages, tables, reports, XMLports, and request pages that have no `Caption` or `CaptionML` of their own, and writes those captions to the XLIFF file so they can be translated. An object that already sets `Caption` keeps that value. The feature depends on `TranslationFile`, so both must be listed: `"features": [ "TranslationFile", "GenerateCaptions" ]`.

In a project that enables the feature, an object without a `Caption` property is therefore not missing a caption or a translation unit. Whether the feature is enabled is visible only in `app.json`, not in the object file under review.

## Best Practice

Before reporting an object-level caption as missing, check the `features` setting in the project's `app.json`. With `GenerateCaptions` enabled, add an explicit `Caption` only when the wording should differ from the object name.

Keep the scope exact. The generated caption applies to the listed object types. It does not label page fields, actions, or other controls; those follow their own rules, such as inheritance from the source table field described in [`caption-required-on-page-fields.md`](caption-required-on-page-fields.md).

## Anti Pattern

Reporting every page, table, or report without a `Caption` as untranslatable in a project whose `app.json` enables `GenerateCaptions`, or adding captions that merely repeat the object names to satisfy that report.

The opposite defect is assuming generated captions without checking the manifest: when `GenerateCaptions` is not listed, or `TranslationFile` is absent, no caption is generated and the object has no translation unit for its name.

## References

[Working with translation files: Generating the XLIFF file](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#generating-the-xliff-file) and the `features` setting in [JSON files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-json-files#appjson-file).
