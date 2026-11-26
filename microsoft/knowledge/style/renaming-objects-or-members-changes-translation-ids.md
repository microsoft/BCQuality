---
bc-version: [all]
domain: style
keywords: [trans-unit, translation-id, rename, xliff, as0125, namespace, translationswithnamespaces]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Renaming an object or member changes its translation IDs

## Description

Each `<trans-unit>` in an XLIFF file has an `id` that identifies the object or object member that defines the text. In the legacy format the ID is built from hashes of those names, for example `Page 1066360047 - Property 2879900210`. Renaming a page, a field, a control, an action, or a `Label` variable therefore produces a different ID in the next generated file. Existing per-language files still carry the old ID, so the renamed text silently falls back to the developer language. The rename compiles, and nothing ties the failure to the translation files.

From runtime 18.0 the opt-in `TranslationsWithNamespaces` compiler feature includes the object's namespace in the ID and uses readable names when the ID is 400 characters or fewer. Enabling it changes the IDs in newly generated files, but the compiler consumes both formats, so existing translation files stay valid.

## Best Practice

Treat a rename of a translated object or member as a change to the translation files as well: regenerate the source file, and move the existing `<target>` text to the new ID in every per-language file in the same change.

Under `TranslationsWithNamespaces`, apply the same care to namespaces. Enabling the feature, or adding a namespace to an object that had none, does not by itself break translations. Moving or removing a namespace does, exactly like a rename.

A rename is also a breaking change for any other app that translates this one. AppSourceCop rule AS0125 covers changes that affect translation IDs; it flags the change but does not move the translations.

## Anti Pattern

A refactoring that renames objects, fields, or label variables for style reasons and leaves the `Translations` folder untouched. The build is green and the English UI is unchanged, while the renamed captions, tooltips, and messages revert to the developer text in every other language.

Do not report enabling `TranslationsWithNamespaces`, or adding a first namespace, as a translation-breaking change.

## References

[Working with translation files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#generating-the-xliff-file) and [AppSourceCop AS0125](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0125).
