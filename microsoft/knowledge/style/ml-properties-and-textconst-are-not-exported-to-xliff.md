---
bc-version: [all]
domain: style
keywords: [captionml, tooltipml, optioncaptionml, textconst, xliff, translation, label, multilanguage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `ML` properties and `TextConst` are not exported to the XLIFF file

## Description

The generated XLIFF file contains the strings of `Caption`, `ToolTip`, and the other label properties, of `Label` variables, and of report labels. It does not contain the multilanguage (`ML`) variants: `CaptionML`, `ToolTipML`, `OptionCaptionML`, `InstructionalTextML`, `PromotedActionCategoriesML`, `RequestFilterHeadingML`, `AboutTitleML`, and `AboutTextML`. Variables of the `TextConst` data type are not included either. Text declared that way compiles and displays, but it never reaches a translator through the translation file, and XLIFF translation files are required to submit an app to Marketplace.

Code converted from C/AL, and code written from older examples, commonly still uses these forms.

## Best Practice

Declare user-facing text with the label properties (`Caption`, `ToolTip`, `OptionCaption`, and so on) and with `Label` variables, and supply other languages through XLIFF translation files. Carry translator context in the label's `Comment` parameter instead of inline language codes.

See sample: [`ml-properties-and-textconst-are-not-exported-to-xliff.good.al`](ml-properties-and-textconst-are-not-exported-to-xliff.good.al).

## Anti Pattern

`CaptionML = ENU = 'Loyalty Level', DAN = 'Loyalitetsniveau';` on a field, or `LevelMissingErr: TextConst ENU = 'Select a loyalty level.';` as a message. The languages listed inline are the only ones the text will ever have, the strings are absent from the generated `.xlf`, and adding a per-language translation file does not help because there is no translation unit to target.

Do not report a plain `Caption` or `Label` as untranslated because it carries no language codes: the single developer text is the source string, and translations live in the XLIFF files.

See sample: [`ml-properties-and-textconst-are-not-exported-to-xliff.bad.al`](ml-properties-and-textconst-are-not-exported-to-xliff.bad.al).

## References

[Working with translation files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#generating-the-xliff-file), [Working with labels](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-using-labels), and [AppSourceCop AS0015](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0015).
