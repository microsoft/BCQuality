---
bc-version: [all]
domain: style
keywords: [error, strsubstno, label, parameters, concatenation, aa0231, strmenu, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass parameters directly to `Error()`, do not wrap with `StrSubstNo`

## Description

`Error()` accepts a format string and substitution arguments: `Error(SomeLabelErr, Arg1, Arg2)`. Passing already-formatted `Text` instead loses the error's data-classification context, so the platform cannot log the message text in error telemetry (see [error telemetry](../privacy/avoid-strsubstno-prebuild-before-error.md)). This is different from translation: `StrSubstNo(SomeLabelErr, Arg1)` still formats a translatable label; it does not remove that label from XLIFF.

## Best Practice

Keep the error template as a `Label` and pass substitution values separately to `Error`, including when a helper currently returns the fully formatted message. Use a suitable `Comment` to explain ambiguous placeholders. An intentional `Error('')` is not a missing-label defect.

`Message` also accepts substitution arguments. For `Confirm`, preserve its second argument (the default answer) before the substitution arguments: `Confirm(QuestionLbl, false, Value)`. Do not generalize those signatures to `StrMenu`: its arguments are options, default option number, and instruction text, with no substitution arguments. `StrSubstNo(InstructionLbl, Value)` is valid when preparing a translated `StrMenu` instruction.

Use the consuming app's analyzers for literal user messages (AA0216) and direct `Error(StrSubstNo(...))` or concatenation (AA0231); do not duplicate those mechanical diagnostics as review findings. This article adds the remediation boundary: follow visible message construction through helpers, preserve the receiving API's signature, and distinguish error telemetry from label translation.

See sample: [`error-passes-parameters-directly-not-strsubstno.good.al`](error-passes-parameters-directly-not-strsubstno.good.al).

## Anti Pattern

A helper formats a label into `Text` and the caller passes that result to `Error`, separating the error API from the template and values it needs for telemetry classification. Move the formatting to the `Error` call rather than merely hiding the direct AA0231 pattern behind a helper.

An incorrect remediation removes `StrSubstNo` from a `StrMenu` instruction and passes the substitution value as another menu argument, or claims that any use of `StrSubstNo` makes a label untranslatable. Neither follows the AL API contract.

See sample: [`error-passes-parameters-directly-not-strsubstno.bad.al`](error-passes-parameters-directly-not-strsubstno.bad.al).

## References

- [CodeCop AA0231: error data-classification context](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0231)
- [CodeCop AA0216: literal user messages](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0216)
- [Dialog.Confirm signature](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dialog/dialog-confirm-method)
- [Dialog.StrMenu signature](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dialog/dialog-strmenu-method)
- [XLIFF generation from labels](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files)
