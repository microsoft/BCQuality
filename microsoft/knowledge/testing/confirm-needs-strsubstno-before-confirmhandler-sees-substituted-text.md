---
bc-version: [all]
domain: testing
keywords: [confirm, confirmhandler, strsubstno, placeholder, question, substitution]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Build the Confirm message with StrSubstNo, or a ConfirmHandler sees the raw template

## Description

`Confirm`'s placeholder-substitution overload — `Confirm('text %1', false, Value)` — substitutes the placeholder only for the dialog a real user sees. Inside a `[ConfirmHandler]`, the `Question` parameter received is the literal, unsubstituted template string (`'text %1'`), not the value-filled text. A test that asserts `Question` against the expected substituted message either fails outright or silently checks the wrong thing.

## Best Practice

When a `ConfirmHandler` needs to assert on the actual message text, build the string with `StrSubstNo(Text, Value)` in the production code first, and pass the already-substituted string to `Confirm()` with no further placeholder arguments.

See sample: `confirm-needs-strsubstno-before-confirmhandler-sees-substituted-text.good.al`.

## Anti Pattern

Calling `Confirm('text %1', false, Value)` and then asserting the substituted text against `Question` inside a `[ConfirmHandler]`. `Question` holds the raw `'text %1'` template, so the assertion never matches the intended message.

See sample: `confirm-needs-strsubstno-before-confirmhandler-sees-substituted-text.bad.al`.
