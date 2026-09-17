---
bc-version: [all]
domain: style
keywords: [dateformula, evaluate, calcdate, date-expression, language-independent, multilanguage, global-language]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Parse DateFormula constants with language-independent input

## Description

A `DateFormula` stores a formula in a language-independent representation, but `Evaluate` must first interpret its text input. Declaring the destination as `DateFormula` does not make an English literal such as `1W` independent of the session language: French uses `S` for weeks. Passing the resulting typed variable to `CalcDate` does not repair a parsing failure that already happened in `Evaluate`.

## Best Practice

For an application-defined formula in a normal two-argument `Evaluate` call, use the generic units inside angle brackets, such as `<1W>`. Apply this at the text-to-`DateFormula` boundary, including a visible constant passed through a helper. A label's `Locked = true` prevents translation of its text; it does not make unbracketed English units language independent.

Preserve genuinely localized input: text entered by the user, or already formatted for the same session language, should be parsed in that language. Do not blindly wrap that text in angle brackets. Already invariant `<...>` literals, explicit import-format conversions, a typed formula passed to `CalcDate`, and `Format(Interval) = ''` checks are not findings without an unsafe constant at the parsing boundary.

See sample: [`dateformula-evaluate-needs-language-independent-literals.good.al`](dateformula-evaluate-needs-language-independent-literals.good.al).

## Anti Pattern

A hard-coded, language-fixed formula such as `1W` flows into a normal two-argument `Evaluate` whose destination is known to be `DateFormula`, and the application expects that default to work across session languages. Require the destination type and constant provenance; an arbitrary `Evaluate` call or dynamic text parameter is not enough. The resulting code can compile and work in English while failing when the same default is first needed in another language.

Do not report direct `CalcDate` text arguments under this article: CodeCop AA0462 already owns the requirement for a typed formula or angle-bracketed text there. Its typed-argument check does not establish that an earlier `Evaluate` parsed language-independent input.

See sample: [`dateformula-evaluate-needs-language-independent-literals.bad.al`](dateformula-evaluate-needs-language-independent-literals.bad.al).

## Validation

Exercise the default path with an empty formula and an explicit reference date in English and a language with different unit tokens, such as French. Both should produce a date one week later. Also cover an already configured formula and input entered in the active language; these must retain their meaning.

## References

[DateFormula data type](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/dateformula/dateformula-data-type) and [CalcDate language behavior](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/system/system-calcdate-dateformula-date-method).

[CodeCop AA0462](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0462) defines the separate direct-`CalcDate` check.

[BaseApp retention scheduling](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/System/RetentionPolicy/RetentionPolicyScheduler.Codeunit.al#L73-L97) initializes a typed formula with an invariant literal.
