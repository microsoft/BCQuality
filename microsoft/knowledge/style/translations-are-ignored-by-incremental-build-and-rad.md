---
bc-version: [all]
domain: style
keywords: [translation, xliff, incremental-build, rad, rapid-application-development, publish, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Incremental build and RAD publishing ignore translations

## Description

Two development-time publishing modes leave translations out even when `"features": [ "TranslationFile" ]` is set in `app.json` and the per-language XLIFF files are correct. When the **Incremental Build** setting of the AL Language extension is enabled, all translations are ignored. The same is true when publishing with Rapid Application Development (RAD). In both cases the extension shows its developer text in every language.

This is a property of how the extension was published, not a defect in the labels or the translation files. The same source published with a full build shows the translations.

## Best Practice

Verify translations with a full build and a regular publish. Before investigating labels, translation IDs, or XLIFF content for a "translations do not appear" report, establish how the extension was published.

## Anti Pattern

Concluding from a development sandbox that captions or messages are untranslated, and then changing labels, adding `ML` properties, or rewriting the XLIFF files to fix it, when the extension was published with incremental build or RAD. The change does not make the translations appear in those modes, and switching to `ML` properties removes the text from the translation file altogether; see [`ml-properties-and-textconst-are-not-exported-to-xliff.md`](ml-properties-and-textconst-are-not-exported-to-xliff.md).

Do not report missing translations as a code defect on evidence that comes only from an incremental or RAD publish.

## References

[Working with translation files: Generating the XLIFF file](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#generating-the-xliff-file), [AL Language extension configuration](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-al-extension-configuration), and [Work with Rapid Application Development](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-rad-publishing).
