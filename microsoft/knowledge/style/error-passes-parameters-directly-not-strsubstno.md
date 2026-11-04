---
bc-version: [all]
domain: style
keywords: [error, strsubstno, label, parameters, concatenation, aa0231]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass parameters directly to `Error()`, do not wrap with `StrSubstNo`

## Description

`Error()` accepts a format string and a variable number of arguments — `Error(SomeLabelErr, Arg1, Arg2)`. Passing already-formatted `Text` instead loses the error's data-classification context, so the platform cannot log the message text in error telemetry. This is different from translation: `StrSubstNo(SomeLabelErr, Arg1)` still formats a translatable label and does not remove that label from XLIFF. A hardcoded user-facing string has no translatable label in the first place.

## Best Practice

Declare a `Label` with the `Err` suffix and the appropriate `Comment` for placeholders, then call `Error(YourErr, arg1, arg2)`. `Message` also accepts substitution arguments; `Confirm` takes its default-answer argument before them: `Confirm(QuestionLbl, false, Value)`. Do not generalize those signatures to `StrMenu`: its arguments are options, default option number, and instruction text. It has no additional substitution arguments, so `StrSubstNo(InstructionLbl, Value)` is valid for its instruction. An `Error('')` (empty message) is acceptable when the calling code expects another layer to emit the actual diagnostic.

See sample: [`error-passes-parameters-directly-not-strsubstno.good.al`](error-passes-parameters-directly-not-strsubstno.good.al).

## Anti Pattern

Passing a preformatted message to `Error`, directly or through a helper, separates the error API from its template and substitution values. Preserve those values for error telemetry rather than claiming the label is untranslatable. Removing `StrSubstNo` from a `StrMenu` instruction and passing a fourth argument is not a valid remediation.

See sample: [`error-passes-parameters-directly-not-strsubstno.bad.al`](error-passes-parameters-directly-not-strsubstno.bad.al).

References: [AA0231](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0231), [Dialog.StrMenu](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dialog/dialog-strmenu-method).
