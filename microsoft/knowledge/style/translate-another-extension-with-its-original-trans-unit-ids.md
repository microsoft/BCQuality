---
bc-version: [all]
domain: style
keywords: [xliff, translation, dependency, trans-unit, base-application, language-app, original-attribute]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Translate another extension with its own translation IDs

## Description

An extension can ship translations for a different extension, for example a language app that translates the Base Application. The translated extension must be listed in `dependencies` in `app.json`, and the translated `.xlf` file goes in a `Translations` folder at the root of the translating extension. Two details decide whether those translations are applied, and neither produces a build error when wrong.

First, the `original` attribute of the `<file>` element must not be the name of the current app. When it is, the translations are used only for labels in the current app. Second, each `<trans-unit id>` must be the ID of the property where the text was originally defined, not the ID of an extension object that modifies it.

## Best Practice

Take the translation IDs from the XLIFF file generated for the extension being translated, and keep that extension's name in the `original` attribute. To change the translated caption of a page that a page extension also touches, target the page's own ID, such as `Page 2931038265 - Property 2879900210`, rather than the page extension's ID.

The generated file of an app that translates itself already has the correct `original` value; this concern applies only to translating a dependency.

## Anti Pattern

Copying the current app's generated `.xlf` as a starting point for translating a dependency, which leaves `original` set to the current app, or using the `PageExtension ...` translation ID to translate a caption that the base page defines. The file is accepted, the extension builds and publishes, and the dependency's UI stays untranslated.

## References

[Working with translation files: Translating other extensions](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#translating-other-extensions).
