---
bc-version: [all]
domain: style
keywords: [xliff, xlf, translation-file, generated, translations-folder, target-language, app-json]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The generated XLIFF file is rewritten on every build

## Description

With `"features": [ "TranslationFile" ]` in `app.json`, each build writes a `.xlf` file into the `Translations` folder that contains every label, label property, and report label of the extension as `<source>` elements. That generated file is build output: the next build overwrites it. A translation is a separate file that adds a `target-language` and one `<target>` per label, and there can be only one `.xlf` file per language. Adding `<target>` elements to the generated file therefore loses the work on the next build, and it is easy to miss because the build still succeeds.

## Best Practice

Treat the generated file as the source list only. Keep each translation in its own file in the `Translations` folder, one file per target language, named after the extension and language (for example `<extensionname>.<language>.xlf`); the name is a convention, not enforced. Regenerate the source file by building, then bring new or changed `<source>` entries into the per-language files.

When reviewing, a per-language file that lags behind the generated file is a translation gap, not a compile problem: untranslated labels fall back to the developer text.

## Anti Pattern

Editing the generated file in place, for example adding `target-language` and `<target>` elements to it, or committing it as the Danish or German translation. The next build replaces the file and the translations disappear without a diagnostic.

A second form is two files for the same language in the `Translations` folder, such as a renamed copy next to an older one. Only one file per language is supported.

## References

[Working with translation files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files) and the `features` setting in [JSON files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-json-files).
